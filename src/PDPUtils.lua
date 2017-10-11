local PDP_Utils_module = {}

local jwtParser = require "kong.plugins.pepkong.jwtparser"


-- Receives information about a request and encode it to be send to the PDP.
-- How the request is encoded depends on 'pdpMode' parameter
function PDP_Utils_module.buildRequest(pdpMode, rawJWT, action, resource, userIpAddr)
  if (pdpMode == 'JWTForward') then
    -- Forward the JWT. so JWT capable PDPs have all possible information
    local requestJson = ({
            jwt = rawJWT,
            action = action,
            resource = resource
          })
    return json.encode(requestJson)

  elseif (pdpMode == 'JSON_XACML') then
    -- Return a JSON encoded as string, ready to be sent to the PDP

    -- get user profile (role) from the token
    local userRoles = jwtParser.jwtGetRoles(rawJWT)
    local requestJson = ({Request={Action={Attribute={}},Resource={Attribute={}},AccessSubject={Attribute={}}}})


    requestJson.Request.Action.Attribute = {{
      AttributeId = "urn:oasis:names:tc:xacml:1.0:action:action-id",
      Value = action
    }}


    requestJson.Request.Resource.Attribute = {{
      AttributeId = "urn:oasis:names:tc:xacml:1.0:resource:resource-id",
      Value = resource
    }}

    requestJson.Request.AccessSubject.Attribute = {{
      AttributeId = "urn:oasis:names:tc:xacml:1.0:subject:subject-id",
      Value = role
    }}

    return json.encode(requestJson)
  end
end


return PDP_Utils_module
