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

function adobe.signIn(method, username, password)
    local authCert = adobe.getAuthenticationServiceInfo().certificate

    local deviceKey = crypto.generateDeviceKey()

    local authKey = crypto.generateKey(deviceKey)
    local licenseKey = crypto.generateKey(deviceKey)

    print(base64.encode(authKey.private))
    local login = crypto.encryptLogin(username, password, deviceKey, authCert)
    local signInRequest = xml.adobe({
        _attr = { method = method},
        signInData = login,
        publicAuthKey = base64.encode(authKey.public),
        encryptedPrivateAuthKey = base64.encode(authKey.encrypted),
        publicLicenseKey = base64.encode(licenseKey.public),
        encryptedPrivateLicenseKey = base64.encode(licenseKey.encrypted)
    }, "signIn")
    print(signInRequest)

    -- send POST with type application/vnd.adobe.adept+xml
    headers = {}
    headers["Content-Type"] = "application/vnd.adobe.adept+xml"
    headers["Accept"] = "*/*"
    headers["User-Agent"] = "book2png"

    local resp = {}
    http.request{
        url = url.build(util.endpoint(adobe.EDEN_URL, "SignInDirect")),
        sink = ltn12.sink.table(resp),
        method = "POST",
        headers = headers,
        source = ltn12.source.string(signInRequest)
    }
    
    --local response = http.request(url.build(util.endpoint(adobe.EDEN_URL, "SignInDirect")), "POST", signInRequest, headers)
    print(resp[1])
    --print(signInRequest)
end

return adobe