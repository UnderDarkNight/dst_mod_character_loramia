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
                ["inspect_str"] = "Who would stuff high-energy battery packs into their skirt?",
                ["recipe_desc"] = "girl's skirt have  million volts of electricity",
            },
            ["loramia_item_wings_of_universe"] = {
                ["name"] = "Wings of Universe",
                ["inspect_str"] = "Adapting to local customs, this thing isn't even a glider wing.",
                ["recipe_desc"] = "One day it will fly back into space again.",
            },
            ["loramia_item_alloy_circuit_board"] = {
                ["name"] = "Alloy Circuit Board",
                ["inspect_str"] = " Fix it some more, if it doesn't work, I might as well use it as a cutting board.",
                ["recipe_desc"] = "Alloy Circuit Board",
            },
            ["loramia_item_luminous_alloy_board"] = {
                ["name"] = "Luminous Alloy Board",
                ["inspect_str"] = "Ha!   The embedded light group on the casing!",
                ["recipe_desc"] = "Luminous Alloy Board",
            },
            ["loramia_weapon_laser_cannon"] = {
                ["name"] = "Laser Cannon",
                ["inspect_str"] = "I think the way to use this thing shouldn't be...   forget it, it works fine.",
                ["recipe_desc"] = "The best ship cannon in the world, even when not firing.",
                ["action_str"] = "Shoot",
            },
            ["loramia_item_luminescent_crystal"] = {
                ["name"] = "Luminescent Crystal",
                ["inspect_str"] = "I know it's cool to become light, but having your throat glowing really affects your vision.",
            },
        --------------------------------------------------------------------
        -- 06_buildings
            ["loramia_building_sharpstrike_creation"] = {
                ["name"] = "Sharpstrike Creation",
                ["inspect_str"] = "Gemstones as lenses...   hey, don't shine that at me, it's dangerous!.",
                ["recipe_desc"] = "Experiment a little while generating power.",
            },
            ["loramia_building_swiftstrike_creation"] = {
                ["name"] = "Swiftstrike Creation",
                ["inspect_str"] = "Don't worry, it'll be over soon, it won't hurt.",
                ["recipe_desc"] = "One day I'll fix this thing.",
            },
            ["loramia_building_analytic_creation"] = {
                ["name"] = " Analytic Creation",
                ["inspect_str"] = "《galaxy》on the air.",
                ["recipe_desc"] = "Knowledge is power.",
            },
            ["loramia_building_mysterious_creation"] = {
                ["name"] = "Mysterious Creation",
                ["inspect_str"] = "No bedding or pillows in the charging bay.",
                ["recipe_desc"] = "High speed, maintenance, polishing, waxing, one-stop service",
            },
            ["loramia_building_guardian_creation"] = {
                ["name"] = " Guardian Creation",
                ["inspect_str"] = "Protect the home",
                ["recipe_desc"] = "you are already a mature naval gun, you have to learn to re-employment.",
            },
            ["loramia_building_primordial_creation"] = {
                ["name"] = "Primordial Creation",
                ["inspect_str"] = "Studying the secrets of the moon.",
                ["recipe_desc"] = "The moon will belong to me eventually.",
            },
            ["loramia_building_esoteric_creation"] = {
                ["name"] = "Esoteric Creation",
                ["inspect_str"] = "Enjoy the gifts of biomass friends in a different way.",
                ["recipe_desc"] = "Thanks for the gifts of biomass friends.",
            },
            ["loramia_building_electromagnetic_tower_of_creation"] = {
                ["name"] = "Electromagnetic Tower of Creation",
                ["inspect_str"] = "There's a big hunk of metal inside.  ",
                ["recipe_desc"] = "Wake up sleeping companions.",
            },
            ["loramia_building_sacred_creation"] = {
                ["name"] = "Sacred Creation",
                ["inspect_str"] = "Camera, turn away!   I want to see Virgo!",
                ["recipe_desc"] = "Gaze upon the stars, and you will find your destination.",
            },
            ["loramia_building_sacred_creation_fruit"] = {
                ["name"] = "Proliferating Creation",
                ["inspect_str"] = "Like a firefly",
                ["recipe_desc"] = "Like a firefly",
            },
            ["loramia_item_sacred_creation_fruit"] = {
                ["name"] = "Proliferating Creation",
                ["inspect_str"] = "Like a firefly",
                ["recipe_desc"] = "Like a firefly",
            },
            ["loramia_building_ancient_creation"] = {
                ["name"] = " Ancient Creation",
                ["inspect_str"] = "For you, my biomass friend",
                ["recipe_desc"] = "I don't think 「forester」really means that",
            },
            ["loramia_building_spaceship_debris"] = {
                ["name"] = "Spaceship Debris",
                ["inspect_str"] = "It's really broken. I didn't even use the scrap protocol",
            },
        --------------------------------------------------------------------

}