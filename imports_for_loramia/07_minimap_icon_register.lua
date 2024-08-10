---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 统一注册 【 images\map_icons 】 里的所有图标
--- 每个 xml 里面 只有一个 tex

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if Assets == nil then
    Assets = {}
end

local files_name = {
	-------------------------------------------------------------------------------------------------
	---- 00_loramia_others
	---- 22_loramia_npc
	-------------------------------------------------------------------------------------------------
		"loramia",						--- 小地图图标
	-------------------------------------------------------------------------------------------------
	---- 06_buildings
		"loramia_building_sharpstrike_creation",						--- 发电机
		"loramia_building_analytic_creation",							--- 解析的创造物
		"loramia_building_mysterious_creation",							--- 神秘的创造物  帐篷
		"loramia_building_guardian_creation",							--- 守御的创造物  炮台
		"loramia_building_primordial_creation",							--- 创世的创造物  月台
		"loramia_building_electromagnetic_tower_of_creation",			--- 创造物电磁塔  避雷针
		"loramia_building_esoteric_creation",							--- 精奥的创造物  物品转换器
		"loramia_building_sacred_creation",								--- 神圣的创造物  改版水中木
		"loramia_building_ancient_creation",							--- 古老的创造物  改版圣诞树

	-------------------------------------------------------------------------------------------------


}

for k, name in pairs(files_name) do
    table.insert(Assets, Asset( "IMAGE", "images/map_icons/".. name ..".tex" ))
    table.insert(Assets, Asset( "ATLAS", "images/map_icons/".. name ..".xml" ))
	AddMinimapAtlas("images/map_icons/".. name ..".xml")
	RegisterInventoryItemAtlas("images/map_icons/".. name ..".xml",name..".tex")	
end


