------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    raindomewatcher.lua
    雨遮蔽器的关键API

    local domes = GetRainDomesAtXZ(x, z)

]]--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- AddComponentPostInit("raindomewatcher", function(self)

--     local old_IsUnderRainDome = self.IsUnderRainDome
--     self.IsUnderRainDome = function(self,...)
--         local old_ret = old_IsUnderRainDome(self,...)
--         if not old_ret then
--             local x,y,z = self.inst.Transform:GetWorldPosition()
--             local ents = TheSim:FindEntities(x,y,z,3.5,{})
--         end
--         return old_ret
--     end
-- end)

-- local old_GetRainDomesAtXZ = rawget(_G,"GetRainDomesAtXZ")
-- rawset(_G,"GetRainDomesAtXZ",function(x,z)
--     local origin_ret = old_GetRainDomesAtXZ(x,z) or {}
--     return origin_ret
-- end)