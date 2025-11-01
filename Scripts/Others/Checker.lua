if type(checklist) ~= 'table' then return end

local checker = {
    ['work'] = {},
    ['fail'] = {}
}

local function CheckFunc(func)
    local result = type(func) == 'function'
    if result then table.insert(checker.work,func) else table.insert(checker.fail,func) end
end

for _,func in pairs(checklist) do CheckFunc(func) end

for _,workfunc in pairs(checker.work) do print('✅',workfunc) end
for _,failfunc in pairs(checker.fail) do warn('❌',failfunc)  end

return checker.work,checker.fail