if TUNING["loramia.Strings"] == nil then
    TUNING["loramia.Strings"] = {}
end

local this_language = "en"
if TUNING["loramia.Language"] then
    if type(TUNING["loramia.Language"]) == "function" and TUNING["loramia.Language"]() ~= this_language then
        return
    elseif type(TUNING["loramia.Language"]) == "string" and TUNING["loramia.Language"] ~= this_language then
        return
    end
end

TUNING["loramia.Strings"][this_language] = TUNING["loramia.Strings"][this_language] or {
        --------------------------------------------------------------------
        --- 正在debug 测试的
            -- ["loramia_skin_test_item"] = {
            --     ["name"] = "en皮肤测试物品",
            --     ["inspect_str"] = "en inspect单纯的测试皮肤",
            --     ["recipe_desc"] = " en 测试描述666",
            -- },        
        --------------------------------------------------------------------

}