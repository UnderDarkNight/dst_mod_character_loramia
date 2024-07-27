local assets =
{
	Asset( "ANIM", "anim/loramia.zip" ),
	Asset( "ANIM", "anim/ghost_loramia_build.zip" ),

	Asset( "ANIM", "anim/llmy.zip" ),
	Asset( "ANIM", "anim/ghost_llmy_build.zip" ),
}
local skin_fns = {

	-----------------------------------------------------
		CreatePrefabSkin("loramia_none",{
			base_prefab = "loramia",			---- 角色prefab
			skins = {
					normal_skin = "llmy",					--- 正常外观
					ghost_skin = "ghost_llmy_build",			--- 幽灵外观
			}, 								
			assets = assets,
			skin_tags = {"BASE" ,"LORAMIA", "CHARACTER"},		--- 皮肤对应的tag
			
			build_name_override = "loramia",
			rarity = "Character",
		}),
	-----------------------------------------------------
	-----------------------------------------------------
		-- CreatePrefabSkin("loramia_skin_flame",{
		-- 	base_prefab = "loramia",			---- 角色prefab
		-- 	skins = {
		-- 			normal_skin = "loramia_skin_flame", 		--- 正常外观
		-- 			ghost_skin = "ghost_loramia_build",			--- 幽灵外观
		-- 	}, 								
		-- 	assets = assets,
		-- 	skin_tags = {"BASE" ,"loramia_CARL", "CHARACTER"},		--- 皮肤对应的tag
			
		-- 	build_name_override = "loramia",
		-- 	rarity = "Character",
		-- }),
	-----------------------------------------------------

}

return unpack(skin_fns)