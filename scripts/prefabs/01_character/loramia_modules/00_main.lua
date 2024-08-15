--------------------------------------------------------------------------------------------------------------------------------------------------
---- 模块总入口，使用 common_postinit 进行嵌入初始化，注意 mastersim 区分
--------------------------------------------------------------------------------------------------------------------------------------------------
return function(inst)

    if TheWorld.ismastersim then
        if inst.components.loramia_data == nil then
            inst:AddComponent("loramia_data")
        end
    end

    local modules = {
        "prefabs/01_character/loramia_modules/01_hud_change",                           ---- hud修改
        "prefabs/01_character/loramia_modules/02_recharge_badge_setup",                 ---- 充电值的界面
        "prefabs/01_character/loramia_modules/03_recharge_sys_setup",                   ---- 充电值系统
        "prefabs/01_character/loramia_modules/04_death_skeleton",                       ---- 死亡骷髅
        "prefabs/01_character/loramia_modules/05_custom_eater",                         ---- 吃东西的组件
        "prefabs/01_character/loramia_modules/06_world_tile_event",                     ---- 地图地块检测组件
        "prefabs/01_character/loramia_modules/07_uniform_hunger_fix",                   ---- 制服相关的操作
        "prefabs/01_character/loramia_modules/08_custom_sounds",                        ---- 客制化音源
        "prefabs/01_character/loramia_modules/09_uniform_temperature_controller",       ---- 套装温度控制器

    }
    for k, lua_addr in pairs(modules) do
        local temp_fn = require(lua_addr)
        if type(temp_fn) == "function" then
            temp_fn(inst)
        end
    end


    inst:AddTag("loramia")
    inst:AddTag("fastbuilder")
    inst:AddTag("handyperson")
    inst:AddTag("basicengineer")


    inst.customidleanim = "idle_wendy"  -- 闲置站立动画
    inst.soundsname = "wendy"           -- 角色声音

    -- inst:AddTag("stronggrip")      --- 不被打掉武器


    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:AddOverrideBuild("wendy_channel")
    inst.AnimState:AddOverrideBuild("player_idles_wendy")


end