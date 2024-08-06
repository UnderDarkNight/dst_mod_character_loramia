-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_building_mysterious_creation.zip"),
}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local MYSTERIOUS_CREATION_COST_PERCENT =  TUNING["loramia.Config"].MYSTERIOUS_CREATION_COST_PERCENT or 0.01
    local MYSTERIOUS_CREATION_HUNGER_VALUE_UP = TUNING["loramia.Config"].MYSTERIOUS_CREATION_HUNGER_VALUE_UP or 50
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- workable
    local function OnFinishCallback(inst,worker)
        inst.components.lootdropper:SpawnLootPrefab("redgem")
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
--- sleepingbag
    local function is_in_battery_area(inst)     ---- 在充电区域
        if not inst.components.circuitnode:IsConnected() then
            return false
        end
        local ret_flag = false
        local battery = nil
        inst.components.circuitnode:ForEachNode(function(inst, node)
            if ret_flag == false and node and node:HasTag("engineeringbattery") then
                if node.components.fueled and not node.components.fueled:IsEmpty() then
                    ret_flag = true
                    battery = node
                end
            end
        end)
        return ret_flag,battery
    end
    local function sleeping_task_in_player(inst,player,battery_node) --- 玩家周期性任务
        --------------------------------------------------------------------------
        --- 切换检查参数
            if not player:HasTag("loramia") then
                inst.components.sleepingbag.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK
                inst.components.sleepingbag.health_tick = TUNING.SLEEP_HEALTH_PER_TICK
                inst.components.sleepingbag.sanity_tick = TUNING.SLEEP_SANITY_PER_TICK
            else
                if battery_node and battery_node.components.fueled and not battery_node.components.fueled:IsEmpty() then
                    inst.components.sleepingbag.hunger_tick = MYSTERIOUS_CREATION_HUNGER_VALUE_UP or 50
                    -- battery_node.components.fueled:DoDelta(-1)
                    local battery_node_max = battery_node.components.fueled.maxfuel
                    local battery_node_cost = battery_node_max*MYSTERIOUS_CREATION_COST_PERCENT
                    battery_node.components.fueled:DoDelta(-battery_node_cost)
                else
                    inst.components.sleepingbag.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK
                end
                inst.components.sleepingbag.health_tick = TUNING.SLEEP_HEALTH_PER_TICK
                inst.components.sleepingbag.sanity_tick = TUNING.SLEEP_SANITY_PER_TICK
            end
        --------------------------------------------------------------------------
        --- 血量上限
            if player.components.health then
                player.components.health:DeltaPenalty(-0.05)
            end
        --------------------------------------------------------------------------
    end
    local function onignite(inst)
        inst.components.sleepingbag:DoWakeUp()
    end
    local function onwake(inst, sleeper, nostatechange) --- 玩家醒来
        sleeper:RemoveEventCallback("onignite", onignite, inst)
        if inst.sleepingbag_task[sleeper] then
            inst.sleepingbag_task[sleeper]:Cancel()
            inst.sleepingbag_task[sleeper] = nil
        end
    end
    local function onsleep(inst, sleeper)       --- 玩家入睡
        sleeper:ListenForEvent("onignite", onignite, inst)

        if inst.sleepingbag_task[sleeper] then
            inst.sleepingbag_task[sleeper]:Cancel()
        end
        inst.sleepingbag_task[sleeper] = inst:DoPeriodicTask(1,function()
            local in_battery_area , battery_inst = is_in_battery_area(inst)
            if in_battery_area then
                sleeping_task_in_player(inst,sleeper,battery_inst)
            end            
        end)
    end
    local function temperaturetick(inst, sleeper)  --- 温度控制
        if sleeper.components.temperature ~= nil then
            if inst.is_cooling then
                if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                    sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
                end
            elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
            end
        end
    end
    local function sleepingbag_install(inst)
        inst:AddComponent("sleepingbag")
        inst.components.sleepingbag.onsleep = onsleep
        inst.components.sleepingbag.onwake = onwake
        ------------------------------------------------------------------
        -- 让帐篷全天候可进去
            local function GetPhase()
                if TheWorld.state.phase == "day" then
                    inst:AddTag("siestahut")
                    return "day"
                end
                inst:RemoveTag("siestahut")
                return "night"
            end
            inst.components.sleepingbag.GetSleepPhase = function()
                return TheWorld.state.phase
            end
            inst:DoTaskInTime(0,function()
                inst.components.sleepingbag:SetSleepPhase(GetPhase())
            end)
            inst:WatchWorldState("phase",function()
                inst.components.sleepingbag:SetSleepPhase(GetPhase())                
            end)
        ------------------------------------------------------------------

        --convert wetness delta to drying rate
        inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
        inst.components.sleepingbag:SetTemperatureTickFn(temperaturetick)
        -----------------------------------------------------------
        --- 因意外移除而取消任务
            inst.sleepingbag_task = {}
        -----------------------------------------------------------
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- circuitnode
    -- local function circuitnode_OnInit(inst)
    --     inst:DoTaskInTime(0,function()
    --         inst.components.circuitnode:ConnectTo("engineeringbattery")
    --     end)
    -- end
    local function OnConnectCircuit(inst) -- 物品接入
        
    end

    local function OnDisconnectCircuit(inst) -- 物品断开
        if inst.components.circuitnode:IsConnected() then

        end
    end
    local function circuitnode_setup(inst)



        inst:AddComponent("circuitnode")
        inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
        -- inst.components.circuitnode:SetFootprint(TUNING.WINONA_ENGINEERING_FOOTPRINT)
        inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
        inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
        -- inst.components.circuitnode.connectsacrossplatforms = false
        -- inst.components.circuitnode.rangeincludesfootprint = true
        inst:DoTaskInTime(0,function()
            inst.components.circuitnode:ConnectTo("engineeringbattery")
        end)

        inst.AddBatteryPower = function()
            
        end
        
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 指示器安装
    local PLACER_SCALE = 1.5

    local function OnUpdatePlacerHelper(helperinst)
        if not helperinst.placerinst:IsValid() then
            helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
            helperinst.AnimState:SetAddColour(0, 0, 0, 0)
        else
            local range = TUNING.WINONA_BATTERY_RANGE - TUNING.WINONA_ENGINEERING_FOOTPRINT
            local hx, hy, hz = helperinst.Transform:GetWorldPosition()
            local px, py, pz = helperinst.placerinst.Transform:GetWorldPosition()
            --<= match circuitnode FindEntities range tests
            if distsq(hx, hz, px, pz) <= range * range and TheWorld.Map:GetPlatformAtPoint(hx, hz) == TheWorld.Map:GetPlatformAtPoint(px, pz) then
                helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
            else
                helperinst.AnimState:SetAddColour(0, 0, 0, 0)
            end
        end
    end

    local function CreatePlacerBatteryRing()
        local inst = CreateEntity()

        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOCLICK")
        inst:AddTag("placer")

        inst.AnimState:SetBank("winona_battery_placement")
        inst.AnimState:SetBuild("winona_battery_placement")
        inst.AnimState:PlayAnimation("idle_small")
        inst.AnimState:SetLightOverride(1)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(1)
        inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

        return inst
    end

    local function CreatePlacerRing()
        local inst = CreateEntity()

        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOCLICK")
        inst:AddTag("placer")

        inst.AnimState:SetBank("winona_spotlight_placement")
        inst.AnimState:SetBuild("winona_spotlight_placement")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetAddColour(0, .2, .5, 0)
        inst.AnimState:SetLightOverride(1)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(1)
        inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

        CreatePlacerBatteryRing().entity:SetParent(inst.entity)

        return inst
    end

    local function OnEnableHelper(inst, enabled, recipename, placerinst)
        if enabled then
            if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
                if recipename == "winona_spotlight" or (placerinst and placerinst.prefab == "winona_spotlight_item_placer") then
                    inst.helper = CreatePlacerRing()
                    inst.helper.entity:SetParent(inst.entity)
                else
                    inst.helper = CreatePlacerBatteryRing()
                    inst.helper.entity:SetParent(inst.entity)
                    if placerinst and (
                        placerinst.prefab == "winona_battery_low_item_placer" or
                        placerinst.prefab == "winona_battery_high_item_placer" or
                        recipename == "winona_battery_low" or
                        recipename == "winona_battery_high"
                    ) then
                        inst.helper:AddComponent("updatelooper")
                        inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                        inst.helper.placerinst = placerinst
                        OnUpdatePlacerHelper(inst.helper)
                    end
                end
            end
        elseif inst.helper ~= nil then
            inst.helper:Remove()
            inst.helper = nil
        end
    end

    local function OnStartHelper(inst)--, recipename, placerinst)
        if inst.AnimState:IsCurrentAnimation("place") then
            inst.components.deployhelper:StopHelper()
        end
    end
    local function indicator_setup(inst)
        if not TheNet:IsDedicated() then
            inst:AddComponent("deployhelper")
            inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
            inst.components.deployhelper:AddRecipeFilter("winona_catapult")
            inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
            inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
            inst.components.deployhelper:AddKeyFilter("winona_battery_engineering")
            inst.components.deployhelper.onenablehelper = OnEnableHelper
            inst.components.deployhelper.onstarthelper = OnStartHelper
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


    inst.MiniMapEntity:SetIcon("loramia_building_mysterious_creation.tex")

    inst.AnimState:SetBank("loramia_building_mysterious_creation")
    inst.AnimState:SetBuild("loramia_building_mysterious_creation")
    inst.AnimState:PlayAnimation("idle",true)

    inst:AddTag("tent")
    inst:AddTag("structure")
    inst:AddTag("engineering")
    inst:AddTag("engineeringbatterypowered") 
    inst:AddTag("loramia_building_mysterious_creation")

    -----------------------------------------------------------
    --- 指示器安装
        indicator_setup(inst)
    -----------------------------------------------------------
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    -----------------------------------------------------------
    --- 
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
    --- 官方的睡袋系统
        sleepingbag_install(inst)
    -----------------------------------------------------------
    --- 官方的电器系统
        circuitnode_setup(inst)
    -----------------------------------------------------------
    inst.AddBatteryPower = function() end
    -----------------------------------------------------------

    MakeHauntableLaunch(inst)

    return inst
end

----------------------------------------------------------------------------------------------------------------------
--- placer
    local function CreatePlacerSpotlight()
        local inst = CreateEntity()

        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOCLICK")
        inst:AddTag("placer")

        inst.Transform:SetTwoFaced()

        inst.AnimState:SetBank("loramia_building_mysterious_creation")
        inst.AnimState:SetBuild("loramia_building_mysterious_creation")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetLightOverride(1)

        return inst
    end
    local function placer_postinit_fn(inst)
        --Show the spotlight placer on top of the spotlight range ground placer
        --Also add the small battery range indicator

        local placer2 = CreatePlacerBatteryRing()
        placer2.entity:SetParent(inst.entity)
        inst.components.placer:LinkEntity(placer2)

        placer2 = CreatePlacerSpotlight()
        placer2.entity:SetParent(inst.entity)
        inst.components.placer:LinkEntity(placer2)

        inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

        inst.deployhelper_key = "winona_battery_engineering"
    end
----------------------------------------------------------------------------------------------------------------------

return Prefab("loramia_building_mysterious_creation", fn, assets),
    MakePlacer("loramia_building_mysterious_creation_placer", "loramia_building_mysterious_creation", "loramia_building_mysterious_creation", "idle", nil, nil, nil, nil, nil, nil, placer_postinit_fn)


