-- light wrapper around xml2lua, providing a simple interface

-- setup a non-global environment
local xml = {}
setmetatable(xml, {__index = _G})
setfenv(1, xml)

-- load required modules
local xml2lua = require("util.xml.xml2lua")
local treehandler = require("util.xml.xmlhandler.tree")

-- add an xml namespace to the table
function addNamespace(tb, prefix, namespace)
    tb._attr["xmlns:" .. prefix] = namespace
    local newtable = {}
    for k, v in pairs(tb) do
        if k ~= "_attr" then
            k = prefix .. ":" .. k
        end
        newtable[k] = v
    end
    return newtable
end

-- serialize a table into an XML string
function serialize(table, name)
    local name = name or ""
    return xml2lua.toXml(table, name)
end

-- add the xml version header to the string
function addHeader(string)
    return "<?xml version=\"1.0\"?>\n" .. string
end

-- deserialize an XML string into a table
function deserialize(string)
    local handler = treehandler:new()
    local parser = xml2lua.parser(handler)
    parser:parse(string)
    return handler.root
end

return xml
