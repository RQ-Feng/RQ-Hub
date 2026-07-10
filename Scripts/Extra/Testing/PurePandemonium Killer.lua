local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local connection = nil
local success = false

local function checkAndDestroy(child)
	if child:IsA("BasePart") then
		local nameLower = string.lower(child.Name)
		-- 转换为小写匹配，防止大小写绕过
		if string.find(nameLower, "pande") or string.find(nameLower, "monium") then
            task.wait(0.1)
			print("[Anti-Pande] 成功拦截并销毁异常 Part: " .. child.Name)
			child:Destroy()
		end
	end
end

for _, child in ipairs(Workspace:GetChildren()) do
	checkAndDestroy(child)
end
connection = Workspace.ChildAdded:Connect(checkAndDestroy)

local closeCallback = Instance.new("BindableFunction")
closeCallback.OnInvoke = function(buttonName)
	if buttonName == "停止监控" then
		if connection then
			connection:Disconnect()
			connection = nil
			print("[Anti-Pande] 监听已断开，停止检测。")
		end
	end
end

while not success do
	task.wait(0.1)
	success = pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Anti Pandomenium",
			Text = "启用中",
			Icon = "rbxassetid://6031075931", -- 自带或自定义图标（可选）
			Duration = math.huge, -- 让它长时间显示，直到玩家点击
			Callback = closeCallback, -- 绑定点击事件
			Button1 = "关闭", -- 按钮文本
		})
	end)
end