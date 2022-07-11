local crypto = {}

-- load required libraries
local openssl = require("openssl")
openssl.load_library()
local x509    = require("openssl.x509")
local rand    = require("openssl.rand")
local cipher  = require("openssl.cipher")
local pkey    = require("openssl.pkey")

local util = require("adobe.util.util")

-- generate a random device key
function crypto.generateDeviceKey()
    return rand.bytes(16)
end

-- encrypt a username, password, and device key using a certificate
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

-- encrypt the provided data with the provided device key, using AES
function crypto.encryptWithDeviceKey(deviceKey, data)
    local aes = cipher.new("AES-128-CBC")
    local iv = rand.bytes(16)
    local encrypted, err = aes:encrypt(deviceKey, iv, data)
    if err ~= nil then error(err) end
    return iv .. encrypted
end

-- generate an RSA keypair
-- if passed an (optional) device key, will return private key encrypted with it
function crypto.generateKey(deviceKey)
    local key, err = pkey.new({
        type = 'RSA',
        bits = 1025,
        exp = 65537
    })
    if err ~= nil then error(err) end

    local public = key:tostring("public", "DER")
    local private = key:tostring("private", "DER")

    local encrypted = nil
    if deviceKey ~= nil then
        encrypted = crypto.encryptWithDeviceKey(deviceKey, private)
    end

    return { public = public, private = private, encrypted = encrypted }
end

return crypto
