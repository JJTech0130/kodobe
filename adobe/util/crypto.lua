local crypto = {}

-- load required libraries
local openssl = require("openssl")
openssl.load_library()
--ngx.debug = true
local x509    = require("openssl.x509")
local rand    = require("openssl.rand")
local cipher  = require("openssl.cipher")
local pkey    = require("openssl.pkey")
local digest  = require("openssl.digest")
local pkcs12  = require("openssl.pkcs12")

local util = require("adobe.util.util")
local asn1 = require("adobe.util.asn1")

-- DEVICE KEY
crypto.deviceKey = {}

function crypto.deviceKey.new()
    local key = {}
    local meta = { __index = crypto.deviceKey }
    setmetatable(key, meta)
    key.key = rand.bytes(16)
    return key
end

function crypto.deviceKey:encrypt(data)
    local aes = cipher.new("AES-128-CBC")
    local iv = rand.bytes(16)
    local encrypted, err = aes:encrypt(self.key, iv, data)
    if err ~= nil then error(err) end
    return iv .. encrypted
end

function crypto.deviceKey:decrypt(data)
    local aes = cipher.new("AES-128-CBC")
    local iv = data:sub(1, 16)
    local encrypted = data:sub(17)
    local decrypted, err = aes:decrypt(self.key, iv, encrypted)
    if err ~= nil then error(err) end
    return decrypted
end

-- SPECIFIC HELPERS
-- encrypt a username, password, and device key using a certificate
function crypto.encryptLogin(username, password, deviceKey, authCert)
    -- construct buffer (devicekey + len(username) + username + len(password) + password)
    local buffer = deviceKey.key
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

-- creates a random serial
-- TODO: make this a real serial
function crypto.serial()
    local rand = rand.bytes(20)
    local serial = ""
    for i = 1, 20 do
        serial = serial .. string.format("%02x", rand:byte(i))
    end
    return serial
end

-- creates a random 12 bytes, then encodes it with base64
-- note: some other implementations use a Gregorian timestamp (in ms)
--     for the first 8 bytes, and then a counter for the last 4 bytes
function crypto.nonce()
    return util.base64.encode(rand.bytes(12))
end

-- base64(sha1(serial + deviceKey))
function crypto.fingerprint(serial, deviceKey)
    local sha1 = digest.new("SHA1")
    sha1:update(serial .. deviceKey.key)
    return util.base64.encode(sha1:final())
end


-- RSA KEYS
crypto.key = {}

function crypto.key.new(k)
    local key = nil
    if k ~= nil then
        key = pkey.new(k)
    else
        key, err = pkey.new({
            type = 'RSA',
            bits = 1025,
            exp = 65537
        })
        if err ~= nil then error(err) end
    end

    local wrapped = {
        pkey = key
    }
    local meta = { __index = crypto.key }
    setmetatable(wrapped, meta)
    return wrapped
end

-- exports the private key to PEM, then strips headers and base64 decodes
-- for some reason that makes it PKCS#8, whereas directly using DER is not...
function crypto.key:topkcs8()
    local pem = self.pkey:tostring("private", "PEM")
    -- strip headers, need the % to escape the dash
    local pkcs8 = pem:gsub("%-%-%-%-%-BEGIN PRIVATE KEY%-%-%-%-%-", ""):gsub("%-%-%-%-%-END PRIVATE KEY%-%-%-%-%-", "")
    return util.base64.decode(pkcs8)
end

local function xmlconcat(tb)
    local c = ""
    for k, v in pairs(tb) do
        if k ~= "_attr" then
            if type(v) == "table" then
                c = c .. previewXML(k, xmlconcat(v), "adobe")
            else
                c = c .. previewXML(k, v, "adobe")
            end
        end
    end
    return c
end

function crypto.parsePkcs12(pk, pass)
    local pk = util.base64.decode(pk)
    local decoded, err = pkcs12.decode(pk, pass)
    if err ~= nil then error(err) end
    print("Decoded PKCS#12: " .. decoded.friendly_name)
    return decoded.key, decoded.cert
end

local function sign(key, data)
    local sig, err = key:sign_raw(data, pkey.PADDINGS.RSA_PKCS1_PADDING)
    if err ~= nil then error(err) end
    return util.base64.encode(sig)
end

function crypto.signXML(key, tb, name)
    --print(util.base64.encode(asn1.element(name, tb)))
    local encoded = asn1.element(name, tb)
    -- generate sha1 hash of the encoded xml
    local sha1 = digest.new("SHA1")
    sha1:update(data)
    local hash = sha1:final()
    print("HASH: " .. util.base64.encode(hash))
    --local msg = pad_PKCS1(data, 128)
    --print(util.base64.encode(msg))
    return sign(key, hash)
    --print("SIGNING:")
    --print(xmlconcat(tb))
    --print("END SIGNING")
    --local signature, err = key.pkey:sign(digest, "SHA1")
    --if err ~= nil then error(err) end
    --return util.base64.encode(signature)
    --return "TODO"
end
return crypto
