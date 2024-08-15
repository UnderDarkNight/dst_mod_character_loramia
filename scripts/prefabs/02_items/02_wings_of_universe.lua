-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_item_wings_of_universe.zip"),
    Asset( "IMAGE", "images/inventoryimages/loramia_item_wings_of_universe.tex" ),
    Asset( "ATLAS", "images/inventoryimages/loramia_item_wings_of_universe.xml" ),
}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 水上行走
    local OCEAN_WALK = TUNING["loramia.Config"].WING_OF_THE_UNIVERSE_OCEAN_WALK or false
    local SPEED_MULT = (1 + TUNING["loramia.Config"].WING_OF_THE_UNIVERSE_SPEED_MULT ) or 2
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 水上行走
    local function turn_on_player_ocean_walk(owner)
        if not OCEAN_WALK then
            return
        end
        if owner.components.drownable and owner.components.drownable.enabled ~= false then
            owner.components.drownable.enabled = false
        end
        owner.Physics:ClearCollisionMask()
        owner.Physics:CollidesWith(COLLISION.GROUND)
        owner.Physics:CollidesWith(COLLISION.OBSTACLES)
        owner.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
        owner.Physics:CollidesWith(COLLISION.CHARACTERS)
        owner.Physics:CollidesWith(COLLISION.GIANTS)
        owner.Physics:Teleport(owner.Transform:GetWorldPosition())
    end
    local function turn_off_player_ocean_walk(owner)
        if not OCEAN_WALK then
            return
        end
        if owner.components.drownable then
            owner.components.drownable.enabled = true
        end
        owner.Physics:ClearCollisionMask()
        owner.Physics:CollidesWith(COLLISION.WORLD)
        owner.Physics:CollidesWith(COLLISION.OBSTACLES)
        owner.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
        owner.Physics:CollidesWith(COLLISION.CHARACTERS)
        owner.Physics:CollidesWith(COLLISION.GIANTS)
        owner.Physics:Teleport(owner.Transform:GetWorldPosition())
    end

    local function world_tile_check_fn_in_player(owner)
        owner:DoTaskInTime(0,function()            
            if owner.components.loramia_com_recharge:GetPercent() > 0 then
                turn_on_player_ocean_walk(owner)
            else
                turn_off_player_ocean_walk(owner)
            end
        end)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function onequip(inst, owner)
    if owner and owner.prefab == "loramia" then
		owner.AnimState:OverrideSymbol("swap_body", "loramia_item_wings_of_universe", "swap_body")
        -- owner.AnimState:HideSymbol("hairpigtails")
        -----------------------------------------------------------------------------------------------
        -- 地上行走
            world_tile_check_fn_in_player(owner)
            owner:ListenForEvent("loramia_event.enter_new_tile",world_tile_check_fn_in_player)
        -----------------------------------------------------------------------------------------------
        --
            owner:PushEvent("loramia_event.wings_of_universe_onequip",inst)
        -----------------------------------------------------------------------------------------------
    end
end

local function onunequip(inst, owner)
    if owner and owner.prefab == "loramia" then
        owner.AnimState:ClearOverrideSymbol("swap_body")
        -- owner.AnimState:ShowSymbol("hairpigtails")
        -----------------------------------------------------------------------------------------------
        --- 地上行走
            turn_off_player_ocean_walk(owner)
            owner:RemoveEventCallback("loramia_event.enter_new_tile",world_tile_check_fn_in_player)
        -----------------------------------------------------------------------------------------------
        ---
            owner:PushEvent("loramia_event.wings_of_universe_onunequip",inst)
        -----------------------------------------------------------------------------------------------
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("loramia_item_wings_of_universe")
    inst.AnimState:SetBuild("loramia_item_wings_of_universe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("loramia_item_wings_of_universe")
    

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    -- inst.components.inventoryitem:ChangeImageName("bluegem")
    inst.components.inventoryitem.imagename = "loramia_item_wings_of_universe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/loramia_item_wings_of_universe.xml"

    -- inst:AddComponent("fuel")
    -- inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    -- inst:AddComponent("armor")
    -- inst.components.armor:InitCondition(TUNING.ARMORWOOD, TUNING.ARMORWOOD_ABSORPTION)
    -- inst.components.armor:AddWeakness("beaver", TUNING.BEAVER_WOOD_DAMAGE)

    ---------------------------------------------------------------------------------------------------
    -- 保暖、隔热
        -- inst:AddComponent("insulator")
        -- inst.components.insulator:SetInsulation(300)
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
        
        inst.components.equippable.walkspeedmult = SPEED_MULT

    ---------------------------------------------------------------------------------------------------
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("loramia_item_wings_of_universe", fn, assets)
