local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local t_List = {} -- ⚠️ 这里需要填入你地图里所有房间判定点 Part 的数组

-- 核心获取函数
local function getCurrentRoomByRaycast()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart or #t_List == 0 then return nil end

    -- 1. 创建射线参数，并设置白名单只检测房间判定点
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Include
    raycastParams.FilterDescendantsInstances = t_List

    -- 2. 向下发射 21 studs 的射线
    local raycastResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -21, 0), raycastParams)

    if raycastResult then
        local hitPart = raycastResult.Instance
        
        -- 3. 🎯 拿到了踩到的判定点，通过你自己的映射表或属性即可获取对应的房间
        return hitPart
    end
    
    return nil
end

-- ⚡ 每帧测试获取
RunService.RenderStepped:Connect(function()
    local room = getCurrentRoomByRaycast()
    if room then
        print("当前踩在判定点:", room.Name)
    end
end)