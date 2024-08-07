---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 统一注册 【 images\inventoryimages 】 里的所有图标
--- 每个 xml 里面 只有一个 tex

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if Assets == nil then
    Assets = {}
end

local files_name = {

	---------------------------------------------------------------------------------------
	--- 02_items
		"loramia_item_uniform",											--- 专属制服
		"loramia_item_wings_of_universe",								--- 宇宙之翼
		"loramia_item_alloy_circuit_board",								--- 加速合金板
		"loramia_item_luminous_alloy_board",							--- 发光合金板
		"loramia_weapon_laser_cannon",									--- 激光炮
		"loramia_item_luminescent_crystal",								--- 发光结晶
	---------------------------------------------------------------------------------------
	--- 06_buildings
		"loramia_building_swiftstrike_creation", 						--- 陷阱
	---------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------

}

for k, name in pairs(files_name) do
    table.insert(Assets, Asset( "IMAGE", "images/inventoryimages/".. name ..".tex" ))
    table.insert(Assets, Asset( "ATLAS", "images/inventoryimages/".. name ..".xml" ))
	RegisterInventoryItemAtlas("images/inventoryimages/".. name ..".xml", name .. ".tex")
end


