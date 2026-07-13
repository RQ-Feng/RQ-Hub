return {
    ['Loaded'] = false,
    -- #sym:ESPSetting 中心配置表
    -- 所有ESP相关的默认配置在此统一管理
    ['ESPSetting'] = {
        ['TextSize'] = 17,            -- 文字大小

        -- ESPLibrary.GlobalConfig 的默认值 (EspSetting.lua UI 会覆盖这些)
        ['GlobalConfig'] = {
            ['IgnoreCharacter'] = false,  -- 忽略角色自身
            ['Rainbow'] = false,          -- 彩虹特效
            ['Distance'] = true,          -- 显示距离
            ['Font'] = 'RobotoCondensed', -- 字体
            ['Arrows'] = false,           -- 箭头指示
            ['Tracers'] = false,          -- 追踪线
            ['Billboards'] = true,        -- 标签
            ['Highlighters'] = true,      -- 高亮
            ['Boxes2D'] = false,          -- 2D框
            ['Boxes3D'] = false,          -- 3D框
            ['Skeleton'] = false,         -- 骨骼
        }
    }
}
