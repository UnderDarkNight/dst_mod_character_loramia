local assets =
{
    -- Asset("ANIM", "anim/cane.zip"),
    -- Asset("ANIM", "anim/swap_cane.zip"),
}

local function Player_SetSkeletonDescription(inst, char, playername, cause, pkname, userid)
end

local function Player_SetSkeletonAvatarData(inst, client_obj)end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetSkeletonDescription = Player_SetSkeletonDescription
    inst.SetSkeletonAvatarData  = Player_SetSkeletonAvatarData

    inst:DoTaskInTime(0,function(inst)
        
        local new_inst = SpawnPrefab("junk_pile")
        local scale = 0.5
        new_inst.AnimState:SetScale(scale,scale,scale)
        new_inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
        
        inst:Remove()
    end)
    return inst
end

return Prefab("loramia_skeleton", fn, assets)
