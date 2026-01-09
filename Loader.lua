print("--------------------成功注入，正在加载中--------------------")
local baseUrl = "https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/refs/heads/main/Scripts/"
local PlaceTable = loadstring(game:HttpGet(baseUrl .. "PlaceTable.lua"))()

local GameId,PlaceId = game.GameId,game.PlaceId

local Game = PlaceTable[GameId]
local Place = Game and Game.PlaceId[PlaceId]
--检查Place
if not Game or not Place then game:GetService("StarterGui"):SetCore("SendNotification",{Title = "不支持此地点",Text = "请使用其他中心",Duration = 5}); return end

OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua'))()
ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
RQHub = loadstring(game:HttpGet(baseUrl .. 'baseHub_table.lua'))()
ExecutorChecker = loadstring(game:HttpGet(baseUrl .. 'Utills/ExecutorChecker.lua'))()--检测函数

local checklist = {OrionLib,ESPLibrary,RQHub,ExecutorChecker}; if not checklist[4] then 
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "RQHub",Text = "加载资源时遇到问题.",
        Duration = 10
    });return
end

OrionLib:MakeNotification({
    Name = "加载中",
    Content = "请稍等...",
    Time = 5
})

Window = OrionLib:MakeWindow({
    IntroText = "RQHub-WIP",
    Name = 'RQHub | '..Game.Folder..' - '..Place,
    SaveConfig = true,
    ConfigFolder = 'RQHub\\'..Game.Folder..'\\'..Place
})

loadstring(game:HttpGet(baseUrl .. 'Utills/Init.lua'))() --init
loadstring(game:HttpGet(baseUrl .. "Places/" .. Game.Folder .. '/' .. Place .. ".lua"))() -- 加载链接 
loadstring(game:HttpGet(baseUrl .. 'Utills/EspSetting.lua'))()-- Esp设置
loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/Other-scripts/Setting.lua'))()-- UI设置
OrionLib:LoadConfig('RQHub-Default')