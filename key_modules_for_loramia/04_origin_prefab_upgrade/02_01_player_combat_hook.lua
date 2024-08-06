-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[




]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end
    
    inst:AddComponent("loramia_com_combat_hook")
    if inst.components.combat then            
        local old_GetAttacked = inst.components.combat.GetAttacked
        inst.components.combat.GetAttacked = function(self,attacker, damage, weapon, stimuli, spdamage,...)
            ------------------------------------------------------------------------------------
            --- 通用屏蔽器
                damage,spdamage = self.inst.components.loramia_com_combat_hook:GetAttackedHooked(attacker, damage, weapon, stimuli, spdamage)
            
            ------------------------------------------------------------------------------------
            return old_GetAttacked(self,attacker, damage, weapon, stimuli, spdamage,...)
        end
    end

end)

