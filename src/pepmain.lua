local _M = {}
local utils = require "kong.plugins.pepkong.utils"
local pl_stringx = require "pl.stringx"
local req_get_headers = ngx.req.get_headers
local http = require "socket.http"
local responses = require "kong.tools.responses"
local keypass = require "kong.plugins.pepkong.keypass"
local jwtParser = require "kong.plugins.pepkong.jwtparser"


function _M.run(conf)
    utils.printToFile(debug.getinfo(1).currentline,'Inicio de access.run()')

    -- missing JWT token on the HTTP header
    if not req_get_headers()["Authorization"] then
      return responses.send(401)
    end

    -- remove the word 'bearer' from te token
    local rawJWT = string.sub(req_get_headers()["Authorization"]  , 8)
    
    -- get user profile (role) from the token
    -- TODO: add suport to multiple roles
    local userRoles = jwtParser.jwtGetRoles(rawJWT)
  
    -- if no role has been specified, negate the access
    if not userRoles or next(userRoles) == nil then
      return responses.send(400)
    end

    -- this loop is for debug porposes
    for i = 1, table.getn(userRoles) do
      utils.printToFile(debug.getinfo(1).currentline,'role: ' .. userRoles[i])
    end

    -- gather information about the request. Like ip address and HTTP method
    local ipAddr  = ngx.var.remote_addr
    local method = ngx.var.request_method


    -- Get the URL prefix and discard URL parameters
    local path_prefix = utils.split( ngx.var.request_uri , '?' )[1]
    if pl_stringx.endswith(path_prefix, "/") then
        path_prefix = path_prefix:sub(1, path_prefix:len() - 1)
    end
    local toPrint = 'Received uri: ' .. path_prefix .. ' method: ' .. method .. ' ip: ' .. ipAddr .. ' role: ' .. userRoles[1]
    utils.printToFile(debug.getinfo(1).currentline,toPrint)

    -- send the gathered information to PDP, asking if the access is allowed
    local pdpresp = keypass.sendRequest(conf.pdpUrl , userRoles[1], method, path_prefix, ipAddr)
    utils.printToFile(debug.getinfo(1).currentline,'veredicto pdp-ws:' .. pdpresp)

    if not (pdpresp == 'Permit' or pdpresp == 'permit') then
      return responses.send(403)
    end

end

return _M
