package.path = ";./dependencies/?.lua;./dependencies/?/init.lua" .. package.path
-- load required modules
local adobe = require("adobe.adobe")
local crypto = require("adobe.util.crypto")
local base64 = require("adobe.util.util").base64

-- main
local authInfo = adobe.getAuthenticationServiceInfo()
--for i, m in ipairs(authInfo.methods) do
--    print(m.name, m.method)
--end

--adobe.signIn("AdobeID", "wisawog159@satedly.com", "ieCggSk6C96uLGR", authInfo.certificate)
adobe.signIn("anonymous", "", "", authInfo.certificate)