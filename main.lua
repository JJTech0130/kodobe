package.path = ";./dependencies/?.lua;./dependencies/?/init.lua" .. package.path
-- load required modules
local http      = require("socket.http")    -- HTTP(S)
local url       = require("socket.url")     -- URL manipulation
local util      = require("util.util")      -- basic utility functions
local crypto    = require("util.crypto")    -- crypto helper
local xml       = require("util.xml")       -- xml helper
local templates = require("util.templates") -- xml templates

-- Eden2 activation service 
local EDEN_URL = url.parse("https://adeactivate.adobe.com/adept")

-- get information about the authentication service
local function getAuthenticationServiceInfo()
    -- construct the endpoint from the base URL
    local endpoint = util.tableShallowCopy(EDEN_URL)
    endpoint.path = endpoint.path .. "/AuthenticationServiceInfo"
    
    local response = http.request(url.build(endpoint))
    local info = xml.deserialize(response).authenticationServiceInfo

    -- parse the methods into a nicer table
    local raw = info.signInMethods.signInMethod
    local methods = {}
    for i, m in ipairs(raw) do
        methods[i] = {
            name = m[1],
            method = m._attr.method,
        }
    end
    return { certificate = info.certificate, methods = methods }
end

local function getActivationServiceCertificate()
    -- construct the endpoint from the base URL
    local endpoint = util.tableShallowCopy(EDEN_URL)
    endpoint.path = endpoint.path .. "/ActivationServiceInfo"
    
    local response = http.request(url.build(endpoint))
    local info = xml.deserialize(response).activationServiceInfo   

    return info.certificate
end

function buildSignInRequest(type, username, password, authCert)
    print("TODO")
end

-- main
local authServiceInfo = getAuthenticationServiceInfo()
local activationCert = getActivationServiceCertificate()
local deviceKey = crypto.generateDeviceKey()
-- encrypto anon credentials (no use an password)
local login = crypto.encryptLogin("", "", deviceKey, authServiceInfo.certificate)
print(templates.signInRequest("anonymous", login))
