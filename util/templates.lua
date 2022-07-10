-- setup a non-global environment
local templates = {}

-- load required modules
local xml = require("util.xml")

function templates.signInRequest(method, signInData, publicAuthKey, encryptedPrivateAuthKey, publicLicenseKey, encryptedPrivateLicenseKey)
    local tb = {
        _attr = { method = method},
        signInData = signInData,
        publicAuthKey = publicAuthKey,
        encryptedPrivateAuthKey = encryptedPrivateAuthKey,
        publicLicenseKey = publicLicenseKey,
        encryptedPrivateLicenseKey = encryptedPrivateLicenseKey
    }

    tb = xml.addNamespace(tb, "adept", "http://ns.adobe.com/adept")
    tb = xml.serialize(tb, "adept:signIn")
    tb = xml.addHeader(tb)

    return tb
end

return templates