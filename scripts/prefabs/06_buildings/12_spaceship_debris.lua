-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_building_spaceship_debris.zip"),
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 残骸上限记录器
    local max_spaceship_debris_num = TUNING.LORAMIA_DEBUGGING_MODE and 5 or 15  --- 总的最大数量。
    local current_spaceship_debris = {}
    local function Clear_Spaceship_Debris()
        local new_table = {}
        for k, v in pairs(current_spaceship_debris) do
            if k and k:IsValid() then
                new_table[k] = true
            end
        end
        current_spaceship_debris = new_table
    end
    local function Add_Spaceship_Debris(inst)
        Clear_Spaceship_Debris()
        current_spaceship_debris[inst] = true
    end
    local function Get_Spaceship_Debris_Num()
        local num = 0
        for k, v in pairs(current_spaceship_debris) do
            if k and k:IsValid() then
                num = num + 1
            end
        end
        return num
    end
    local function LORAMIA_SPACESHIP_DEBRIS_IS_MAX()
        local current = Get_Spaceship_Debris_Num()
        -- print(current,max_spaceship_debris_num)
        if current >= max_spaceship_debris_num then
            return true
        else
            return false
        end
        -- return Get_Spaceship_Debris_Num() >= max_spaceship_debris_num
    end
    TUNING.LORAMIA_SPACESHIP_DEBRIS_IS_MAX = LORAMIA_SPACESHIP_DEBRIS_IS_MAX
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 
    local WORK_TIME = 15
    local function DropItem(inst)
        -- 50%概率翻找出合金板，40%概率翻找出电线，10%概率翻找出电路板
        local ret_precent = math.random(10000)/10000
        if ret_precent <= 0.5 then
            inst.components.lootdropper:SpawnLootPrefab("loramia_item_luminous_alloy_board")
        elseif ret_precent <= 0.9 then
            inst.components.lootdropper:SpawnLootPrefab("trinket_6")
        else
            inst.components.lootdropper:SpawnLootPrefab("loramia_item_alloy_circuit_board")
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
        if not TUNING["loramia.Config"].SPACESHIP_DEBRIS_WORKABLE_COM then
            return
        end
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

    -- inst.AnimState:SetBank("scrappile")
    -- inst.AnimState:SetBuild("scrappile")
    -- inst.AnimState:PlayAnimation("idle1")
    inst.AnimState:SetBank("loramia_building_spaceship_debris")
    inst.AnimState:SetBuild("loramia_building_spaceship_debris")
    -- inst.AnimState:PlayAnimation("idle1")

    inst.entity:SetPristine()

    special_workable_install(inst)

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")
    inst:AddComponent("loramia_data")
    inst:AddComponent("lootdropper")
    hammer_workable_install(inst)

    ------------------------------------------------------------------
    -- 动画初始化
        inst:DoTaskInTime(0,function()
            local anim = inst.components.loramia_data:Get("anim") or "idle_"..math.random(3)
            inst.AnimState:PlayAnimation(anim)
            inst.components.loramia_data:Set("anim",anim)
        end)
    ------------------------------------------------------------------
    --- 数量上限
        inst.components.loramia_data:AddOnLoadFn(function() -- 加载的时候就进行判断删除
            if LORAMIA_SPACESHIP_DEBRIS_IS_MAX() then
                inst:Remove()
            else
                Add_Spaceship_Debris(inst)
            end
        end)
        inst:DoTaskInTime(0,function()
            Add_Spaceship_Debris(inst)
        end)
    ------------------------------------------------------------------

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("loramia_building_spaceship_debris", fn, assets)
