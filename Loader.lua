print("--------------------成功注入，正在加载中--------------------")
local function load(url) return loadstring(game:HttpGet(url))() end
local OrionLib = load('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua')
local baseUrl = "https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/refs/heads/main/"
local PlaceTable = load(baseUrl .. "PlaceTable.lua")

local GameId,PlaceId
GameId = PlaceTable[game.GameId]
if GameId then PlaceId = GameId.PlaceId[game.PlaceId] end

if not GameId or not PlaceId then OrionLib:MakeNotification({Name = "不支持此地点",Content = "请使用其他中心",Time = 5}) return end
OrionLib:MakeNotification({
    Name = "加载中",
    Content = "请稍等...",
    Time = 5
})
load('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/Other-script/Setting.lua')-- UI设置
load(baseUrl .. "Place-Scripts/" .. GameId.Folder .. '/' .. PlaceId .. ".lua") -- 加载链接 