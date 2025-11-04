if type(checklist) ~= 'table' then return end

local checker = {
    ['work'] = {},
    ['fail'] = {}
}

local function CheckFunc(func)
    if type(func) ~= 'string' then warn('Checker:Please enter string to check the function. (string expected, got',tostring(func) ..')') return end
    local result = type(getfenv(0)[func]) == 'function' and true or false
    if result then print('✅',func) table.insert(checker.work,func) 
    else warn('❌',func) table.insert(checker.fail,func) 
    end
end

for _,func in pairs(checklist) do CheckFunc(func) end

return checker.work,checker.fail