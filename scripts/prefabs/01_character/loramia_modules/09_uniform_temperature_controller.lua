--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[



]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local UNIFORM_TEMPERATURE_COST = TUNING["loramia.Config"].UNIFORM_TEMPERATURE_COST or 200
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return function(inst)
    if not TheWorld.ismastersim then
        return
    end
    -- local temperature_task = nil
    -- inst:ListenForEvent("loramia_item_uniform_equipped",function()
    --     if temperature_task == nil then            
    --         temperature_task = inst:DoPeriodicTask(10,function(inst)
   
    --     end        
    -- end)
    -- inst:ListenForEvent("loramia_item_uniform_unequipped",function()
    --     if temperature_task ~= nil then
    --         temperature_task:Cancel()
    --         temperature_task = nil
    --     end
    -- end)


    local uniform_equipped = false
    inst:ListenForEvent("loramia_item_uniform_equipped",function()
        uniform_equipped = true
    end)
    inst:ListenForEvent("loramia_item_uniform_unequipped",function()
        uniform_equipped = false
    end)

    inst:ListenForEvent("temperaturedelta",function()
        -------------------------------------------------------------------
        --
            if inst:HasTag("playerghost") or not uniform_equipped then
                return
            end
        -------------------------------------------------------------------
        --
            local need_2_cost_flag = false
            if inst.components.hunger.current < UNIFORM_TEMPERATURE_COST then
                return
            end
        -------------------------------------------------------------------
        --
            local current = inst.components.temperature.current
            if current >= 65 then -- 过热
                inst.components.temperature:SetTemperature(8)
                inst:SpawnChild("halloween_firepuff_cold_2")
                need_2_cost_flag = true
            elseif current <= 5 then
                inst:SpawnChild("halloween_firepuff_1")
                inst.components.temperature:SetTemperature(60)
                need_2_cost_flag = true
            end
        -------------------------------------------------------------------
        --
            if need_2_cost_flag then
                inst.components.hunger:DoDelta(-UNIFORM_TEMPERATURE_COST,true)
            end
        -------------------------------------------------------------------
    end)

end