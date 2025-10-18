print("--------------------成功注入，正在加载中--------------------")
local function load(url) return loadstring(game:HttpGet(url))() end
local OrionLib = load('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua')
local baseUrl = "https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/"
local PlaceTable = load(baseUrl .. "PlaceIdTable.lua")

local Game,Place
Game = PlaceTable[game.GameId]
if Game then Place = Game.PlaceId[game.PlaceId] end

if not Game or not Place then OrionLib:MakeNotification({Name = "不支持此地点",Content = "请使用其他中心",Time = 5}) return end
OrionLib:MakeNotification({
    Name = "加载中...",
    Content = "可能会有短暂卡顿",
    Time = 5
})
load(baseUrl .. "Place-Scripts/" .. Game.Folder .. '/' .. Place .. ".lua") -- 加载链接