-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    特殊物品、给玩家上回San光环

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    -- Asset("ANIM", "anim/cane.zip"),
    -- Asset("ANIM", "anim/swap_cane.zip"),
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("loramia_special_item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("cane")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.LORAMIA_SPECIAL_ITEM
    inst.components.equippable.dapperness = 0
    -- inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(function()
        inst:DoTaskInTime(0,function()
            inst:Remove()            
        end)
    end)
    -- inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT


    return inst
end

return Prefab("loramia_special_item", fn, assets)
