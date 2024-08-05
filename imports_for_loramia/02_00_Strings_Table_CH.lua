if TUNING["loramia.Strings"] == nil then
    TUNING["loramia.Strings"] = {}
end

local this_language = "ch"
-- if TUNING["loramia.Language"] then
--     if type(TUNING["loramia.Language"]) == "function" and TUNING["loramia.Language"]() ~= this_language then
--         return
--     elseif type(TUNING["loramia.Language"]) == "string" and TUNING["loramia.Language"] ~= this_language then
--         return
--     end
-- end

--------- 默认加载中文文本，如果其他语言的文本缺失，直接调取 中文文本。 03_TUNING_Common_Func.lua
--------------------------------------------------------------------------------------------------
--- 默认显示名字:  name
--- 默认显示描述:  inspect_str
--- 默认制作栏描述: recipe_desc
--------------------------------------------------------------------------------------------------
TUNING["loramia.Strings"][this_language] = TUNING["loramia.Strings"][this_language] or {
        --------------------------------------------------------------------
        --- 正在debug 测试的
            ["loramia_skin_test_item"] = {
                ["name"] = "皮肤测试物品",
                ["inspect_str"] = "inspect单纯的测试皮肤",
                ["recipe_desc"] = "测试描述666",
            },
        --------------------------------------------------------------------
        --- 组件动作
           
        --------------------------------------------------------------------
        --- 02_items
		    ["loramia_item_uniform"] = {
                ["name"] = "洛拉米亚的制服",
                ["inspect_str"] = "洛拉米亚的专属制服",
                ["recipe_desc"] = "洛拉米亚的专属制服",
            },
		    ["loramia_item_wings_of_universe"] = {
                ["name"] = "宇宙之翼",
                ["inspect_str"] = "宇宙之翼",
                ["recipe_desc"] = "宇宙之翼",
            },
		    ["loramia_item_alloy_circuit_board"] = {
                ["name"] = "合金电路板",
                ["inspect_str"] = "合金电路板",
                ["recipe_desc"] = "合金电路板",
            },
		    ["loramia_item_luminous_alloy_board"] = {
                ["name"] = "发光合金板",
                ["inspect_str"] = "发光合金板",
                ["recipe_desc"] = "发光合金板",
            },
		    ["loramia_weapon_laser_cannon"] = {
                ["name"] = "聚合激光炮",
                ["inspect_str"] = "聚合激光炮",
                ["recipe_desc"] = "聚合激光炮",
                ["action_str"] = "发射激光",
            },
		    ["loramia_item_luminescent_crystal"] = {
                ["name"] = "发光结晶",
                ["inspect_str"] = "发光结晶",
            },
        --------------------------------------------------------------------
        -- 06_buildings
            ["loramia_building_sharpstrike_creation"] = {
                ["name"] = "锋锐的创造物",
                ["inspect_str"] = "一种发电器",
                ["recipe_desc"] = "一种发电器",
            },
            ["loramia_building_swiftstrike_creation"] = {
                ["name"] = "迅袭的创造物",
                ["inspect_str"] = "一种陷阱",
                ["recipe_desc"] = "一种陷阱",
            },
            ["loramia_building_analytic_creation"] = {
                ["name"] = "解析的创造物",
                ["inspect_str"] = "用来敲出智慧",
                ["recipe_desc"] = "用来敲出智慧",
            },
            ["loramia_building_mysterious_creation"] = {
                ["name"] = "神秘的创造物",
                ["inspect_str"] = "用来睡觉和充电",
                ["recipe_desc"] = "用来睡觉和充电",
            },
            ["loramia_building_guardian_creation"] = {
                ["name"] = "守御的创造物",
                ["inspect_str"] = "一种炮台",
                ["recipe_desc"] = "一种炮台",
            },
            ["loramia_building_primordial_creation"] = {
                ["name"] = "创世的创造物",
                ["inspect_str"] = "和月亮有关",
                ["recipe_desc"] = "和月亮有关",
            },
        --------------------------------------------------------------------
}

