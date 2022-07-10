local crypto = {}

-- load required libraries
local openssl = require("openssl")
openssl.load_library()
local x509 = require("openssl.x509")
local rand = require("openssl.rand")
local util = require("adobe.util.util")

function crypto.generateDeviceKey()
    return rand.bytes(16)
end

function crypto.encryptLogin(username, password, deviceKey, authCert)
    -- construct buffer (devicekey + len(username) + username + len(password) + password)
    local buffer = deviceKey
    buffer = buffer .. string.char(username:len())
    -- FIXME: Encode as Latin-1
    buffer = buffer .. username
    buffer = buffer .. string.char(password:len())
    -- FIXME: Encode as Latin-1
    buffer = buffer .. password
    --print(util.base64.encode(buffer))
    -- load public key from cert
    local cert = x509.new(util.base64.decode(authCert))
    local key = cert:get_pubkey()
    local encrypted = key:encrypt(buffer)
    return util.base64.encode(encrypted)
end

return crypto
