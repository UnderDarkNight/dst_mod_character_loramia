--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    无法从食物中直接获取三维回复

]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("loramia_master_postinit",function()
        inst.components.eater.custom_stats_mod_fn = function(inst, health_delta, hunger_delta, sanity_delta, food, feeder)
            if health_delta > 0 then
                health_delta = 0
            end
            if hunger_delta > 0 then
                hunger_delta = 0
            end
            if sanity_delta > 0 then
                sanity_delta = 0
            end
            return health_delta, hunger_delta, sanity_delta
        end
    end)

end