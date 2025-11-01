print("--------------------成功注入，正在加载中--------------------")
local function load(url) return loadstring(game:HttpGet(url))() end 

local baseUrl = "https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/refs/heads/main/Scripts/"

local PlaceTable,Game,Place = load(baseUrl .. "PlaceTable.lua");
Game = PlaceTable[game.GameId]
if Game then Place = Game.PlaceId[game.PlaceId] end

if not Game or not Place then game:GetService("StarterGui"):SetCore("SendNotification",{Title = "不支持此地点",Text = "请使用其他中心",Duration = 5}) return end
--Check place done
OrionLib = load('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua')
ESPLibrary = load("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau")
if not OrionLib then return end
OrionLib:MakeNotification({
    Name = "加载中",
    Content = "请稍等...",
    Time = 5
})

RQHub = {
    ['ESPSetting'] = {
        ['Color'] = Color3.new(),
        ['TextSize'] = 17
    }
}

load(baseUrl .. 'Others/Init.lua')--init
load(baseUrl .. 'Others/EspSetting.lua')-- Esp设置
load('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/Other-scripts/Setting.lua')-- UI设置

checklist = {}; workfunc,failfunc = load(baseUrl .. 'Others/Checker.lua'); checklist = nil--check functions

load(baseUrl .. "Places/" .. Game.Folder .. '/' .. Place .. ".lua") -- 加载链接 