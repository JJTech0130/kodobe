package.path = ";./dependencies/?.lua;./dependencies/?/init.lua" .. package.path
-- load required modules
local adobe = require("adobe.adobe")
local crypto = require("adobe.util.crypto")
local templates = require("adobe.templates")
local base64 = require("adobe.util.util").base64

-- main
--local authServiceInfo = adobe.getAuthenticationServiceInfo()
--local activationCert = adobe.getActivationServiceCertificate()
local deviceKey = crypto.generateDeviceKey()
-- encrypt anonymous credentials (no username or password)
local login = crypto.encryptLogin("", "", deviceKey, authServiceInfo.certificate)
--local login = "TEST"
--print(templates.signInRequest("anonymous", login))
local authKey = crypto.generateKey(deviceKey)
local licenseKey = crypto.generateKey(deviceKey)

local signInRequest = templates.signInRequest(
    "anonymous", login, 
    base64.encode(authKey.public), 
    base64.encode(authKey.encrypted), 
    base64.encode(licenseKey.public), 
    base64.encode(licenseKey.encrypted)
)
print(signInRequest)