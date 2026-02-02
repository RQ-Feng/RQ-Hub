local StarterGui = game:GetService("StarterGui")
local function VanillaNotify(text,duration,icon)
    pcall(function(...)
        StarterGui:SetCore("SendNotification",{
            Title = "RQ-Hub",
            Text = text or '',
            Duration = duration or 5,
            Icon = icon,
            Button1 = '好'
        })
    end)
end
VanillaNotify('正在加载,请稍等...',5,'rbxassetid://7733715400')
baseUrl = "https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/refs/heads/main/Scripts/"
local PlaceTable = loadstring(game:HttpGet(baseUrl .. "PlaceTable.lua"))()

local GameId,PlaceId = game.GameId,game.PlaceId

local gameInfo = PlaceTable[GameId]
local placeInfo = gameInfo and (gameInfo.PlaceId['*'] or gameInfo.PlaceId[PlaceId])
--检查Place
if not gameInfo or not placeInfo then VanillaNotify('不支持此地点.'); return end

local LoadSuc,_ = pcall(function()
    local baseScriptURLs = {
        'https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua',
        'https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau',
        baseUrl .. 'baseHub_table.lua',
        baseUrl .. 'Utills/ExecutorChecker.lua'
    }
    local baseScripts = {}
    
    for i,url in ipairs(baseScriptURLs) do task.spawn(function() baseScripts[i] = game:HttpGet(url) end) end
    repeat task.wait() until #baseScripts == 4 --Waiting for scripts

    OrionLib = loadstring(baseScripts[1])()
    ESPLibrary = loadstring(baseScripts[2])()
    RQHub = loadstring(baseScripts[3])()
    ExecutorChecker = loadstring(baseScripts[4])()
end)

local checklist = {OrionLib,ESPLibrary,RQHub,ExecutorChecker}
if not LoadSuc or not checklist[4] then VanillaNotify('加载资源时遇到问题',10,'rbxassetid://7733658271'); return end

local GameFolder = 'RQHub\\' .. gameInfo.Folder
if not isfolder(GameFolder) then makefolder(GameFolder) end

local ScriptURLs = {
    baseUrl .. 'Utills/Init.lua',
    baseUrl .. "Places/" .. gameInfo.Folder .. '/' .. (placeInfo ~= '*' and placeInfo or 'General') .. ".lua",
    baseUrl .. 'Utills/EspSetting.lua',
}
local Scripts = {}

task.spawn(function()
    for _,url in ipairs(ScriptURLs) do table.insert(Scripts,game:HttpGet(url)) end --Load scripts from urls
end)

local Suffix = gameInfo.Folder .. (placeInfo ~= '*' and (' - ' .. placeInfo) or '')

Window = OrionLib:MakeWindow({
    IntroText = "RQHub-WIP",
    Name = 'RQHub | ' .. Suffix,
    SaveConfig = true,
    ConfigFolder = GameFolder .. (placeInfo ~= '*' and ('\\' .. placeInfo) or '')
})

repeat task.wait() until #Scripts == 3 --Waiting for scripts

for _,script in pairs(Scripts) do loadstring(script)() end

OrionLib:LoadConfig('RQHub-Default')