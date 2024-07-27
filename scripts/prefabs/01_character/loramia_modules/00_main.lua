--------------------------------------------------------------------------------------------------------------------------------------------------
---- 模块总入口，使用 common_postinit 进行嵌入初始化，注意 mastersim 区分
--------------------------------------------------------------------------------------------------------------------------------------------------
return function(inst)

    if TheWorld.ismastersim then

    end

    local modules = {
        "prefabs/01_character/loramia_modules/01_hud_change",                           ---- hud修改
        "prefabs/01_character/loramia_modules/02_recharge_badge_setup",                 ---- 充电值的界面
        "prefabs/01_character/loramia_modules/03_recharge_sys_setup",                   ---- 充电值系统
        "prefabs/01_character/loramia_modules/04_death_skeleton",                       ---- 死亡骷髅

    }
    for k, lua_addr in pairs(modules) do
        local temp_fn = require(lua_addr)
        if type(temp_fn) == "function" then
            temp_fn(inst)
        end
    end


    inst:AddTag("loramia")


    inst.customidleanim = "idle_wendy"  -- 闲置站立动画
    inst.soundsname = "wendy"           -- 角色声音

    -- inst:AddTag("stronggrip")      --- 不被打掉武器


    if not TheWorld.ismastersim then
        return
    end



end