-- Setup a non-global environment
local util = {}
setmetatable(util, {__index = _G})
setfenv(1, util)

-- load required modules
local base642bin = require("ffi.sha2").base642bin
local bin2base64 = require("ffi.sha2").bin2base64

-- light wrappers for more consistent naming
base64 = {}
function base64.encode(string)
    return bin2base64(string)
end

function base64.decode(string)
    return base642bin(string)
end

-- Shallow copy a table (why is this not built-in?)
function tableShallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

return util
