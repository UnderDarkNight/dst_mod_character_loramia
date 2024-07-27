------------------------------------------------------------------------------------------------------------------------------------------------------
---- 角色相关的 素材文件
------------------------------------------------------------------------------------------------------------------------------------------------------

if Assets == nil then
    Assets = {}
end

local temp_assets = {


	---------------------------------------------------------------------------
        Asset( "IMAGE", "images/saveslot_portraits/loramia.tex" ), --存档图片
        Asset( "ATLAS", "images/saveslot_portraits/loramia.xml" ),

        Asset( "IMAGE", "bigportraits/loramia.tex" ), --人物大图（方形的那个）
        Asset( "ATLAS", "bigportraits/loramia.xml" ),

        Asset( "IMAGE", "bigportraits/loramia_none.tex" ),  --人物大图（椭圆的那个）
        Asset( "ATLAS", "bigportraits/loramia_none.xml" ),
        
        Asset( "IMAGE", "images/map_icons/loramia.tex" ), --小地图
        Asset( "ATLAS", "images/map_icons/loramia.xml" ),
        
        Asset( "IMAGE", "images/avatars/avatar_loramia.tex" ), --tab键人物列表显示的头像  --- 直接用小地图那张就行了
        Asset( "ATLAS", "images/avatars/avatar_loramia.xml" ),
        
        Asset( "IMAGE", "images/avatars/avatar_ghost_loramia.tex" ),--tab键人物列表显示的头像（死亡）
        Asset( "ATLAS", "images/avatars/avatar_ghost_loramia.xml" ),
        
        Asset( "IMAGE", "images/avatars/self_inspect_loramia.tex" ), --人物检查按钮的图片
        Asset( "ATLAS", "images/avatars/self_inspect_loramia.xml" ),
        
        Asset( "IMAGE", "images/names_loramia.tex" ),  --人物名字
        Asset( "ATLAS", "images/names_loramia.xml" ),
        
        Asset("ANIM", "anim/loramia.zip"),              --- 人物动画文件
        Asset("ANIM", "anim/ghost_loramia_build.zip"),  --- 灵魂状态动画文件

    ---------------------------------------------------------------------------
    ----
        Asset("ANIM", "anim/loramia_status_meter.zip"),  --- 三维指示圈素材
        Asset( "IMAGE", "images/widgets/character_select_panel_loramia_hunger.tex" ), --- 选角色的时候的三维图标
        Asset( "ATLAS", "images/widgets/character_select_panel_loramia_hunger.xml" ),


	---------------------------------------------------------------------------


}
-- for i = 1, 30, 1 do
--     print("fake error ++++++++++++++++++++++++++++++++++++++++")
-- end
for k, v in pairs(temp_assets) do
    table.insert(Assets,v)
end

