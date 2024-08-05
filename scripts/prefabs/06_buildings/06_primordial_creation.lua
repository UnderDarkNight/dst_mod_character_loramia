-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_building_primordial_creation.zip"),
}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- moon checker event install
    local YELLOWSTAFF_TASK_TIME = TUNING.LORAMIA_DEBUGGING_MODE and 30 or 120
    local function moon_checker_event_install(inst)

        inst:ListenForEvent("yellowstaff_task_start",function()
            if TheWorld:HasTag("cave") then
                return
            end
            if TheWorld.state.isfullmoon and not inst:HasTag("yellowstaff_task_working") then
                local fx = inst:SpawnChild("loramia_sfx_terra_beam")
                fx:PushEvent("TurnOn",{
                    pt = Vector3(0,0,0),
                })
                inst.fx = fx

                inst:AddTag("yellowstaff_task_working")
                inst.yellostaff_task = inst:DoPeriodicTask(1,function()
                    inst.yellostaff_task_time = (inst.yellostaff_task_time or 0) + 1
                    if inst.yellostaff_task_time >= YELLOWSTAFF_TASK_TIME then
                        inst.yellostaff_task:Cancel()
                        inst.yellostaff_task = nil
                        inst.yellostaff_task_time = nil
                        inst:RemoveTag("yellowstaff_task_working")
                        inst:PushEvent("yellowstaff_task_end")
                        inst.fx:PushEvent("TurnOff")
                    end
                end)

            end
        end)

        local task_checker_starter = function(inst)
            if TheWorld.state.isfullmoon and TheWorld.state.isnight and inst:HasTag("has_yellowstaff") then
                inst:PushEvent("yellowstaff_task_start")
            end
        end
        --- 初始化检查
        inst:DoTaskInTime(0,task_checker_starter)

        --- 任务结束
        inst:ListenForEvent("yellowstaff_task_end",function()
            inst.components.lootdropper:SpawnLootPrefab("opalstaff")
            inst:RemoveTag("has_yellowstaff")
            inst.components.loramia_data:Set("has_yellowstaff",false)
            inst.SoundEmitter:PlaySound("dontstarve/common/together/celestial_orb/active")
        end)

        inst:WatchWorldState("isfullmoon",task_checker_starter)
        inst:WatchWorldState("isnight",task_checker_starter)

        --- 初始化检查
        inst.components.loramia_data:AddOnLoadFn(function()
            if inst.components.loramia_data:Get("has_yellowstaff") then
                inst:AddTag("has_yellowstaff")
                inst:PushEvent("yellowstaff_task_start")
            end
        end)

    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- acceptable
    local accept_item = {
        ["moonrocknugget"] = true,
        ["moonglass"] = true,
        -- ["yellowstaff"] = true,
    }
    local function acceptable_install(inst)
        inst:ListenForEvent("Loramia_OnEntityReplicated.loramia_com_acceptable",function(inst,replica_com)
            replica_com:SetText("loramia_building_primordial_creation",STRINGS.ACTIONS.GIVE.GENERIC)
            replica_com:SetSGAction("give")
            replica_com:SetTestFn(function(inst,item,doer,right_click)
                if accept_item[item.prefab] then
                    return true
                end
                if item.prefab == "yellowstaff" and not inst:HasTag("has_yellowstaff") then
                    return true
                end
                return false
            end)
        end)
        if not TheWorld.ismastersim then
            return
        end

        inst:AddComponent("loramia_com_acceptable")
        inst.components.loramia_com_acceptable:SetOnAcceptFn(function(inst,item,doer)
            if accept_item[item.prefab] then
                if item.components.stackable then
                    item.components.stackable:Get():Remove()
                else
                    item:Remove()    
                end
                inst.SoundEmitter:PlaySound("dontstarve/common/together/celestial_orb/active")
                TheWorld:PushEvent("ms_setmoonphase", {moonphase = "full"})
                return true
            elseif item.prefab == "yellowstaff" then
                item:Remove()
                inst.components.loramia_data:Set("has_yellowstaff",true)
                inst:AddTag("has_yellowstaff")
                inst.SoundEmitter:PlaySound("dontstarve/common/together/celestial_orb/active")
                inst:PushEvent("yellowstaff_task_start")
                return true
            end
            return false
        end)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- workable
    local function OnFinishCallback(inst,worker)
        inst.components.lootdropper:SpawnLootPrefab("greengem")
        inst.components.lootdropper:SpawnLootPrefab("purplegem")
        inst.components.lootdropper:SpawnLootPrefab("orangegem")
        inst.components.lootdropper:SpawnLootPrefab("thulecite")
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

        --- 除非玩家主动敲打，否则不会掉落
        local old_WorkedBy = inst.components.workable.WorkedBy
        inst.components.workable.WorkedBy = function(self,worker, numworks,...)
            if worker and worker:HasTag("player") then
                return old_WorkedBy(self,worker, numworks,...)
            end
        end
        local old_WorkedBy_Internal = inst.components.workable.WorkedBy_Internal
        inst.components.workable.WorkedBy_Internal = function(self,worker, numworks,...)
            if worker and worker:HasTag("player") then
                return old_WorkedBy_Internal(self,worker, numworks,...)
            end
        end
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

    inst.MiniMapEntity:SetIcon("loramia_building_primordial_creation.tex")

    inst.AnimState:SetBank("loramia_building_primordial_creation")
    inst.AnimState:SetBuild("loramia_building_primordial_creation")
    inst.AnimState:PlayAnimation("idle",true)

    inst.entity:SetPristine()
    -----------------------------------------------------------
    --- 
        acceptable_install(inst)
    -----------------------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end


    -----------------------------------------------------------
    --- 
        inst:AddComponent("loramia_data")
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
    --- 月亮相关的事件安装
        moon_checker_event_install(inst)
    -----------------------------------------------------------

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("loramia_building_primordial_creation", fn, assets),
    MakePlacer("loramia_building_primordial_creation_placer", "loramia_building_primordial_creation", "loramia_building_primordial_creation", "idle", nil, nil, nil, nil, nil, nil, nil, nil, nil)


