package.path = ";./dependencies/?.lua;./dependencies/?/init.lua" .. package.path
-- load required modules
local adobe = require("adobe.adobe")
local crypto = require("adobe.util.crypto")
local base64 = require("adobe.util.util").base64

-- main
adobe.signIn("anonymous", "", "")