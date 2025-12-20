local PathfindingService = game:GetService('PathfindingService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local Character = player.Character
local Humanoid = Character.Humanoid
local HumanoidRootPart = Character.HumanoidRootPart

local GameData = ReplicatedStorage:WaitForChild("GameData")

local function GetFolder(name,parent)
    local Parent = parent or workspace; name = tostring(name)
    local folder = Parent:FindFirstChild('pathFinding')
    if not folder then
         folder = Instance.new('Folder',Parent)
         folder.Name = name
    end
    return folder
end

local pathFinding = GetFolder('pathFinding')
local nodes = GetFolder('nodes',pathFinding)
local block = GetFolder('block',pathFinding)

local function LatestRoom()
    return GameData.LatestRoom.Value
end

local function CurrentRoom()
    return workspace.CurrentRooms[LatestRoom()]
end

local pathfindingGoal = workspace.CurrentRooms["0"].Assets.BufferStop.PrimaryPart

local function test(value)
    Character:SetAttribute('SpeedBoost',5)
    local hasResetFailsafe = false

    local function moveToCleanup()
        if Humanoid then
            Humanoid:Move(HumanoidRootPart.Position)
            Humanoid.WalkToPart = nil
            Humanoid.WalkToPoint = HumanoidRootPart.Position
        end
        nodes:ClearAllChildren()
        block:ClearAllChildren()
        hasResetFailsafe = true
    end

    local lastRoomValue = 0

    local function createNewBlockedPoint(point: PathWaypoint)
        local block = Instance.new("Part", block)
        local pathMod = Instance.new("PathfindingModifier", block)
        pathMod.Label = "_ms_pathBlock"

        block.Name = "_mspaint_blocked_path"
        block.Shape = Enum.PartType.Block

        local sizeY = 10
        
        block.Size = Vector3.new(1, sizeY, 1)
        block.Color = Color3.fromRGB(255, 130, 30)
        block.Material = Enum.Material.Neon
        block.Position = point.Position + Vector3.new(0, sizeY / 2, 0)
        block.Anchored = true
        block.CanCollide = false
        block.Transparency = 0.9
    end

    local function AutoPathToLoot(Loot)
        if not Loot:IsA('Model') then return end
        local path = PathfindingService:CreatePath({
            AgentCanJump = false,
            AgentCanClimb = false,
            WaypointSpacing = 2,
            AgentRadius = 1,
            Costs = {_ms_pathBlock = 8}--cost will increase the more stuck you get.
        })

        warn("Computing Path to " .. pathfindingGoal.Parent.Name .. "...")

        path:ComputeAsync(HumanoidRootPart.Position - Vector3.new(0, 2.5, 0), Loot.PrimaryPart.Position)
        local waypoints = path:GetWaypoints()

        if path.Status == Enum.PathStatus.Success then
            hasResetFailsafe = true
            task.spawn(function()
                task.wait(0.1)
                hasResetFailsafe = false
                if Humanoid and Character.Collision then
                    local checkFloor = Humanoid.FloorMaterial
                    local isStuck = checkFloor == Enum.Material.Air or checkFloor == Enum.Material.Concrete
                    if isStuck then
                        repeat task.wait()
                            Character.Collision.CanCollide = false
                            Character.Collision.CollisionCrouch.CanCollide = false
                        until not isStuck or hasResetFailsafe
                    end
                    hasResetFailsafe = true
                end
            end)

            nodes:ClearAllChildren()

            for i, waypoint in pairs(waypoints) do
                local node = Instance.new("Part", nodes) do
                    node.Name = "_internal_node_" .. i
                    node.Size = Vector3.new(1, 1, 1)
                    node.Position = waypoint.Position
                    node.Anchored = true
                    node.CanCollide = false
                    node.Shape = Enum.PartType.Ball
                    node.Color = Color3.new(1, 0, 0)
                    node.Transparency = 0.5
                end
            end

            local lastWaypoint = nil
            for i, waypoint in pairs(waypoints) do
                local moveToFinished = false
                local recalculate = false
                local waypointConnection = Humanoid.MoveToFinished:Connect(function() moveToFinished = true end)
                if not moveToFinished then
                    Humanoid:MoveTo(waypoint.Position)

                    task.delay(1.5, function()
                        if moveToFinished then return end

                        repeat task.wait(0.25) until (not Character:GetAttribute("Hiding") and not Character.PrimaryPart.Anchored)

                        warn("Seems like you are stuck, trying to recalculate path...")

                        recalculate = true
                        if lastWaypoint == nil and waypointAmount > 1 then
                            waypoint = waypoints[i+1]
                        else
                            waypoint = waypoints[i-1]
                        end

                        createNewBlockedPoint(waypoint)
                    end)
                end

                repeat task.wait() until moveToFinished or recalculate
                lastWaypoint = waypoint

                waypointConnection:Disconnect()

                if nodes:FindFirstChild("_internal_node_" .. i) then
                    nodes:FindFirstChild("_internal_node_" .. i):Destroy()
                end

                if recalculate then break end
            end
        else
            warn("Pathfinding failed with status " .. tostring(path.Status))
        end
    end

    AutoPathToLoot()
end
test()