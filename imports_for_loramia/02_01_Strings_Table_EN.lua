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
            ["loramia_item_luminous_alloy_board"] = {
                ["name"] = "Luminous Alloy Board",
                ["inspect_str"] = "Luminous Alloy Board",
                ["recipe_desc"] = "Luminous Alloy Board",
            },
            ["loramia_weapon_laser_cannon"] = {
                ["name"] = "Laser Cannon",
                ["inspect_str"] = "Laser Cannon",
                ["recipe_desc"] = "Laser Cannon",
                ["action_str"] = "Shoot",

            },
        --------------------------------------------------------------------
        -- 06_buildings
            ["loramia_building_sharpstrike_creation"] = {
                ["name"] = "Sharpstrike Creation",
                ["inspect_str"] = "A power generator.",
                ["recipe_desc"] = "A power generator.",
            },
            ["loramia_building_swiftstrike_creation"] = {
                ["name"] = "Swiftstrike Creation",
                ["inspect_str"] = "a kind of trap",
                ["recipe_desc"] = "a kind of trap",
            },
            ["loramia_building_analytic_creation"] = {
                ["name"] = " Analytic Creation",
                ["inspect_str"] = "Used to knock",
                ["recipe_desc"] = "Used to knock",
            },
        --------------------------------------------------------------------

}