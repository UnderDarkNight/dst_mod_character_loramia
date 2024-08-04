-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_building_analytic_creation.zip"),
}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- workable
    local function special_workable_install(inst)
        local tag = ACTIONS.HAMMER.id.."_tool"
        inst:ListenForEvent("Loramia_OnEntityReplicated.loramia_com_workable",function(inst,replica_com)
            replica_com:SetTestFn(function(inst,doer,right_click)
                if right_click and doer and doer.replica.inventory and doer.replica.inventory:EquipHasTag(tag) then
                    return true
                end
                return false
            end)
            replica_com:SetSGAction("hammer")
            replica_com:SetText("loramia_building_analytic_creation",STRINGS.ACTIONS.HAMMER)
        end)
        if not TheWorld.ismastersim then
            return
        end
        local max_fueled = 100
        if TUNING.LORAMIA_DEBUGGING_MODE then
            max_fueled = 10
        end
        inst:AddComponent("fueled")
        inst.components.fueled.maxfuel = max_fueled

        inst:AddComponent("loramia_com_workable")
        inst.components.loramia_com_workable:SetOnWorkFn(function(inst,doer)
            inst.components.fueled:DoDelta(1)
            if inst.components.fueled:IsFull() then
                inst.components.fueled:SetPercent(0)

                local player = doer
                player.components.builder:GiveTempTechBonus({SCIENCE = 2, MAGIC = 2, SEAFARING = 2})
                local fx = SpawnPrefab(player.components.rider ~= nil and player.components.rider:IsRiding() and "fx_book_research_station_mount" or "fx_book_research_station")
                fx.Transform:SetPosition(player.Transform:GetWorldPosition())
                fx.Transform:SetRotation(player.Transform:GetRotation())

            end
            return true
        end)

    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- workable
    local function OnFinishCallback(inst,worker)
        for i = 1, 3, 1 do
            inst.components.lootdropper:SpawnLootPrefab("goldnugget")
            inst.components.lootdropper:SpawnLootPrefab("transistor")
            inst.components.lootdropper:SpawnLootPrefab("cutstone")
        end
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end
    local function workable_install(inst)
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetWorkLeft(1)
        -- inst.components.workable:SetOnWorkCallback(onhit)
        inst.components.workable:SetOnFinishCallback(OnFinishCallback)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(2, 1)

    inst.MiniMapEntity:SetIcon("loramia_building_analytic_creation.tex")

    inst.AnimState:SetBank("loramia_building_analytic_creation")
    inst.AnimState:SetBuild("loramia_building_analytic_creation")
    inst.AnimState:PlayAnimation("idle",true)

    inst.entity:SetPristine()
    -----------------------------------------------------------
    --- 
        special_workable_install(inst)
    -----------------------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end


    -----------------------------------------------------------
    --- 
        inst:AddComponent("loramia_data")
        inst:DoTaskInTime(0,function()
            if not inst.components.loramia_data:Get("inited") then
                inst.components.loramia_data:Set("inited",true)
                inst.components.fueled:SetPercent(0)
            end
        end)
    -----------------------------------------------------------
    --- 
        inst:AddComponent("inspectable")
    -----------------------------------------------------------
    --- 
        inst:AddComponent("lootdropper")
    -----------------------------------------------------------
    --- 官方的workable
        workable_install(inst)
    -----------------------------------------------------------

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("loramia_building_analytic_creation", fn, assets),
    MakePlacer("loramia_building_analytic_creation_placer", "loramia_building_analytic_creation", "loramia_building_analytic_creation", "idle", nil, nil, nil, nil, nil, nil, nil, nil, nil)


