# kong-plugin-cookie-management

## Overview
A kong plugin for getting a cookie value and putting it in memory in the event it has been removed by other plugin. You can put it back at the end of the request process by using a `post-function` plugin.

## Issue
The cookie issued by the OIDC session management plugin is removed by the AI Proxy plugin (kong v3.12 and earlier release), like all other cookies (issued for instance by OpenAI)

## Solution
Enable this plugin in the context of OIDC and AI Proxy plugins. It gets the cookie from the OIDC session. Once the cookie has been removed by the AI Proxy plugin you can add it by using a `post-function` plugin and its `header_filter` phase.

### Detailed solution
Those plugins are executed in this order during the request processing.
1) Add `openid-connect` plugin: set the `config.session_cookie_name`
2) Add `cookie-management` plugin. The process is:
  - In `header_filter` phase, get the cookie value from the HTTP rersponse `set-cookie` header
  - Put the value in `kong.ctx.name_of_your_cookie`
3) Add `post-function` plugin and put the following code in the `header_filter` phase:
```lua
local cookieName="sessionOIDC"
if kong.ctx.shared[cookieName] then
  local headers = kong.response.get_headers()
  local cookieFound = false
  for k,v in pairs (headers) do
    if k == "set-cookie" and v and type (v) == "string" then
        local b,_=string.find(v, cookieName.."=")
        if b then
            cookieFound = true
            break
        end
    end
  end
  if not cookieFound then
    kong.response.add_header("Set-Cookie", kong.ctx.shared[cookieName])
  end
end
```
3) Align the cookie name for the 3 plugins:
  - `openid-connect` plugin: `config.session_cookie_name`
  - `cookie-management` plugin: `config.cookie_name`
  - `post-function` plugin: Lua code (see above: `local cookieName`)

