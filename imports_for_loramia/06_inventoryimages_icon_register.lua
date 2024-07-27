---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 统一注册 【 images\inventoryimages 】 里的所有图标
--- 每个 xml 里面 只有一个 tex

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if Assets == nil then
    Assets = {}
end

local files_name = {

	---------------------------------------------------------------------------------------

		-- "loramia_weapon_scythe",											--- 冥界之镰
		-- "loramia_weapon_scythe_overcome_confinement",						--- 冲破禁锢


		-- "loramia_item_faded_memory",										--- 褪色的记忆
		-- "loramia_item_blissful_memory",										--- 幸福的记忆
	---------------------------------------------------------------------------------------

}

for k, name in pairs(files_name) do
    table.insert(Assets, Asset( "IMAGE", "images/inventoryimages/".. name ..".tex" ))
    table.insert(Assets, Asset( "ATLAS", "images/inventoryimages/".. name ..".xml" ))
	RegisterInventoryItemAtlas("images/inventoryimages/".. name ..".xml", name .. ".tex")
end


