# fluent-plugin-avro

[![Build Status](https://travis-ci.org/takebayashi/fluent-plugin-avro.svg)](https://travis-ci.org/takebayashi/fluent-plugin-avro)

fluent-plugin-avro provides a formatter plugin for Fluentd.

## Configurations

Either `schema_registry config` or `schema_file` or `schema_json` is required.

| Name | Description |
| ---- | ----------- |
| `schema_file` | filename of Avro schema |
| `schema_json` | JSON representation of Avro schema |
| `schema_registry_uri` | Schema Registry URI |
| `schema_registry_port` | Schema Registry Port |
| `schema_id` | Id of the Schema |
| `use_ssl` | To use or not to use SSL |

### Example 

```
<match example.avro>
  @type file
  path /path/to/output
  <formatter>
    @type avro
    schema_registry_uri localhost
    schema_registry_port 8081
    schema_id 1
    use_ssl false
    ## You can use schema_file
    # schema_file /path/to/schema.avsc
    ## You can use schema_json 
    # schema_json {"type":"record","name":"example","namespace":"org.example","fields":[{"name":"message","type":"string"}]}
  </formatter>

  
  
</match>
```

## License

Apache License, Version 2.0.
