local keypass_module = {}
local utils = require "kong.plugins.pepkong.utils"
local xmlUtils = require "kong.plugins.pepkong.kongxml.utils"
local http = require "socket.http"

--[[envia um request de acesso ao PDP
   Parametros: role de quem pretende realizar o acesso
              acao pretendiada (POST, write etc)
              recurso: path da API
              ip ip do usuario solicitante

    retornos:
            'Permit' -> o PDP permitiu o acesso explicitamente
            'Deny' -> o PDP negou o acesso, ou não cnseguiu chegar a uma decisão
            Codigo de erro -> ocorreu um erro ao realizar a solicitacao http
            'connection refused' -> nao foi possivel conectar-se ao servidor
  http.request retorna a string 'connection refused' instataneamente se nao encontrar o servidor
--]]
function keypass_module.sendRequest(pdpUrl, userRole, action, resource, ip)
    utils.printToFile(debug.getinfo(1).currentline,'keyPass: userRole' .. userRole .. ' action: ' .. action .. ' url: '.. pdpUrl)
    local requestXML = xmlUtils.buildRequest(userRole, action, resource, ip)
    
    local response_body = { }

    -- envia a solicitacao
    local res, code, response_headers, status = http.request
		{
			url = pdpUrl  .. '/pdp/identity/entitlement/decision',
			method = "POST",
      sink = ltn12.sink.table(response_body),
			headers =
			{
        ["content-type"] = 'application/json',
        ["charset"] = 'UTF-8',
        ["Accept"] = 'application/json',
        ["Fiware-Service"] = 'myTenant',
        ["Content-Length"] = requestXML:len(),
			},

      source =  ltn12.source.string(requestXML),
		}

    -- envio funcionou. extrai do XML da repsosta o veredicto do PDP
    if code == 200 then      
        local decoded = json.decode(response_body[1])
        return decoded.decision
    else
      --envio falhou. retorna codigo de erro
      return code
    end
end

return keypass_module
