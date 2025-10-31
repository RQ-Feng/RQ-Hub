print("--------------------成功注入，正在加载中--------------------")
local function load(url) return loadstring(game:HttpGet(url))() end

OrionLib = load('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua')
ESPLibrary = load("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau")

local baseUrl = "https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/refs/heads/main/Scripts/"

local PlaceTable,Game,Place = load(baseUrl .. "PlaceTable.lua");
Game = PlaceTable[game.GameId]
if Game then Place = Game.PlaceId[game.PlaceId] end

if not Game or not Place then OrionLib:MakeNotification({Name = "不支持此地点",Content = "请使用其他中心",Time = 5}) return end

OrionLib:MakeNotification({
    Name = "加载中",
    Content = "请稍等...",
    Time = 5
})

load('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/Other-script/Setting.lua')-- UI设置
load(baseUrl .. "Places/" .. Game.Folder .. '/' .. Place .. ".lua") -- 加载链接 