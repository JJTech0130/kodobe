require("tools.set_paths")

describe("Authentication Service Info", function()
    it("should return the correct certificate", function()
        local adobe = require("adobe.adobe")
        local authInfo = adobe.getAuthenticationServiceInfo()
        assert.are.equal(authInfo.certificate, "MIIEYDCCA0igAwIBAgIER2q5eTANBgkqhkiG9w0BAQUFADCBhDELMAkGA1UEBhMCVVMxIzAhBgNVBAoTGkFkb2JlIFN5c3RlbXMgSW5jb3Jwb3JhdGVkMRswGQYDVQQLExJEaWdpdGFsIFB1Ymxpc2hpbmcxMzAxBgNVBAMTKkFkb2JlIENvbnRlbnQgU2VydmVyIENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0wODAxMDkxODQzNDNaFw0xODAxMzEwODAwMDBaMHwxKzApBgNVBAMTImh0dHA6Ly9hZGVhY3RpdmF0ZS5hZG9iZS5jb20vYWRlcHQxGzAZBgNVBAsTEkRpZ2l0YWwgUHVibGlzaGluZzEjMCEGA1UEChMaQWRvYmUgU3lzdGVtcyBJbmNvcnBvcmF0ZWQxCzAJBgNVBAYTAlVTMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDZAxpzOZ7N38ZGlQjfMY/lfu4Ta4xK3FRm069VwdqGZIwrfTTRxnLE4A9i1X00BnNk/5z7C0pQX435ylIEQPxIFBKTH+ip5rfDNh/Iu6cIlB0N4I/t7Pac8cIDwbc9HxcGTvXg3BFqPjaGVbmVZmoUtSVOsphdA43sZc6j1iFfOQIDAQABo4IBYzCCAV8wEgYDVR0TAQH/BAgwBgEB/wIBATAUBgNVHSUEDTALBgkqhkiG9y8CAQUwgbIGA1UdIASBqjCBpzCBpAYJKoZIhvcvAQIDMIGWMIGTBggrBgEFBQcCAjCBhhqBg1lvdSBhcmUgbm90IHBlcm1pdHRlZCB0byB1c2UgdGhpcyBMaWNlbnNlIENlcnRpZmljYXRlIGV4Y2VwdCBhcyBwZXJtaXR0ZWQgYnkgdGhlIGxpY2Vuc2UgYWdyZWVtZW50IGFjY29tcGFueWluZyB0aGUgQWRvYmUgc29mdHdhcmUuMDEGA1UdHwQqMCgwJqAkoCKGIGh0dHA6Ly9jcmwuYWRvYmUuY29tL2Fkb2JlQ1MuY3JsMAsGA1UdDwQEAwIBBjAfBgNVHSMEGDAWgBSL7vCBYMmi2h4OUsFYDASwQ/eP6DAdBgNVHQ4EFgQU9RP19K+lzF03he+0T47hCVkPhdAwDQYJKoZIhvcNAQEFBQADggEBAJoqOj+bUa+bDYyOSljs6SVzWH2BN2ylIeZKpTQYEo7jA62tRqW/rBZcNIgCudFvEYa7vH8lHhvQak1s95g+NaNidb5tpgbS8Q7/XTyEGS/4Q2HYWHD/8ydKFROGbMhfxpdJgkgn21mb7dbsfq5AZVGS3M4PP1xrMDYm50+Sip9QIm1RJuSaKivDa/piA5p8/cv6w44YBefLzGUN674Y7WS5u656MjdyJsN/7Oup+12fHGiye5QS5mToujGd6LpU80gfhNxhrphASiEBYQ/BUhWjHkSi0j4WOiGvGpT1Xvntcj0rf6XV6lNrOddOYUL+KdC1uDIe8PUI+naKI+nWgrs=")
    end)

    it("should have the anonymous login method", function()
        local adobe = require("adobe.adobe")
        local authInfo = adobe.getAuthenticationServiceInfo()
        local hasAnonymous = false
        for _, method in ipairs(authInfo.methods) do
            if method.name == "anonymous" then
                hasAnonymous = true
            end
        end
        assert.is_true(hasAnonymous)
    end)
end)