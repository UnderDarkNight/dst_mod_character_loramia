----------------------------------------------------------------------------------------------------------------------------------
--[[

     通用数据储存库，用来储存各种 【文本】数据

]]--
----------------------------------------------------------------------------------------------------------------------------------
local loramia_data = Class(function(self, inst)
    self.inst = inst

    self.DataTable = {}
    self.TempTable = {}
    self._onload_fns = {}
    self._onsave_fns = {}
end,
nil,
{

})
---------------------------------------------------------------------------------------------------
----- onload/onsave 函数
    function loramia_data:AddOnLoadFn(fn)
        if type(fn) == "function" then
            table.insert(self._onload_fns, fn)
        end
    end
    function loramia_data:ActiveOnLoadFns()
        for k, temp_fn in pairs(self._onload_fns) do
            temp_fn(self)
        end
    end
    function loramia_data:AddOnSaveFn(fn)
        if type(fn) == "function" then
            table.insert(self._onsave_fns, fn)
        end
    end
    function loramia_data:ActiveOnSaveFns()
        for k, temp_fn in pairs(self._onsave_fns) do
            temp_fn(self)
        end
    end
---------------------------------------------------------------------------------------------------
----- 数据读取/储存

    function loramia_data:Get(index)
        if index then
            return self.DataTable[index]
        end
        return nil
    end
    function loramia_data:Set(index,theData)
        if index then
            self.DataTable[index] = theData
        end
    end

    function loramia_data:Add(index,num)
        if index then
            self.DataTable[index] = (self.DataTable[index] or 0) + ( num or 0 )
            return self.DataTable[index]
        end
        return 0
    end
------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------
    function loramia_data:OnSave()
        self:ActiveOnSaveFns()
        local data =
        {
            DataTable = self.DataTable
        }
        return next(data) ~= nil and data or nil
    end

    function loramia_data:OnLoad(data)
        if data.DataTable then
            self.DataTable = data.DataTable
        end
        self:ActiveOnLoadFns()
    end
------------------------------------------------------------------------------------------------------------------------------
return loramia_data







