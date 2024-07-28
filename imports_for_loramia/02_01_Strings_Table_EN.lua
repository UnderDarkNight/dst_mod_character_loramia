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
        --- 02_items
		    ["loramia_item_uniform"] = {
                ["name"] = "Loramia's Uniform",
                ["inspect_str"] = "Loramia's Uniform",
                ["recipe_desc"] = "Loramia's Uniform",
            },
            ["loramia_item_wings_of_universe"] = {
                ["name"] = "Wings of Universe",
                ["inspect_str"] = "Wings of Universe",
                ["recipe_desc"] = "Wings of Universe",
            },
            ["loramia_item_alloy_circuit_board"] = {
                ["name"] = "Alloy Circuit Board",
                ["inspect_str"] = "Alloy Circuit Board",
                ["recipe_desc"] = "Alloy Circuit Board",
            },
        --------------------------------------------------------------------

}