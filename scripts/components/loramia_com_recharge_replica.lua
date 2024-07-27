----------------------------------------------------------------------------------------------------------------------------------
--[[

    充电值 系统

]]--
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
local loramia_com_recharge = Class(function(self, inst)
    self.inst = inst


    self.current = 0
    self.max = 100
    
    ------------------------------------------------------------------------------------------------------------
    ---
        self.__update_fns = {}
    ------------------------------------------------------------------------------------------------------------
    ---
        self.__net_current = net_float(inst.GUID,"loramia_com_recharge","loramia_com_recharge_update")
        if not TheNet:IsDedicated() then
            self.inst:ListenForEvent("loramia_com_recharge_update",function()           
                self.current = self.__net_current:value()
                self:ActiveUpdate()
            end)
        end
    ------------------------------------------------------------------------------------------------------------

end)
------------------------------------------------------------------------------------------------------------------------------
----
    function loramia_com_recharge:SetCurrent(value)
        self.current = value
        self.__net_current:set(value)
    end
    function loramia_com_recharge:GetCurrent()
        return self.current
    end
    function loramia_com_recharge:GetMax()
        return self.max
    end
    function loramia_com_recharge:GetPercent()
        return self.current / self.max
    end
------------------------------------------------------------------------------------------------------------------------------
---
    function loramia_com_recharge:AddUpdateFn(fn)
        table.insert(self.__update_fns,fn)
    end
    function loramia_com_recharge:ActiveUpdate()
        for k, v in pairs(self.__update_fns) do
            v(self)
        end
    end
------------------------------------------------------------------------------------------------------------------------------
return loramia_com_recharge







