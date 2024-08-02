----------------------------------------------------------------------------------------------------------------------------------
--[[

    独立额外的伤害屏蔽器
    注意参数顺序

]]--
----------------------------------------------------------------------------------------------------------------------------------
local loramia_com_combat_hook = Class(function(self, inst)
    self.inst = inst

    self.modifiler_fns = {}

    ----- 目标被移出的时候移除事件和函数
    self.event_in_tar_inst = function(tar_inst)
        self:Remove(tar_inst)
    end

end,
nil,
{

})
---------------------------------------------------------------------------------------------------
----
    function loramia_com_combat_hook:GetAttackedHooked(attacker, damage, weapon, stimuli, spdamage)
        for index, fn in pairs(self.modifiler_fns) do
            damage,spdamage = fn(self.inst,attacker, damage, weapon, stimuli, spdamage)
        end
        return damage,spdamage
    end
---------------------------------------------------------------------------------------------------
----
    function loramia_com_combat_hook:Set(tar_inst,fn)
        self:Add(tar_inst,fn)
    end
    function loramia_com_combat_hook:Add(tar_inst,fn)
        self.modifiler_fns[tar_inst] = fn
        tar_inst:ListenForEvent("onremove",self.event_in_tar_inst)
    end
    function loramia_com_combat_hook:Remove(tar_inst)
        local new_table = {}
        for k,v in pairs(self.modifiler_fns) do
            if k ~= tar_inst then
                new_table[k] = v
            end
        end
        self.modifiler_fns = new_table
        tar_inst:RemoveEventCallback("onremove",self.event_in_tar_inst)
    end
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
return loramia_com_combat_hook







