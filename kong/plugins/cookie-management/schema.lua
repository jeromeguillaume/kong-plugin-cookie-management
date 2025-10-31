local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "cookie-management"

local schema = {
 name = PLUGIN_NAME,
 fields = {
   { consumer = typedefs.no_consumer },
   { protocols = typedefs.protocols_http },
   { config = {
       type = "record",
       fields = {
         { cookie_name = {
              required = true,
              type = "string",
              default = "sessionOIDC",
            }
          }
       },
     },
   },
 },
}

return schema
