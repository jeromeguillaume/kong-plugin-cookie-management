local http  = require("resty.http")
local cjson = require("cjson.safe")

local CookieManagement = {
  -- Executed after OIDC plugin (priority=1050) and before AI Proxy plugin (priority=770)
  PRIORITY = 1000,
  VERSION = "0.0.1",
}

function CookieManagement:header_filter(conf)

  local headers = kong.response.get_headers()
  for k,v in pairs (headers) do
    if k == "set-cookie" and v and type (v) == "string" then
        local b,_=string.find(v, conf.cookie_name .. "=")
        if b then
          kong.ctx.shared[conf.cookie_name] =v
          kong.log.notice("set-cookie: '", conf.cookie_name, "' is found")
          break
        end
    end
  end
  if not kong.ctx.shared[conf.cookie_name] then
    kong.log.notice("set-cookie: '", conf.cookie_name, "' is NOT found")
  end

end

return CookieManagement
