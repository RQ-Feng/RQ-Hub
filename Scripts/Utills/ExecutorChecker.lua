local ExecutorChecker = {}
local ExecutorCheckerInfo = {}

local executorName = string.split(identifyexecutor() or "None", " ")[1]
local brokenFeatures = {
    ["Arceus"] = { "require" },
    ["Codex"] = { "require" },
    ["VegaX"] = { "require" },
    ["Solara"] = { "require" },
    ["Xeno"] = { "require" }
}

function test(name: string, func,shouldCallback: boolean)
    if typeof(brokenFeatures[executorName]) == "table" and table.find(brokenFeatures[executorName], name) then return false end -- garbage executor 🤯
    
    local success, errorMessage = false, nil
    if shouldCallback ~= false then success, errorMessage = pcall(func)
    else success = typeof(func) == "function" end
    
    ExecutorCheckerInfo[name] = string.format("%s [%s]%s", (if success then "✅" else "❌"), name, (if errorMessage then (": " .. tostring(errorMessage)) else ""))
    ExecutorChecker[name] = success
    return success
end

test("getrenv", getrenv, false)
test("queue_on_teleport", queue_on_teleport, false)
test("replicatesignal", replicatesignal, false)
test("getcallingscript", getcallingscript, false)

test("require", function()
    require(game.Players.LocalPlayer:WaitForChild("PlayerScripts", math.huge):WaitForChild("PlayerModule", 5))
end)
test("hookmetamethod", function()
    local object = setmetatable({}, { __index = newcclosure(function() return false end), __metatable = "Locked!" })
    local ref = hookmetamethod(object, "__index", function() return true end)
    assert(object.test == true, "Failed to hook a metamethod and change the return value")
    assert(ref() == false, "Did not return the original function")
end)
test("getnamecallmethod", function()
    pcall(function()
        game:NAMECALL_METHODS_ARE_IMPORTANT()
    end)

    assert(getnamecallmethod() == "NAMECALL_METHODS_ARE_IMPORTANT", "getnamecallmethod did not return the real namecall method")
end)
test("hookfunction", function()
    local function test()
		return true
	end
	local ref = hookfunction(test, function()
		return false
	end)
	assert(test() == false, "Function should return false")
	assert(ref() == true, "Original function should return true")
	assert(test ~= ref, "Original function should not be same as the reference")
end)
test("firesignal", function()
    local event = Instance.new("BindableEvent")
    local fired = false

    event.Event:Once(function(value) fired = value end)
        
    firesignal(event.Event, true)
    task.wait(0.1)
    event:Destroy()

    assert(fired, "Failed to fire a BindableEvent")
end)
test("fireproximityprompt", function()
    local prompt = Instance.new("ProximityPrompt", Instance.new("Part",orkspace))
    local triggered = false

    prompt.Triggered:Once(function() triggered = true end)

    fireproximityprompt(prompt)
    task.wait(0.1)

    prompt.Parent:Destroy()
    assert(triggered, "Failed to fire proximity prompt")
end)

--// Load \\--
ExecutorChecker["_ExecutorName"] = executorName

for name, result in pairs(ExecutorChecker) do
    if ExecutorCheckerInfo[name] then 
        print(ExecutorCheckerInfo[name]) 
    elseif name:gsub("_", "") ~= name then
        print("🛠️ [" .. tostring(name) .. "]", tostring(result))
    else
        print("❓ [" .. tostring(name) .. "]", tostring(result))
    end
end

return ExecutorChecker