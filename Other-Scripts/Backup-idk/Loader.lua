print("--------------------成功注入，正在加载中--------------------")
local baseUrl = "https://raw.githubusercontent.com/C-Feng-dev/My-own-Script/refs/heads/main/Script/"
--local librepo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/' 
local function load(url)
    return loadstring(game:HttpGet(url))()
end
--[[local Library = load(librepo .. 'Library.lua')
local ThemeManager = load(librepo .. 'addons/ThemeManager.lua')
local SaveManager = load(librepo .. 'addons/SaveManager.lua')]]
local PlaceTable = load(baseUrl .. "GameTable.lua")
local ScriptPath = PlaceTable[game.GameId].Folder .. "/" .. PlaceTable[game.GameId].Place[game.PlaceId]
local suc,err = pcall(function()
    return load(baseUrl .. "Place-Scripts/" .. ScriptPath .. ".lua")
end)
if suc == false then
    warn("尝试加载对应外挂时出现错误,报错为:" .. err .. ",已尝试加载中心")
    load(baseUrl .. "Tab/Hub.lua")
end