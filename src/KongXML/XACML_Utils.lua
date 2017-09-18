local XACML_Utils_module = {}

local xml = require("kong.plugins.pepkong.kongxml.xmlsimple").newParser()

-- Recebe um XML de resposta de um PDP
-- retorna Permit, se o PDP respondeu permit
--    retorna Deny caso contrario, ou se algum erro ocorreu
-- TODO: obligations
function XACML_Utils_module.extractResponse(rawXML)
    parsed = xml:ParseXmlText(rawXML)
    response = parsed.Response.Result.Decision:value()

    -- provavel erro de conexao
    if (response == nil) then
      return 'Deny'
    end

    if (response == 'Permit') then
      return 'Permit'
    end
    return 'Deny'
end

-- Receives information about a request.
-- Return a JSON encoded as string, ready to be sent to a JSON-XACML PDP
function XACML_Utils_module.buildRequest(role, action, resource, userIpAddr)
  requestJson = ({Request={Action={Attribute={}},Resource={Attribute={}},AccessSubject={Attribute={}}}})
  
  
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


return XACML_Utils_module
