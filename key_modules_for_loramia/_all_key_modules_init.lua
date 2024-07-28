-- -- -- 这个文件是给 modmain.lua 调用的总入口
-- -- -- 本lua 和 modmain.lua 平级
-- -- -- 子分类里有各自的入口
-- -- -- 注意文件路径


modimport("key_modules_for_loramia/00_others/__all_others_init.lua") 
-- 难以归类的杂乱东西

modimport("key_modules_for_loramia/01_character/__all_character_modules_init.lua") 
-- 角色模块


modimport("key_modules_for_loramia/03_origin_components_upgrade/__all_com_init.lua")
-- 官方的 component 修改

modimport("key_modules_for_loramia/04_origin_prefab_upgrade/__all_prefabs_init.lua") 
-- 官方的 prefab 修改


modimport("key_modules_for_loramia/05_widget/__all_widgets_init.lua")
-- 三维模块hook

modimport("key_modules_for_loramia/06_recipes/__all_recipes_init.lua")
-- 各种配方


