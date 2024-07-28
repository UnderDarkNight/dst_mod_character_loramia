--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

洛拉米亚有独属的100上限的充能值，
每移动30格距离获得1点充能，每有10点充能，饥饿速率+0.5，移动和攻击倍率+0.2，充能值达到100时每分钟回20san值。

]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local TILE_NUM = 30
if TUNING.LORAMIA_DEBUGGING_MODE then
    TILE_NUM = 1
end

return function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("loramia_event.enter_new_tile",function(inst,_table)
        if inst.components.loramia_com_recharge:Add("tile_num",1) >= TILE_NUM then
            inst.components.loramia_com_recharge:Set("tile_num",0)
            inst.components.loramia_com_recharge:DoDelta(1)
            -- print("loramia_event.enter_new_tile",inst.components.loramia_com_recharge:Add("tile_num",0))
        end
    end)

end