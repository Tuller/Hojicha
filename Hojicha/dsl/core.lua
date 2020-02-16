local AddonName, Addon = ...

local env = { }

function env.render(layout)
    local frames = {}

    -- grab all the frames we now have
    for i = 1, #layout do
        tinsert(frames, layout[i])
    end

    -- return the frames we generated
    return frames
end

function env.print(...)
    return Addon:Print(...)
end

function env.printf(...)
    return Addon:Printf(...)
end

Addon.Layout = setmetatable({}, {
    __index = function(self, k)
        return env[k]
    end,

    __newindex = function(self, k, v)
        if not(type(k) == "string" and type(v) == "function") then
            error(("Usage: %s.Layout[\"action\"] = function(info) ... end"):format(AddonName), 2)
        end

        if env[k] ~= nil then
            error(("Addon layout action %q has already been registered"):format(k), 2)
        end

        env[k] = v
    end,

    __call = function(self, addon, layout)
        local func
        if type(layout) == "string" then
            func = assert(loadstring("return render {\n" .. layout .. "\n}"))
        elseif type(layout) == "function" then
            func = layout
        else
            error(("Usage: %s:Layout(\"layout\" or \"func\")"):format(AddonName), 2)
        end

        setfenv(func, env)

        return func()
    end
})