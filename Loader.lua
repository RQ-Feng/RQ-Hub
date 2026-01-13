print("--------------------成功注入，正在加载中--------------------")
local baseUrl = "https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/refs/heads/main/Scripts/"
local PlaceTable = loadstring(game:HttpGet(baseUrl .. "PlaceTable.lua"))()

local StarterGui = game:GetService("StarterGui")
local function VanillaNotify(text,duration,icon)
    StarterGui:SetCore("SendNotification",{
        Title = "RQ-Hub",
        Text = text or '',
        Duration = duration or 5,
        Icon = icon
    })
end

local GameId,PlaceId = game.GameId,game.PlaceId

local Game = PlaceTable[GameId]
local Place = Game and Game.PlaceId[PlaceId]
--检查Place
if not Game or not Place then VanillaNotify('不支持此地点.'); return end

OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua'))()
ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
RQHub = loadstring(game:HttpGet(baseUrl .. 'baseHub_table.lua'))()
ExecutorChecker = loadstring(game:HttpGet(baseUrl .. 'Utills/ExecutorChecker.lua'))()--检测函数

local checklist = {OrionLib,ESPLibrary,RQHub,ExecutorChecker}
if not checklist[4] then VanillaNotify('加载资源时遇到问题',10,'rbxassetid://7733658271'); return end
VanillaNotify('正在加载,请稍等...',3,'rbxassetid://7733715400')

local GameFolder = 'RQHub\\'..Game.Folder
if not isfolder(GameFolder) then makefolder(GameFolder) end

local ScriptURLs = {
    baseUrl .. 'Utills/Init.lua',
    baseUrl .. "Places/" .. Game.Folder .. '/' .. Place .. ".lua",
    baseUrl .. 'Utills/EspSetting.lua',
    'https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/Other-scripts/Setting.lua'
}
local Scripts = {}

task.spawn(function()
    for _,url in ipairs(ScriptURLs) do table.insert(Scripts,game:HttpGet(url)) end --Load scripts from urls
end)

Window = OrionLib:MakeWindow({
    IntroText = "RQHub-WIP",
    Name = 'RQHub | '..Game.Folder..' - '..Place,
    SaveConfig = true,
    ConfigFolder = GameFolder..'\\'..Place
})

repeat task.wait() until #Scripts == 4 --Waiting for scripts

for _,script in pairs(Scripts) do loadstring(script)() end

OrionLib:LoadConfig('RQHub-Default')