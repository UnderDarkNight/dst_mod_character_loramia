



--------------------------------------------------------------------------------------------------------------------------------------------
---- 专属制服  【配方：20蛛丝，2电线，2电器元件】
--------------------------------------------------------------------------------------------------------------------------------------------
AddRecipeToFilter("loramia_item_uniform","CHARACTER")     ---- 添加物品到目标标签
AddRecipe2(
    "loramia_item_uniform",            --  --  inst.prefab  实体名字
    { Ingredient("silk", 20),Ingredient("trinket_6", 2),Ingredient("transistor", 2) }, 
    TECH.SCIENCE_TWO, --- TECH.NONE
    {
        nounlock = true,
        no_deconstruction = true,
        builder_tag = "loramia",
        atlas = "images/inventoryimages/loramia_item_uniform.xml",
        image = "loramia_item_uniform.tex",
    },
    {"CHARACTER","ARMOUR"}
)
-- RemoveRecipeFromFilter("loramia_item_uniform","MODS")                       -- -- 在【模组物品】标签里移除这个。


--------------------------------------------------------------------------------------------------------------------------------------------
---- 聚合光炮  【配方：5电器元件，5破烂的电线，5金子，5燧石】
--------------------------------------------------------------------------------------------------------------------------------------------
AddRecipeToFilter("loramia_weapon_laser_cannon","CHARACTER")     ---- 添加物品到目标标签
AddRecipe2(
    "loramia_weapon_laser_cannon",            --  --  inst.prefab  实体名字
    { Ingredient("transistor", 5),Ingredient("trinket_6", 5),Ingredient("goldnugget", 5),Ingredient("flint", 5)}, 
    TECH.SCIENCE_TWO, --- TECH.NONE
    {
        nounlock = true,
        no_deconstruction = true,
        builder_tag = "loramia",
        atlas = "images/inventoryimages/loramia_weapon_laser_cannon.xml",
        image = "loramia_weapon_laser_cannon.tex",
    },
    {"CHARACTER","WEAPONS"}
)
-- RemoveRecipeFromFilter("loramia_weapon_laser_cannon","MODS")                       -- -- 在【模组物品】标签里移除这个。

--------------------------------------------------------------------------------------------------------------------------------------------
---- 【迅袭的创造物】【魔法2本】【配方：10狗牙，1蓝宝石，1电子元件】
--------------------------------------------------------------------------------------------------------------------------------------------
AddRecipeToFilter("loramia_building_swiftstrike_creation","CHARACTER")     ---- 添加物品到目标标签
AddRecipe2(
    "loramia_building_swiftstrike_creation",            --  --  inst.prefab  实体名字
    { Ingredient("houndstooth", 10),Ingredient("bluegem", 1),Ingredient("transistor", 1)}, 
    TECH.MAGIC_TWO, --- TECH.NONE
    {
        -- nounlock = true,
        no_deconstruction = true,
        builder_tag = "loramia",
        atlas = "images/inventoryimages/loramia_building_swiftstrike_creation.xml",
        image = "loramia_building_swiftstrike_creation.tex",
    },
    {"CHARACTER","WEAPONS"}
)
-- RemoveRecipeFromFilter("loramia_building_swiftstrike_creation","MODS")                       -- -- 在【模组物品】标签里移除这个。

--------------------------------------------------------------------------------------------------------------------------------------------
---- 【解析的创造物】【一本】【配方：制造成本6金子，6电器元件，6石板，无法被破坏，拆卸用铲子，返还一半物资】
--------------------------------------------------------------------------------------------------------------------------------------------
AddRecipeToFilter("loramia_building_analytic_creation","CHARACTER")     ---- 添加物品到目标标签
AddRecipe2(
    "loramia_building_analytic_creation",            --  --  inst.prefab  实体名字
    { Ingredient("goldnugget", 6),Ingredient("transistor", 6),Ingredient("cutstone", 6)}, 
    TECH.SCIENCE_ONE, --- TECH.NONE
    {
        -- nounlock = true,
        no_deconstruction = true,
        builder_tag = "loramia",
        placer = "loramia_building_analytic_creation_placer",
        atlas = "images/map_icons/loramia_building_analytic_creation.xml",
        image = "loramia_building_analytic_creation.tex",
    },
    {"CHARACTER","STRUCTURES"}
)
-- RemoveRecipeFromFilter("loramia_building_analytic_creation","MODS")                       -- -- 在【模组物品】标签里移除这个。

--------------------------------------------------------------------------------------------------------------------------------------------
---- 【二本】【配方：1红宝石，1电器元件，1金子，3石板，无法被破坏，拆卸用铲子，返还红宝石】
--------------------------------------------------------------------------------------------------------------------------------------------
AddRecipeToFilter("loramia_building_mysterious_creation","CHARACTER")     ---- 添加物品到目标标签
AddRecipe2(
    "loramia_building_mysterious_creation",            --  --  inst.prefab  实体名字
    { Ingredient("goldnugget", 1),Ingredient("transistor", 1),Ingredient("cutstone", 3),Ingredient("redgem", 1)}, 
    TECH.SCIENCE_TWO, --- TECH.NONE
    {
        -- nounlock = true,
        no_deconstruction = true,
        builder_tag = "loramia",
        placer = "loramia_building_mysterious_creation_placer",
        atlas = "images/map_icons/loramia_building_mysterious_creation.xml",
        image = "loramia_building_mysterious_creation.tex",
    },
    {"CHARACTER","STRUCTURES"}
)
-- RemoveRecipeFromFilter("loramia_building_mysterious_creation","MODS")                       -- -- 在【模组物品】标签里移除这个。
