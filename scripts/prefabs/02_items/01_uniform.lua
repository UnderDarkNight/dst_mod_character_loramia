-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    -- Asset("ANIM", "anim/armor_wood.zip"),
}


local function onequip(inst, owner)
    if owner and owner.prefab == "loramia" then
        -- owner:DoTaskInTime(0,function()
            owner.components.skinner:SetSkinName("loramia_uniform")
            owner.components.hunger.max = TUNING[string.upper("loramia").."_HUNGER"] + 2700
            owner.components.hunger:DoDelta(0,true)
            if not owner.components.loramia_data:Get("loramia_item_uniform_first_time") then
                owner.components.loramia_data:Set("loramia_item_uniform_first_time",true)
                owner.components.hunger:SetPercent(1,true)
            end
            owner.components.combat.externaldamagetakenmultipliers:SetModifier(inst,0.5)
        -- end)
    end
end

local function onunequip(inst, owner)
    if owner and owner.prefab == "loramia" then
        owner.components.skinner:SetSkinName("loramia_none")
        owner.components.hunger.max = TUNING[string.upper("loramia").."_HUNGER"]
        owner.components.hunger:DoDelta(0,true)
        owner.components.combat.externaldamagetakenmultipliers:RemoveModifier(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("loramia_item_uniform")
    inst.AnimState:SetBuild("loramia_item_uniform")
    inst.AnimState:PlayAnimation("idle")


    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    -- inst.components.inventoryitem:ChangeImageName("bluegem")
    inst.components.inventoryitem.imagename = "loramia_item_uniform"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/loramia_item_uniform.xml"

    -- inst:AddComponent("fuel")
    -- inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    -- inst:AddComponent("armor")
    -- inst.components.armor:InitCondition(TUNING.ARMORWOOD, TUNING.ARMORWOOD_ABSORPTION)
    -- inst.components.armor:AddWeakness("beaver", TUNING.BEAVER_WOOD_DAMAGE)

    ---------------------------------------------------------------------------------------------------
    -- 保暖、隔热
        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(300)
    ---------------------------------------------------------------------------------------------------
    --- 护甲
        -- inst:AddComponent("armor")
        -- -- inst.components.armor:InitIndestructible(0.5)
        -- inst.components.armor:SetAbsorption(0.5)
    ---------------------------------------------------------------------------------------------------
    --- 可装备
        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable.restrictedtag = "loramia"

        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
    ---------------------------------------------------------------------------------------------------
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("loramia_item_uniform", fn, assets)
