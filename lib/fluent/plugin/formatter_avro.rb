require 'avro'
require 'fluent/plugin/formatter'
require 'net/http'
require 'json'

module Fluent
  module Plugin
    class AvroFormatter < Formatter
      Fluent::Plugin.register_formatter('avro', self)

      config_param :schema_file, :string, :default => nil
      config_param :schema_json, :string, :default => nil
      config_param :schema_registry_uri, :string, :default => nil
      config_param :schema_registry_port, :string, :default => nil
      config_param :schema_id, :string, :default => nil
      config_param :use_ssl, :bool, :default => false

      def configure(conf)
        super
        if not (@schema_json.nil? ^ @schema_file.nil? ^ @schema_uri.nil?) then
          raise Fluent::ConfigError, 'schema_json or schema_file or schema_uri (but not all) is required'
        end
          
        if not @schema_uri.nil? then
          if not @schema_id then
            raise Fluent::ConfigError, 'schema_id is required while using schema_uri'
          end
            
          net = Net::HTTP.new(@schema_registry_uri, @schema_registry_port)
          if @use_ssl then
            net.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
            
          request = Net::HTTP::Get.new("/schemas/ids/" + @schema_id)
          request["Accept"] = "application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json"
          response = net.request(request)
            
          if response.code == "200" then
            @schema_json = JSON.parse(response.body)["schema"]
          end
            
        elsif not @schema_file.nil? then
          @schema_json = File.read(@schema_file)
        end
        
        @schema = Avro::Schema.parse(@schema_json)
        @writer = Avro::IO::DatumWriter.new(@schema)
      end

      def format(tag, time, record)
        buffer = StringIO.new
        encoder = Avro::IO::BinaryEncoder.new(buffer)
        @writer.write(record, encoder)
        buffer.string
      end
    end
  end
end
