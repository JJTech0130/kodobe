package.path = ";./dependencies/?.lua;./dependencies/?/init.lua" .. package.path

-- load required modules
local adobe = require("adobe.adobe")
local crypto = require("adobe.util.crypto")
local util = require("adobe.util.util")

print("Getting authentication service info...")
local authInfo = adobe.getAuthenticationServiceInfo()
print("Got authentication service info!")

print("Signing in with anonymous...")
local creds = adobe.signIn("anonymous", "", "", authInfo.certificate)
--adobe.signIn("AdobeID", "wisawog159@satedly.com", "ieCggSk6C96uLGR", authInfo.certificate)
print("Signed in!")

--print("Creating fingerprint...")
--print("Fingerprint: " .. crypto.fingerprint(crypto.serial(), crypto.deviceKey.new()))
--creds = { user = "urn:uuid:9ff48d98-40d5-46e3-a50c-ebe57a5aa8c7", deviceKey = crypto.deviceKey.new() }
adobe.activate(creds.user, creds.deviceKey, creds.pkcs12)