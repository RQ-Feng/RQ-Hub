if type(checklist) ~= 'table' then return end

local checker = {
    ['work'] = {},
    ['fail'] = {}
}

local function CheckFunc(func)
    local result = type(getfenv(0)[func]) == 'function' and true or false
    if result then 
        print('✅',workfunc) table.insert(checker.work,func) 
    else 
        warn('❌',failfunc) table.insert(checker.fail,func) 
    end
end

for _,func in pairs(checklist) do CheckFunc(func) end

return checker.work,checker.fail