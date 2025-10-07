print("--------------------成功注入，正在加载中--------------------")
local librepo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
local baseUrl = "https://raw.githubusercontent.com/C-Feng-dev/My-own-Script/refs/heads/LinoriaLib-Gui/Script/"

local function load(url)
    return loadstring(game:HttpGet(url))()
end

Library = load(librepo .. 'Library.lua')
ThemeManager = load(librepo .. 'addons/ThemeManager.lua')
SaveManager = load(librepo .. 'addons/SaveManager.lua')
ESPLibrary = load("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau")
local PlaceTable = load(baseUrl .. "GameTable.lua")

Options = Library.Options
Toggles = Library.Toggles

if not PlaceTable[game.GameId] or PlaceTable[game.GameId].Place[game.PlaceId] then
    game_not_support = true
end

local function ScriptPath(mid)
    if game_not_support then
        return "- " .. tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. mid .. "通用模式")
    else
        return PlaceTable[game.GameId].Folder .. mid .. PlaceTable[game.GameId].Place[game.PlaceId]
    end
end
Window = Library:CreateWindow({
    Title = "*CFHub* " .. ScriptPath(" - "),
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})
Library:Notify("加载中")
if game_not_support then
    load(baseUrl .. "Universal-Script/Universal.lua")
else
    load(baseUrl .. "Place-Script/" .. ScriptPath("/") .. ".lua")--加载链接
end
load(baseUrl .. "Universal-Script/UniversalTab.lua")
print("--------------------------加载完成--------------------------")