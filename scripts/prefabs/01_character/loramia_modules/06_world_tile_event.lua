--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

洛拉米亚有独属的100上限的充能值，
每移动30格距离获得1点充能，每有10点充能，饥饿速率+0.5，移动和攻击倍率+0.2，充能值达到100时每分钟回20san值。

]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 参数表
    local TILE_NUM = 30
    if TUNING.LORAMIA_DEBUGGING_MODE then
        TILE_NUM = 3
    end
    local TILE_NUM_WINGS = 20
    if TUNING.LORAMIA_DEBUGGING_MODE then
        TILE_NUM_WINGS = 2
    end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("loramia_event.enter_new_tile",function(inst,_table)
        -----------------------------------------------------------------------------------------------
        -- 玩家进入新地皮
            if inst.components.loramia_com_recharge:Add("tile_num",1) >= TILE_NUM then
                inst.components.loramia_com_recharge:Set("tile_num",0)
                inst.components.loramia_com_recharge:DoDelta(1)
            end
        -----------------------------------------------------------------------------------------------
        -- 装备了翅膀
            if inst.components.inventory:EquipHasTag("loramia_item_wings_of_universe") then
                if inst.components.loramia_com_recharge:Add("tile_num_wings",1) >= TILE_NUM_WINGS then
                    inst.components.loramia_com_recharge:Set("tile_num_wings",0)
                    inst.components.loramia_com_recharge:DoDelta(-1)
                end
            end
        -----------------------------------------------------------------------------------------------
    end)

end