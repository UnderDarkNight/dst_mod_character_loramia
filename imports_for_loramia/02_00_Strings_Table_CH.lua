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
		    ["loramia_weapon_laser_cannon"] = {
                ["name"] = "聚合激光炮",
                ["inspect_str"] = "聚合激光炮",
                ["recipe_desc"] = "聚合激光炮",
                ["action_str"] = "发射激光",
            },
        --------------------------------------------------------------------
}

