print("--------------------成功注入，正在加载中--------------------")
local function load(url,value) 
    print(url)
    local cache;task.spawn(function() cache = loadstring(game:HttpGet(url))() end) 
    repeat task.wait() until cache
    if value then value = true end
    return cache
end

local baseUrl = "https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/refs/heads/main/Scripts/"

local PlaceTable,Game,Place = loadstring(game:HttpGet(baseUrl .. "PlaceTable.lua"))()
Game = PlaceTable[game.GameId]
if Game then Place = Game.PlaceId[game.PlaceId] end

if not Game or not Place then game:GetService("StarterGui"):SetCore("SendNotification",{Title = "不支持此地点",Text = "请使用其他中心",Duration = 5}) return end
--Check place done
OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua'))()
ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
if not OrionLib then warn('OrionLib isn\'t loaded!') return end

RQHub = {
    ['Loaded'] = false,
    ['ESPSetting'] = {
        ['Color'] = Color3.new(),
        ['TextSize'] = 17
    }
}

loadstring(game:HttpGet(baseUrl .. 'Others/Init.lua'))() --init

checklist = {}; workfunc,failfunc = loadstring(game:HttpGet(baseUrl .. 'Others/Checker.lua'))(); checklist = nil--检测函数

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

loadstring(game:HttpGet("https://raw.githubusercontent.com/RQ-Feng/RQ-Hub/refs/heads/MoveWindow/Scripts/Places/" .. Game.Folder .. '/' .. Place .. ".lua"))() -- 加载链接 
loadstring(game:HttpGet(baseUrl .. 'Others/EspSetting.lua'))()-- Esp设置
loadstring(game:HttpGet('https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/Other-scripts/Setting.lua'))()-- UI设置