



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
        atlas = "images/inventoryimages/loramia_item_uniform.xml",
        image = "loramia_item_uniform.tex",
    },
    {"CHARACTER","ARMOUR"}
)
-- RemoveRecipeFromFilter("loramia_item_uniform","MODS")                       -- -- 在【模组物品】标签里移除这个。
