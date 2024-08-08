-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/cane.zip"),
    Asset("ANIM", "anim/swap_cane.zip"),
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 
    local WORK_TIME = 15
    local function DropItem(inst)
        -- 50%概率翻找出合金板，40%概率翻找出电线，10%概率翻找出电路板
        local ret_precent = math.random(10000)/10000
        if ret_precent <= 0.5 then
            -- doer.components.inventory:GiveItem(SpawnPrefab("loramia_item_alloy_circuit_board"))
            inst.components.lootdropper:SpawnLootPrefab("loramia_item_alloy_circuit_board")
        elseif ret_precent <= 0.9 then
            -- doer.components.inventory:GiveItem(SpawnPrefab("trinket_6"))
            inst.components.lootdropper:SpawnLootPrefab("trinket_6")
        else
            -- doer.components.inventory:GiveItem(SpawnPrefab("loramia_item_luminous_alloy_board"))
            inst.components.lootdropper:SpawnLootPrefab("loramia_item_luminous_alloy_board")
        end

        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

        if inst.components.loramia_data:Add("work_time",1) >= WORK_TIME then
            inst:Remove()
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local function special_workable_install(inst)
        inst:ListenForEvent("Loramia_OnEntityReplicated.loramia_com_workable",function(inst,replica_com)
            replica_com:SetTestFn(function(inst,doer,right_click)
                return  true
            end)
            replica_com:SetSGAction("dolongaction")
            replica_com:SetText("loramia_building_spaceship_debris",STRINGS.ACTIONS.PICK.RUMMAGE)
        end)
        if not TheWorld.ismastersim then
            return
        end

        inst:AddComponent("loramia_com_workable")
        inst.components.loramia_com_workable:SetOnWorkFn(function(inst,doer)
            DropItem(inst)
            return true
        end)

    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- hammer workable
    local function hammer_workable_install(inst)
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(WORK_TIME+5)
        inst.components.workable:SetOnWorkCallback(function()
            DropItem(inst)
        end)
        inst.components.workable:SetOnFinishCallback(inst.Remove)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("scrappile")
    inst.AnimState:SetBuild("scrappile")
    inst.AnimState:PlayAnimation("idle1")

    inst.entity:SetPristine()

    special_workable_install(inst)

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")
    inst:AddComponent("loramia_data")
    inst:AddComponent("lootdropper")
    hammer_workable_install(inst)


    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("loramia_building_spaceship_debris", fn, assets)
