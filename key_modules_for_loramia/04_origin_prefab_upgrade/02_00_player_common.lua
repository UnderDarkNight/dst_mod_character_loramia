-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[




]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end
    
    if inst.components.loramia_data == nil then
        inst:AddComponent("loramia_data")
    end
    if inst.components.loramia_com_rpc_event == nil then
        inst:AddComponent("loramia_com_rpc_event")
    end

end)

