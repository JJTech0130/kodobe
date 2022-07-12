package.path = ";./dependencies/?.lua;./dependencies/?/init.lua" .. package.path

-- load required modules
local adobe = require("adobe.adobe")
local crypto = require("adobe.util.crypto")
local util = require("adobe.util.util")
local pkey = require("openssl.pkey")
--print("Getting authentication service info...")
--local authInfo = adobe.getAuthenticationServiceInfo()
--print("Got authentication service info!")

--print("Signing in with anonymous...")
--local creds = adobe.signIn("anonymous", "", "", authInfo.certificate)
----adobe.signIn("AdobeID", "wisawog159@satedly.com", "ieCggSk6C96uLGR", authInfo.certificate)
--print("Signed in!")

----print("Creating fingerprint...")
----print("Fingerprint: " .. crypto.fingerprint(crypto.serial(), crypto.deviceKey.new()))
----creds = { user = "urn:uuid:9ff48d98-40d5-46e3-a50c-ebe57a5aa8c7", deviceKey = crypto.deviceKey.new() }
--adobe.activate(creds.user, creds.deviceKey, creds.pkcs12)
local test_key = "MIICdAIBADANBgkqhkiG9w0BAQEFAASCAl4wggJaAgEAAoGBALluuPvdDpr4L0j3eIGy3VxhgRcEKU3++qwbdvLXI99/izW9kfELFFJtq5d4ktIIUIvHsWkW0jblGi+bQ4sQXCeIvtOgqVHMSvRpW78lnGEkdD4Y1qhbcVGw7OGpWlhp8qCJKVCGbrkML7BSwFvQqqvg4vMU8O1uALfJvicKN3YfAgMBAAECf3uEg+Hr+DrstHhZF40zJPHKG3FkFd3HerXbOawMH5Q6CKTuKDGmOYQD+StFIlMArQJh8fxTVM3gSqgPkyyiesw0OuECU985FaLbUWxuCQzBcitnhl+VSv19oEPHTJWu0nYabasfT4oPjf8eiWR/ymJ9DZrjMWWy4Xf/S+/nFYUCQQDIZ1pc9nZsCB4QiBl5agTXoMcKavxFHPKxI/mHfRCHYjNyirziBJ+Dc/N40zKvldNBjO43KjLhUZs/BxdAJo09AkEA7OAdsg6SmviVV8xk0vuTmgLxhD7aZ9vpV4KF5+TH2DbximFoOP3YRObXV862wAjCpa84v43ok7Imtsu3NKQ+iwJAc0mx3GUU/1U0JoKFVSm+m2Ws27tsYT4kB/AQLvetuJSv0CcsPkI2meLsoAev0v84Ry+SIz4tgx31V672mzsSaQJBAJET1rw2Vq5Zr8Y9ZkceVFGQmfGAOW5A71Jsm6zin0+anyc874NwXaQdqiiab61/8A9gGSahOKA1DacJcCTqr28CQGm4mn3rOQFf+nniajIobATjNHaZJ76Xnc6rtoreK6+ZjO9wYF+797X/bhiV11Fpakvyrz6+t7bAd0PPQ2taTDg="
--pkey, pcert = crypto.parsePkcs12(test_key, "")
local key, error = pkey.new(util.base64.decode(test_key))
local test_payload = { 0x34, 0x52, 0xe3, 0xd1, 0x1c, 0xdd, 0x70, 0xeb, 0x90, 0x32, 0x3f, 0x29, 0x1c, 0x06, 0xaf, 0xaf, 0xe1, 0x0e, 0x09, 0x8a }
local byte_payload = ""
for i, v in ipairs(test_payload) do
    byte_payload = byte_payload .. string.char(v)
end
print(crypto.sign(key, byte_payload))