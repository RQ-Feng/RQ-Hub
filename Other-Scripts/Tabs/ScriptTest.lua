loadsuc, OrionLib = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/C-Feng-dev/Orion/refs/heads/main/main.lua'))()
end)
if loadsuc ~= true then
    warn("OrionLib加载错误,原因:" .. OrionLib)
    return
end