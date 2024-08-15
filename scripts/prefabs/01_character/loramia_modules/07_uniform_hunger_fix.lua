--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    修正 制服 在穿越洞穴、存档重载 的时候造成的 饥饿值 被扣除的BUG

]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local LORAMIA_UNIFORM_DAMAGETAKEN_MULT = (1 - TUNING["loramia.Config"].LORAMIA_UNIFORM_DAMAGETAKEN_MULT ) or 0.5
    local LORAMIA_UNIFORM_MAX_HUNGER = TUNING["loramia.Config"].LORAMIA_UNIFORM_MAX_HUNGER or 3000
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local inited_flag = false --- 存档加载的时候会多次执行 onequip 和 onunequip 函数，必须屏蔽掉防止 保存错误的 饥饿值
    local origin_hunger_max = TUNING[string.upper("loramia").."_HUNGER"]

    local delta_value = LORAMIA_UNIFORM_MAX_HUNGER - origin_hunger_max
    delta_value = math.clamp(delta_value,100,10000)

    inst:ListenForEvent("loramia_item_uniform_equipped",function(inst,item)
        inst:DoTaskInTime(0,function()            
            inst.components.skinner:SetSkinName("loramia_uniform")
            inst.components.hunger.max = origin_hunger_max + delta_value --- 2700
            inst.components.hunger:DoDelta(0,true)
            if not inst.components.loramia_data:Get("loramia_item_uniform_first_time") then
                inst.components.loramia_data:Set("loramia_item_uniform_first_time",true)
                inst.components.hunger:SetPercent(1,true)
            end
            inst.components.combat.externaldamagetakenmultipliers:SetModifier(item,LORAMIA_UNIFORM_DAMAGETAKEN_MULT)
            inited_flag = true
        end)
    end)
    inst:ListenForEvent("loramia_item_uniform_unequipped",function(inst,item)
        inst.components.skinner:SetSkinName("loramia_none")
        inst.components.hunger.max = origin_hunger_max
        inst.components.hunger:DoDelta(0,true)
        inst.components.combat.externaldamagetakenmultipliers:RemoveModifier(item)
    end)

    inst.components.loramia_data:AddOnSaveFn(function(com)
        if inited_flag and inst.components.inventory:EquipHasTag("loramia_item_uniform") then
            local current_hunger = inst.components.hunger.current
            com:Set("uniform_hunger_current", current_hunger)
        end
    end)
    inst.components.loramia_data:AddOnLoadFn(function(com)
        inst:DoTaskInTime(0,function()
            local current_hunger = com:Get("uniform_hunger_current")
            if type(current_hunger) == "number" and inst.components.inventory:EquipHasTag("loramia_item_uniform") then
                inst.components.hunger.current = current_hunger
                inst.components.hunger:DoDelta(0,true)
                com:Set("uniform_hunger_current",nil)                
            end
        end)
    end)

end