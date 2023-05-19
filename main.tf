resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "additionalProperties" = true,
        "properties" = {
            "queueId" = {
                "type" = "string"
            }
        },
        "required" = [
            "queueId"
        ],
        "type" = "object"
    })
    contract_output = jsonencode({
        "additionalProperties" = true,
        "properties" = {
            "counts" = {
                "description" = "Integer array of on queue agent counts for each routing status. Wrap this variable in a sum() expression to get the total number of on queue agents.",
                "items" = {
                    "type" = "integer"
                },
                "type" = "array"
            },
            "statuses" = {
                "description" = "String array of on queue agent routing statuses for matching up to the counts array.",
                "items" = {
                    "type" = "string"
                },
                "type" = "array"
            }
        },
        "type" = "object"
    })
    
    config_request {
        request_template     = "{\n \"filter\": {\n  \"type\": \"or\",\n  \"predicates\": [\n   {\n    \"type\": \"dimension\",\n    \"dimension\": \"queueId\",\n    \"operator\": \"matches\",\n    \"value\": \"$${input.queueId}\"\n   }\n  ]\n },\n \"metrics\": [\n  \"oOnQueueUsers\"\n ]\n}"
        request_type         = "POST"
        request_url_template = "/api/v2/analytics/queues/observations/query"
        headers = {
			UserAgent = "PureCloudIntegrations/1.0"
			Content-Type = "application/json"
		}
    }

    config_response {
        success_template = "{\"counts\": $${counts}, \"statuses\": $${statuses}}"
        translation_map = { 
			statuses = "$.results[0].data..qualifier"
			counts = "$.results[0].data..stats.count"
		}
        translation_map_defaults = {       
			statuses = "[\"Error\"]"
			counts = "[0]"
		}
    }
}