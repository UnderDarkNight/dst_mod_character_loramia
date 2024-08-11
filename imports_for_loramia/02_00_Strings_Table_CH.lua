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
                ["inspect_str"] = "谁会在裙子里插满高能电池包啊",
                ["recipe_desc"] = "女孩的裙下是百万伏高压电",
            },
		    ["loramia_item_wings_of_universe"] = {
                ["name"] = "宇宙之翼",
                ["inspect_str"] = "入乡随俗，这玩意连滑翔翼都算不上了",
                ["recipe_desc"] = "总有一天会再飞向宇宙",
            },
		    ["loramia_item_alloy_circuit_board"] = {
                ["name"] = "合金电路板",
                ["inspect_str"] = "再修修，实在不行就只能当砧板用了",
                ["recipe_desc"] = "合金电路板",
            },
		    ["loramia_item_luminous_alloy_board"] = {
                ["name"] = "发光合金板",
                ["inspect_str"] = "哈！外壳上的内嵌式灯组",
                ["recipe_desc"] = "发光合金板",
            },
		    ["loramia_weapon_laser_cannon"] = {
                ["name"] = "聚合激光炮",
                ["inspect_str"] = "我觉得这东西的使用方式不该是...算了，好用就行",
                ["recipe_desc"] = "世界上最好的舰炮，哪怕不开火",
                ["action_str"] = "发射",
            },
		    ["loramia_item_luminescent_crystal"] = {
                ["name"] = "发光结晶",
                ["inspect_str"] = "我知道变成光很酷，但喉咙发光真的很影响视野",
            },
        --------------------------------------------------------------------
        -- 06_buildings
            ["loramia_building_sharpstrike_creation"] = {
                ["name"] = "锋锐的创造物",
                ["inspect_str"] = "宝石作为透镜.....喂喂喂别照我，危险！",
                ["recipe_desc"] = "发电之余，做点小实验",
            },
            ["loramia_building_swiftstrike_creation"] = {
                ["name"] = "迅袭的创造物",
                ["inspect_str"] = "放心，很快就结束，不会痛的",
                ["recipe_desc"] = "总有一天会把这东西修好的",
            },
            ["loramia_building_analytic_creation"] = {
                ["name"] = "解析的创造物",
                ["inspect_str"] = "正在播放《galaxy》",
                ["recipe_desc"] = "知识就是力量",
            },
            ["loramia_building_mysterious_creation"] = {
                ["name"] = "神秘的创造物",
                ["inspect_str"] = "不准在充电舱里放被褥枕头",
                ["recipe_desc"] = "快充，保养，抛光，打蜡，一条龙服务",
            },
            ["loramia_building_guardian_creation"] = {
                ["name"] = "守御的创造物",
                ["inspect_str"] = "家里就交给你了",
                ["recipe_desc"] = "近防就近防吧，成熟的舰炮总得学会再就业",
            },
            ["loramia_building_primordial_creation"] = {
                ["name"] = "创世的创造物",
                ["inspect_str"] = "研究月亮的奥秘",
                ["recipe_desc"] = "月亮终将属于我",
            },
            ["loramia_building_esoteric_creation"] = {
                ["name"] = "精奥的创造物",
                ["inspect_str"] = "「换一种方式享受生物质朋友的馈赠」",
                ["recipe_desc"] = "感谢生物质朋友的馈赠",
            },
            ["loramia_building_electromagnetic_tower_of_creation"] = {
                ["name"] = "创造物电磁塔",
                ["inspect_str"] = "里面有个大铁疙瘩",
                ["recipe_desc"] = "唤醒沉睡的伙伴",
            },
            ["loramia_building_sacred_creation"] = {
                ["name"] = "神圣的创造物",
                ["inspect_str"] = "镜头转过去！我想看室女座！",
                ["recipe_desc"] = "仰望星空，就能找到归宿",
            },
            ["loramia_building_sacred_creation_fruit"] = {
                ["name"] = "增殖的创造物",
                ["inspect_str"] = "像萤火一样",
                ["recipe_desc"] = "像萤火一样",
            },
            ["loramia_item_sacred_creation_fruit"] = {
                ["name"] = "增殖的创造物",
                ["inspect_str"] = "像萤火一样",
                ["recipe_desc"] = "像萤火一样",
            },
            ["loramia_building_ancient_creation"] = {
                ["name"] = "古老的创造物",
                ["inspect_str"] = "为了你，我的生物质朋友",
                ["recipe_desc"] = "我觉得「牧林人」不太像这个意思",
            },
            ["loramia_building_spaceship_debris"] = {
                ["name"] = "飞船残骸",
                ["inspect_str"] = "真的坏了，我甚至没启动废弃协议",
            },
        --------------------------------------------------------------------
        -- 07_debuffs
            ["loramia_debuff_electromagnetic_tower_of_creation"] = {
                ["name"] = "电磁巨犀创造物",
            },
        --------------------------------------------------------------------
}

