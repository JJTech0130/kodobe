package.path = ";./dependencies/?.lua;./dependencies/?/init.lua" .. package.path
-- load required modules
local adobe = require("adobe.adobe")
local crypto = require("adobe.util.crypto")
local templates = require("adobe.templates")

-- main
local authServiceInfo = adobe.getAuthenticationServiceInfo()
local activationCert = adobe.getActivationServiceCertificate()
local deviceKey = crypto.generateDeviceKey()
-- encrypto anon credentials (no use an password)
local login = crypto.encryptLogin("", "", deviceKey, authServiceInfo.certificate)
print(templates.signInRequest("anonymous", login))
