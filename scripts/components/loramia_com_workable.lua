----------------------------------------------------------------------------------------------------------------------------------
--[[

     
     
]]--
----------------------------------------------------------------------------------------------------------------------------------
local loramia_com_workable = Class(function(self, inst)
    self.inst = inst

    self.DataTable = {}


end,
nil,
{

})

function loramia_com_workable:SetCanWorlk(flag)
    if not flag then
        self.inst:AddTag("loramia_com_workable_can_not_work")
    else
        self.inst:RemoveTag("loramia_com_workable_can_not_work")
    end
end
function loramia_com_workable:GetCanWorlk()
    return not self.inst:HasTag("loramia_com_workable_can_not_work")
end

function loramia_com_workable:SetActiveFn(fn)
    if type(fn) == "function" then
        self.acive_fn = fn
    end
end

function loramia_com_workable:Active(doer)
    if self.acive_fn then
        return self.acive_fn(self.inst,doer)
    end
    return false
end

function loramia_com_workable:SetOnWorkFn(fn)
    self:SetActiveFn(fn)
end

return loramia_com_workable






