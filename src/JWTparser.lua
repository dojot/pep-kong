local jwtparser_module = {}
local utils = require "kong.plugins.pepkong.utils"
local json = require("json")

-- base64 character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- base 64 decode
local function dec64(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end


function jwtparser_module.jwtGetRoles(rawJWT)
  local rawJWTCut = utils.split(rawJWT,'.')

  --verify if the JWT have all 3 parts
  if table.getn(rawJWTCut) == 3 then
   
    local plainBody = dec64(rawJWTCut[2])
    if plainBody then      
      local jsonJWTBody = json.decode(plainBody)
      return { jsonJWTBody.profile }
    end
  end
  
  -- return nil if the JWT is invalid
  return nil
end

return jwtparser_module