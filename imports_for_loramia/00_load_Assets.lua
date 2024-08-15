
if Assets == nil then
    Assets = {}
end

local temp_assets = {


	-- Asset("IMAGE", "images/inventoryimages/loramia_empty_icon.tex"),
	-- Asset("ATLAS", "images/inventoryimages/loramia_empty_icon.xml"),
	
	-- Asset("SHADER", "shaders/mod_test_shader.ksh"),		--- 测试用的

	---------------------------------------------------------------------------

	-- Asset("ANIM", "anim/loramia_hud_wellness.zip"),	--- 体质值进度条
	-- Asset("ANIM", "anim/loramia_item_medical_certificate.zip"),	--- 诊断单 界面
	-- Asset("ANIM", "anim/loramia_hud_shop_widget.zip"),	--- 商店界面和按钮



	---------------------------------------------------------------------------
	--- 从老王的MOD中提取来的 RPG 动作和声音
		Asset("ANIM", "anim/player_homura_rpg.zip"),	--- RPG动作
		Asset("SOUNDPACKAGE", "sound/lw_homura.fev"), 
		Asset("SOUND", "sound/lw_homura.fsb"),
	---------------------------------------------------------------------------
	--- 角色专属音源
		Asset("SOUNDPACKAGE", "sound/loramia_sound.fev"), 
		Asset("SOUND", "sound/loramia_sound.fsb"),
	---------------------------------------------------------------------------
	--- 星空滤镜
		Asset("IMAGE", "images/widgets/loramia_starry_night_filter.tex"),
		Asset("ATLAS", "images/widgets/loramia_starry_night_filter.xml"),
	---------------------------------------------------------------------------
	-- Asset("SOUNDPACKAGE", "sound/dontstarve_DLC002.fev"),	--- 单机声音集
	---------------------------------------------------------------------------


}

for k, v in pairs(temp_assets) do
    table.insert(Assets,v)
end

