--- @module encodes table as ASN.1 DER
-- this module is intended to be self-contained, so it does not depend on any other modules
-- unfortunately, it has to depend on LuaJIT's bitop module, which is not available on all platforms


-- sorting stuff
local function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

local function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

-- actual asn1 stuff

local bit = require("bit")

local ASN = {
    NONE = 0,
    TEXT_NODE = 4, -- TEXT
    ATTRIBUTE = 5, -- ATTRIBUTE
    END_ATTRIBUTES = 2, -- CHILD
    BEGIN_ELEMENT = 1, -- NS_TAG
    END_ELEMENT = 3 -- END_TAG
}

function ASN.byte(byte)
    return string.char(byte)
end

function ASN.bytes(bytes)
    out = ""
    for i, byte in ipairs(bytes) do
        out = out .. ASN.byte(byte)
    end
    return out
end

function ASN.string(str)
    local length = string.len(str)
    return ASN.bytes(
        {
            math.floor(length / 256), -- upper length byte
            bit.band(length, 0xFF) -- lower length byte
        }
    ) .. str -- contents of string
end

function ASN.namespacedTag(namespace, name)
    return ASN.string(namespace) .. ASN.string(name)
end

function ASN.tag(name)
    -- FIXME: does not work when http: is after the namespace, e.g. for xmlns:http://
    local ns, tag = string.match(name, "(.+):(.+)")
    -- there was no colon, so we just have a tag
    if ns == nil and tag == nil then
        ns = ""
        tag = name
    end
    return ASN.namespacedTag(ns, tag)
end

function ASN.attribute(name, value)
    -- don't add xmlns attributes, as namespaces are fully qualified
    if string.find(name, "xmlns:") then
        return ""
    end
    return ASN.byte(ASN.ATTRIBUTE) .. ASN.tag(name) .. ASN.string(value)
end

function ASN.element(name, content)
    out = ""
    out = out .. ASN.byte(ASN.BEGIN_ELEMENT)
    out = out .. ASN.tag(name)
    if content._attr ~= nil then
        -- FIXME: sort attributes
        for k, v in orderedPairs(content._attr) do
            out = out .. ASN.attribute(k, v)
        end
        content._attr = nil
    end
    out = out .. ASN.byte(ASN.END_ATTRIBUTES)
    
    -- FIXME: how does it work if we have attributes, but are a text node?
    if type(content) == 'string' then
        -- FIXME: support greater than 32k (chunking)
        out = out .. ASN.byte(ASN.TEXT_NODE)
        out = out .. ASN.string(content)
    elseif type(content) == 'table' then
        -- FIXME: sort elements
        for k, v in orderedPairs(content) do
            out = out .. ASN.element(k, v)
        end
    end

    out = out .. ASN.byte(ASN.END_ELEMENT)
    
    return out
end

return ASN
