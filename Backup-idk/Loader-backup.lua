print("--------------------成功注入，正在加载中--------------------")
baseUrl = "https://raw.githubusercontent.com/C-Feng-dev/My-own-Script/refs/heads/main/Script/"
function load(url)
    loadstring(game:HttpGet(url))()
end
if game.PlaceId == 12411473842 then 
    load(baseUrl .. "Place-Script/Pressure/Pressure-Lobby.lua")
elseif game.PlaceId == 17355897213 then
    load(baseUrl .. "Place-Script/Pressure/Pressure-The%20Raveyard.lua")
elseif game.PlaceId == 12552538292 then
    load(baseUrl .. "Place-Script/Pressure/Pressure.lua")
else
    suc,err = pcall(function()
        return load(baseUrl .. "Place-Script/" .. game.PlaceId .. ".lua")
    end)
    if suc == false then
        warn("注入时出现错误,报错为:" .. err .. ",已加载中心")
        load(baseUrl .. "Tab/Hub.lua")
    end
end