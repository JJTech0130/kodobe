local env = {}

-- setup a non-global environment
-- this only works in Lua 5.1/LuaJIT
function env.setupEnv()
    local env = {}
    setmetatable(env, {__index = _G})
    setfenv(2, env)
    return env
end

return env