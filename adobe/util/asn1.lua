--- @module encodes table as ASN.1 DER

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
    return util.ASN.bytes(
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
    local ns = string.match(attribute, "^[^:]+")
    local tag = string.match(attribute, "[^:]+$")
    if ns == tag then
        ns = ""
    end
    return ASN.namespacedTag(ns, tag)
end

function ASN.attribute(name, value)
    out = ASN.byte(ASN.ATTRIBUTE) .. ASN.tag(name) .. ASN.string(value)
end

function ASN.element(name, content)
    out = ""
    out = out .. ASN.byte(ASN.BEGIN_ELEMENT)
    out = out .. ASN.tag(name)
    if content._attr ~= nil then
        -- FIXME: sort attributes
        for k, v in pairs(content._attr) do
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
        for k, v in pairs(content) do
            out = out .. ASN.element(k, v)
        end
    end

    out = out .. ASN.byte(ASN.END_ELEMENT)
    
    return out
end

return ASN
