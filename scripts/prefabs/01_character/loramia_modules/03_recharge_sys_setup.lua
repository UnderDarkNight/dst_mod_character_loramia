--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    洛拉米亚有独属的100上限的充能值，
    每移动30格距离获得1点充能，
    每有10点充能，饥饿速率+0.2，移动和攻击倍率+0.2，充能值达到100时每分钟回20san值。

]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local SPEED_BY_RECHARGE_VALUE = TUNING["loramia.Config"].SPEED_BY_RECHARGE_VALUE or 0.2
    local HUNGER_BY_RECHARGE_VALUE = TUNING["loramia.Config"].HUNGER_BY_RECHARGE_VALUE or 0.2
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local function GetSpecialItem()
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.LORAMIA_SPECIAL_ITEM)
        if item == nil then
            item = SpawnPrefab("loramia_special_item")
            inst.components.inventory:Equip(item)            
        end
        return item
    end

    inst:ListenForEvent("loramia_master_postinit",function()
        
        inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE

        local mult_inst = CreateEntity()
        inst:ListenForEvent("onremove",function()
            mult_inst:Remove()
        end)

        local function parama_update_by_current(inst)        
            ---------------------------------------------------------------------------------------------------
            --  
                local current = inst.components.loramia_com_recharge:GetCurrent()
            ---------------------------------------------------------------------------------------------------
            --- 每有10点充能，饥饿速率+0.2
                local temp_num = math.floor(current / 10)
                inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE + temp_num * HUNGER_BY_RECHARGE_VALUE
            ---------------------------------------------------------------------------------------------------
            --- 每有10点充能，移动 +0.2%
                inst.components.locomotor:SetExternalSpeedMultiplier(mult_inst, "loramia_recharge_speed_mod", 1 + temp_num * SPEED_BY_RECHARGE_VALUE)
            ---------------------------------------------------------------------------------------------------
            --- 每有10点充能，攻击倍率+0.2%
                inst.components.combat.externaldamagemultipliers:SetModifier(mult_inst, 1 + temp_num * 0.2 )
            ---------------------------------------------------------------------------------------------------
            -- 充能值达到100时每分钟回20san值。
                local item = GetSpecialItem()
                if current >= 100 then
                    item.components.equippable.dapperness = TUNING.DAPPERNESS_HUGE
                else
                    item.components.equippable.dapperness = 0
                end
            ---------------------------------------------------------------------------------------------------
        end


        inst:AddComponent("loramia_com_recharge")
        inst:ListenForEvent("loramia_com_recharge_update",parama_update_by_current)
        inst:DoTaskInTime(0,parama_update_by_current)


    end)
end