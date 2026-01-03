local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService('Players')
local StarterGui = game:GetService("StarterGui")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService('UserInputService')
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local HumanoidRootPart = Character.HumanoidRootPart
local Humanoid = Character.Humanoid
local suc,finalDoor
local LatestRoom = ReplicatedStorage.GameData.LatestRoom
local MainUI = LocalPlayer.PlayerGui:WaitForChild('MainUI')
local Main_Game = MainUI.Initiator.Main_Game
local RemotesFolder = ReplicatedStorage.RemotesFolder

if RemotesFolder:FindFirstChild('ClimbLadder') then RemotesFolder.ClimbLadder:Destroy() end

repeat task.wait() until Character:GetAttribute('Climbing')

Character:SetAttribute('Climbing', false)

local function CurrentRoom()
    return workspace.CurrentRooms[LatestRoom.Value]
end

local function CurrentDoor()
    return CurrentRoom():WaitForChild('Door')
end

local function Prompt(prompt)
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 16
    repeat prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd() until CurrentRoom().Name == '30' or not prompt or not prompt.Enabled
end

task.spawn(function() --Player setter
    while Character:GetAttribute('Alive') do
        Main_Game.Camera.Enabled = false

        Humanoid.HipHeight = 0.1
        RemotesFolder.Crouch:FireServer(true)

        local Camera = workspace.CurrentCamera
        Camera.FieldOfView = 120
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.lookAt(HumanoidRootPart.CFrame.Position + Vector3.new(0, 8, 0),HumanoidRootPart.CFrame.Position - Vector3.new(0, 1, 0))

        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        task.wait()
    end
end)

task.spawn(function() --Fuck u USELESS COLLISION
    local Collision = Character:WaitForChild('Collision')
    local function NoClip()
        Collision.CollisionGroup = "PlayerCrouching"
        Collision.CollisionCrouch.CollisionGroup = "PlayerCrouching"
        Collision.CanCollide = false
        Collision.CollisionCrouch.CanCollide = false
        --CollisionPart.CanCollide = false
    end; NoClip()
    Collision:GetPropertyChangedSignal("CanCollide"):Connect(NoClip)
end)

task.spawn(function()
    repeat suc,finalDoor = pcall(function() return workspace.CurrentRooms["30"].RippleExitDoor.Hidden end); task.wait() until suc
    repeat finalDoor.CFrame = HumanoidRootPart.CFrame; task.wait() until not HumanoidRootPart
end)

while CurrentRoom().Name ~= '30' do
    task.wait()
    local Assets = CurrentRoom():WaitForChild('Assets')
    if Assets:WaitForChild('MinesGenerator',0.1) then
        local MinesGenerator = Assets.MinesGenerator
        for _,fuse in pairs(Assets:GetChildren()) do
            if fuse.Name ~= 'FuseObtain' then continue end
            HumanoidRootPart.CFrame = fuse:WaitForChild('Hitbox').CFrame
            Prompt(fuse.ModulePrompt)
        end
        HumanoidRootPart.CFrame = MinesGenerator.GeneratorMain.CFrame
        for _,intoFuse in pairs(MinesGenerator.Fuses:GetChildren()) do
            if intoFuse:FindFirstChild('FusesPrompt') and intoFuse.FusesPrompt.Enabled then Prompt(intoFuse.FusesPrompt) end
        end
        Prompt(MinesGenerator.Lever.LeverPrompt)
        HumanoidRootPart.CFrame = Assets.MinesGateButton.MainBase.CFrame
        Prompt(Assets.MinesGateButton.Button.ActivateEventPrompt)
    else HumanoidRootPart.CFrame = CurrentDoor():WaitForChild('Door').CFrame end
    CurrentDoor():WaitForChild('ClientOpen'):FireServer()
end