-- ==========================================
-- 1. 预先设置好 callback 需要调用的局部函数 (local function)
-- ==========================================

-- 下拉菜单的选择回调
local function onDropdownChanged(value)
    print("下拉菜单当前选择了:", value)
    -- 在这里写你选择 chose1 或 chose2 后的逻辑
end

-- 复选框（Checkbox / Toggle）的状态切换回调
local function onCheckboxChanged(state)
    print("Gamepass1 复选框状态:", state and "已勾选" or "未勾选")
    -- state 为 boolean 值 (true / false)
    -- 在这里写勾选或取消勾选后的逻辑
end

-- “创建”按钮的点击回调
local function onCreateButtonClicked()
    print("点击了创建按钮！")
    -- 在这里写点击创建后的核心逻辑
end


-- ==========================================
-- 2. 加载 Orion Lib 库并初始化 UI 框架
-- ==========================================

-- 根据你的 README.md 提供的官方 Loader 加载库
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/RQ-Feng/Orion/refs/heads/main/main.lua"))()

-- 创建主窗口，标题为 "title idk"
local Window = OrionLib:MakeWindow({
    Name = "title idk",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "OrionConfig"
})

-- 创建唯一的边栏 (Tab)，名字为 "bl1"
local Tab = Window:MakeTab({
    Name = "bl1",
    Icon = "rbxassetid://4483345998", -- 默认图标
    PremiumOnly = false
})


-- ==========================================
-- 3. 在边栏内添加对应的 UI 元素并绑定函数
-- ==========================================

-- 添加下拉栏 (Dropdown)
Tab:AddDropdown({
    Name = "选择项 / Select",
    Default = "chose1",
    Options = {"chose1", "chose2"},
    Callback = onDropdownChanged -- 👈 调用前面设置好的局部函数
})

-- 添加复选框 (Toggle / Checkbox)
Tab:AddToggle({
    Name = "gamepass1",
    Default = false,
    Callback = onCheckboxChanged -- 👈 调用前面设置好的局部函数
})

-- 添加按钮 (Button)
Tab:AddButton({
    Name = "创建",
    Callback = onCreateButtonClicked -- 👈 调用前面设置好的局部函数
})

-- ==========================================
-- 4. 初始化 UI 完成通知
-- ==========================================
OrionLib:Init()