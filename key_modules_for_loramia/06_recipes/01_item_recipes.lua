



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
