local util = {}

-- load required modules
local base642bin = require("ffi.sha2").base642bin
local bin2base64 = require("ffi.sha2").bin2base64

-- light wrappers for more consistent naming
util.base64 = {}
function util.base64.encode(string)
    return bin2base64(string)
end

function util.base64.decode(string)
    return base642bin(string)
end

-- shallow copy a table (why is this not built-in?)
function util.tableShallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

function util.endpoint(base, path)
    local endpoint = util.tableShallowCopy(base)
    endpoint.path = endpoint.path .. "/" .. path
    return endpoint
end

return util
