--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[



]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local cd_task = nil
    local function active_fn(inst)

        if cd_task then
            return
        end
        cd_task = inst:DoTaskInTime(TUNING.LORAMIA_DEBUGGING_MODE and 1 or 10,function()
            cd_task = nil
        end)
        inst.replica.loramia_com_rpc_event:PushEvent("loramia_event.rhion_recall")

    end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function Add_KeyHandler(inst)
    local key_listener = TheInput:AddKeyHandler(function(key,down)
        if down == true and TUNING.LORAMIA_FN:IsKeyPressed(TUNING["loramia.Config"].IRON_RHINO_CLOSE_2_PLAYER_HOTKEY,key) then
            active_fn(inst)
        end
    end)
    inst:ListenForEvent("onremove",function()
        key_listener:Remove()
    end)
end
AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(1,function()
        if inst == ThePlayer and inst.HUD then
            Add_KeyHandler(inst)
        end
    end)
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("loramia_event.rhion_recall",function()
        
        inst.__electromagnetic_tower_of_creation_pet_task = inst.__electromagnetic_tower_of_creation_pet_task or {}
        local new_table = {}
        for monster,v in pairs(inst.__electromagnetic_tower_of_creation_pet_task) do
            if monster and monster:IsValid() then
                new_table[monster] = v
                monster:PushEvent("pet_close_2_player",{
                    destroy = true,
                    mouse_pt = TheInput and TheInput:GetWorldPosition(),
                })
            end
        end

    end)
end)
