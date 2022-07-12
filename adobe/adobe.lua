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
    --print(resp)
    resp = xml.deserialize(resp)

    if resp.error ~= nil then
        error("Server returned error: " .. resp.error._attr.data)
    elseif resp.credentials == nil then
        error("Server returned unexpected response")
        print(resp)
    end
    
    if deviceKey:decrypt(base64.decode(resp.credentials.encryptedPrivateLicenseKey )) ~= licenseKey:topkcs8() then
        -- this account has already been signed into
        print("WARNING: License key from server does not match ours, replacing our key")
        local lk, err = crypto.key.new(deviceKey:decrypt(base64.decode(resp.credentials.encryptedPrivateLicenseKey )))
        if err ~= nil then error(err) end
        licenseKey = lk
    end

    return { 
        -- generated
        deviceKey = deviceKey, 
        authKey = authKey, 
        licenseKey = licenseKey,
        -- received 
        licenseCert = resp.credentials.licenseCertificate, 
        user = resp.credentials.user, 
        username = resp.credentials.username[1],
        pkcs12 = resp.credentials.pkcs12
    }
end

function adobe.activate(user, deviceKey, pkcs12)
    local serial = crypto.serial()
    local fingerprint = crypto.fingerprint(serial, deviceKey)
    local pkey, cert = crypto.parsePkcs12(pkcs12, util.base64.encode(deviceKey.key))

    local activationRequest = xml.adobeSigned({
        _attr = { requestType = "Initial"},
        fingerprint = fingerprint,
        deviceType = "standalone",
        clientOS = "Windows 8", -- TODO: make this configurable
        clientLocale = "en",
        clientVersion = "2.0.1.78765", -- TODO: make this configurable
        targetDevice = {
            softwareVersion = "9.3.58046",
            clientOS = "Windows 8", -- TODO: make this configurable
            clientLocale = "en",
            clientVersion = "2.0.1.78765", -- TODO: make this configurable
            deviceType = "standalone",
            productName = "ADOBE Digitial Editions", -- [sic] Yes, the real ADE misspells Digital...
            fingerprint = fingerprint,
        },
        nonce = crypto.nonce(),
        expiration = util.expiration(10), -- 10 minutes
        user = user
    }, "activate", pkey)

    print(activationRequest)

    -- local resp = {}
    -- http.request{
    --     url = url.build(util.endpoint(adobe.EDEN_URL, "ActivateDirect")),
    --     sink = ltn12.sink.table(resp),
    --     method = "POST",
    --     headers = { ["Content-Type"] = "application/vnd.adobe.adept+xml" },
    --     source = ltn12.source.string(activationRequest)
    -- }
    -- resp = table.concat(resp)
    -- --print(resp)
    -- resp = xml.deserialize(resp)
    -- 
    -- if resp.error ~= nil then
    --     error("Server returned error: " .. resp.error._attr.data)
    -- elseif resp.credentials == nil then
    --     error("Server returned unexpected response")
    --     print(resp)
    -- end
end
return adobe