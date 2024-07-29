----------------------------------------------------------------------------------------------------------------------------------
--[[

    充电值 系统

]]--
----------------------------------------------------------------------------------------------------------------------------------
---
    local function set_current(self,value)
        local replica_com = self.inst.replica.loramia_com_recharge or self.inst.replica._.loramia_com_recharge
        if replica_com then
            replica_com:SetCurrent(value)
        end
    end
    local function set_max(self,value)
        local replica_com = self.inst.replica.loramia_com_recharge or self.inst.replica._.loramia_com_recharge
        if replica_com then
            replica_com:SetMax(value)
        end
    end
----------------------------------------------------------------------------------------------------------------------------------
local loramia_com_recharge = Class(function(self, inst)
    self.inst = inst

    self.DataTable = {}
    self.TempTable = {}
    self._onload_fns = {}
    self._onsave_fns = {}




    self.current = 0
    self.max = 100


end,
nil,
{
    current = set_current,
    max = set_max,
})
---------------------------------------------------------------------------------------------------
----- onload/onsave 函数
    function loramia_com_recharge:AddOnLoadFn(fn)
        if type(fn) == "function" then
            table.insert(self._onload_fns, fn)
        end
    end
    function loramia_com_recharge:ActiveOnLoadFns()
        for k, temp_fn in pairs(self._onload_fns) do
            temp_fn(self)
        end
    end
    function loramia_com_recharge:AddOnSaveFn(fn)
        if type(fn) == "function" then
            table.insert(self._onsave_fns, fn)
        end
    end
    function loramia_com_recharge:ActiveOnSaveFns()
        for k, temp_fn in pairs(self._onsave_fns) do
            temp_fn(self)
        end
    end
---------------------------------------------------------------------------------------------------
----- 数据读取/储存
    function loramia_com_recharge:Get(index)
        if index then
            return self.DataTable[index]
        end
        return nil
    end
    function loramia_com_recharge:Set(index,theData)
        if index then
            self.DataTable[index] = theData
        end
    end

    function loramia_com_recharge:Add(index,num)
        if index then
            self.DataTable[index] = (self.DataTable[index] or 0) + ( num or 0 )
            return self.DataTable[index]
        end
        return 0
    end
------------------------------------------------------------------------------------------------------------------------------
----
    function loramia_com_recharge:SetValue(num)
        self.current = math.clamp(num,0,self.max)
        self.inst:PushEvent("loramia_com_recharge_update")
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
    function loramia_com_recharge:DoDelta(value)
        self:SetValue(self.current + value)
    end
------------------------------------------------------------------------------------------------------------------------------
    function loramia_com_recharge:OnSave()
        self:ActiveOnSaveFns()
        local data =
        {
            DataTable = self.DataTable,
            current = self.current,
            max = self.max,
        }
        return next(data) ~= nil and data or nil
    end

    function loramia_com_recharge:OnLoad(data)
        data = data or {}
        if data.DataTable then
            self.DataTable = data.DataTable
        end
        if data.current then
            self.current = data.current
        end
        if data.max then
            self.max = data.max
        end
        self:ActiveOnLoadFns()
    end
------------------------------------------------------------------------------------------------------------------------------
return loramia_com_recharge







