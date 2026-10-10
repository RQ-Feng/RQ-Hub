local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local FireToolProjectile = ReplicatedStorage:WaitForChild("RemotesFolder"):WaitForChild("FireToolProjectile")
local v2 = require(ReplicatedStorage:WaitForChild("ProjectileData"))

-- ============ Notify（来自你文件，原样套用） ============
local function Notify(Text, Duration, ButtonsCfg)
    local cfgTable = {
        Title = 'Doors PaperPlane Dupe',
        Text = Text,
        Duration = Duration or 5
    }

    if ButtonsCfg then
        if type(ButtonsCfg) ~= 'table' then return end
        cfgTable['Callback'] = Instance.new('BindableFunction')
        cfgTable['Button1'] = ButtonsCfg['Button1']
        cfgTable['Button2'] = ButtonsCfg['Button2']
        if type(ButtonsCfg['Callback']) ~= 'function' then return end
        cfgTable['Callback'].OnInvoke = (ButtonsCfg['Callback'])
    end

    StarterGui:SetCore('SendNotification', cfgTable)
end

-- ============ SetVisible（内联自 module） ============
local function SetVisible(Parent, visible)
    local v4 = if visible then 0 else 1
    Parent.Handle.Transparency = v4
    for _, v6 in Parent.Handle:GetDescendants() do
        if v6:IsA("BasePart") or v6:IsA("Decal") or v6:IsA("Texture") then
            v6.Transparency = v4
        elseif v6:IsA("ParticleEmitter") or v6:IsA("Light") then
            v6.Enabled = visible
        end
    end
end

-- ============ 内联的 Fire()（移植自 module.fire） ============
local function Fire()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Parent = Character:FindFirstChild("PaperPlane")
    if not Parent then return end

    Parent:WaitForChild("Remote"):FireServer()

    local ProjectileType = Parent:GetAttribute("ProjectileType")
    local v8 = v2[ProjectileType]

    local v9 = (
        Parent:FindFirstChild("BigProp")
        and Parent:FindFirstChild("BigProp").PrimaryPart
        and Parent:FindFirstChild("BigProp").PrimaryPart.Position
        or Parent.Handle.Position
    ) + Vector3.new(0, 1, 0) + Character.PrimaryPart.CFrame.LookVector * -0.75

    local v10 = workspace.CurrentCamera.CFrame.LookVector * 1
    local v11 = v10 * (v8.Speed or 100) + Character.PrimaryPart.Velocity
    print(ProjectileType, PropType, v9, v10, v11)
    
    FireToolProjectile:Fire(ProjectileType, nil, v9, v10, v11)

    SetVisible(Parent, false)

    local ToolProp = Parent:FindFirstChild("ToolProp")
    if ToolProp then
        ToolProp:Destroy()
    end
end

-- ============ 循环 dupe ============
local Running = true

local function dupePlane()
    while Running do
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local tool = char:WaitForChild("PaperPlane")

        char.PaperPlane.RemoteInspect:FireServer()
        Fire()
        ReplicatedStorage.RemotesFolder.DropItem:FireServer(tool)
        task.wait(1)

        repeat task.wait() until char:FindFirstChild('PaperPlane') or not Running
    end
end

-- ============ 默认直接开始 ============
Notify('运行中，点击停止结束', math.huge, {
    Button1 = '停止',
    Callback = function(choice)
        Running = false
        Notify('已停止', 3)
    end
})

task.spawn(function()
    local ok, err = pcall(dupePlane)
    if not ok then warn('dupePlane error:', err) end
end)