local adobe = {}

-- load required modules
local http   = require("socket.http")       -- HTTP(S)
local url    = require("socket.url")        -- URL manipulation
local util   = require("adobe.util.util")   -- basic utility functions
local crypto = require("adobe.util.crypto") -- crypto helper
local xml    = require("adobe.util.xml")    -- xml helper
local base64 = require("adobe.util.util").base64
local ltn12  = require("ltn12")             -- HTTP(S) request/response

-- Eden2 activation service 
adobe.EDEN_URL = url.parse("https://adeactivate.adobe.com/adept")

-- get information about the authentication service
function adobe.getAuthenticationServiceInfo()
    local response = http.request(url.build(util.endpoint(adobe.EDEN_URL, "AuthenticationServiceInfo")))
    local info = xml.deserialize(response).authenticationServiceInfo

    -- parse the methods into a nicer table
    local raw = info.signInMethods.signInMethod
    local methods = {}
    for i, m in ipairs(raw) do
        methods[i] = {
            name = m[1],
            method = m._attr.method,
        }
    end
    return { certificate = info.certificate, methods = methods }
end

-- get the activation service certificate
function adobe.getActivationServiceCertificate()
    local response = http.request(url.build(util.endpoint(adobe.EDEN_URL, "ActivationServiceInfo")))
    local info = xml.deserialize(response).activationServiceInfo   

    return info.certificate
end

function adobe.signIn(method, username, password, authCert)
    local deviceKey = crypto.deviceKey.new()

    local authKey = crypto.key.new()
    local licenseKey = crypto.key.new()

    local login = crypto.encryptLogin(username, password, deviceKey, authCert)
    local signInRequest = xml.adobe({
        _attr = { method = method},
        signInData = login,
        publicAuthKey = base64.encode(authKey.pkey:tostring("public", "DER")),
        encryptedPrivateAuthKey = base64.encode(deviceKey:encrypt(authKey:topkcs8())),
        publicLicenseKey = base64.encode(licenseKey.pkey:tostring("public", "DER")),
        encryptedPrivateLicenseKey = base64.encode(deviceKey:encrypt(licenseKey:topkcs8()))
    }, "signIn")

    local resp = {}
    http.request{
        url = url.build(util.endpoint(adobe.EDEN_URL, "SignInDirect")),
        sink = ltn12.sink.table(resp),
        method = "POST",
        headers = { ["Content-Type"] = "application/vnd.adobe.adept+xml" },
        source = ltn12.source.string(signInRequest)
    }
    resp = table.concat(resp)
    print(resp)
    resp = xml.deserialize(resp)
    
    if deviceKey:decrypt(base64.decode(resp.credentials.encryptedPrivateLicenseKey )) ~= licenseKey:topkcs8() then
        -- this account has already been signed into
        print("WARNING: License key from server does not match ours, replacing our key")
        licenseKey, err = crypto.key.new(deviceKey:decrypt(base64.decode(resp.credentials.encryptedPrivateLicenseKey )))
        if err ~= nil then error(err) end
    end
    return { deviceKey = deviceKey, authKey = authKey, licenseKey = licenseKey }
end

return adobe