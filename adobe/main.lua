package.path = ";./dependencies/?.lua;./dependencies/?/init.lua" .. package.path

-- load required modules
local adobe = require("adobe.adobe")

print("Getting authentication service info...")
local authInfo = adobe.getAuthenticationServiceInfo()
print("Got authentication service info!")

print("Signing in with anonymous account...")
local creds = adobe.signIn("anonymous", "", "", authInfo.certificate)
print("Signed in!")

print("Activating as " .. adobe.VERSION.name .. "...")
adobe.activate(creds.user, creds.deviceKey, creds.pkcs12)
print("Activated!")