-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets = {

    Asset("ANIM", "anim/loramia_building_sharpstrike_creation.zip"),

}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 电池
    local PERIOD = .5

    local function DoAddBatteryPower(inst, node)
        -- print(" +++ DoAddBatteryPower",node)
        if node.AddBatteryPower then
            node:AddBatteryPower(PERIOD + math.random(2, 6) * FRAMES)
        end
        if node.Loramia_AddBatteryPower then
            node:Loramia_AddBatteryPower(PERIOD)
        end
        -- node:PushEvent("AddBatteryPower")
    end

    local function OnBatteryTask(inst)
        inst.components.circuitnode:ForEachNode(DoAddBatteryPower)
    end

    local function StartBattery(inst)
        if inst._batterytask == nil then
            inst._batterytask = inst:DoPeriodicTask(PERIOD, OnBatteryTask, 0)
        end
    end

    local function StopBattery(inst)
        if inst._batterytask ~= nil then
            inst._batterytask:Cancel()
            inst._batterytask = nil
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 电路更变（新接入、断开）
    local function UpdateCircuitPower(inst)
        if inst._circuittask then
            inst._circuittask:Cancel()
            inst._circuittask = nil
        end
        -- print("info ++ UpdateCircuitPower")
        if inst.components.circuitnode:IsConnected() and not inst.components.fueled:IsEmpty() then --- 有接入电路，开始计时
            inst.components.fueled:StartConsuming()  --- 开始燃料消耗
            StartBattery(inst)                       --- 开始电池充电
        else
            inst.components.fueled:StopConsuming()   --- 停止燃料消耗
            StopBattery(inst)                        --- 停止电池充电
        end
    end

    local function OnCircuitChanged(inst)
        if inst._circuittask == nil then
            inst._circuittask = inst:DoTaskInTime(0, UpdateCircuitPower)
        end
        -- print("info ++ OnCircuitChanged")

    end

    local function BroadcastCircuitChanged(inst)
        --Notify other connected nodes, so that they can notify their connected batteries
        inst.components.circuitnode:ForEachNode(function(inst, node)
            node:PushEvent("engineeringcircuitchanged")
        end)
        UpdateCircuitPower(inst)
        -- print("info ++ BroadcastCircuitChanged")
    end

    local function OnConnectCircuit(inst)--, node)
        if inst.components.fueled ~= nil and inst.components.fueled.consuming then
            StartBattery(inst)
        end
        OnCircuitChanged(inst)
        -- print("info ++ OnConnectCircuit")
    end

    local function OnDisconnectCircuit(inst)--, node)
        if not inst.components.circuitnode:IsConnected() then
            StopBattery(inst)
        end
        OnCircuitChanged(inst)
        -- print("info ++ OnDisconnectCircuit")
    end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 作为电池使用的时候
    local function CanBeUsedAsBattery(inst, user)
        -- print("+++ CanBeUsedAsBattery")
        return true
    end
    local function UseAsBattery(inst, user)
        -- print(" +++++ UseAsBattery",inst,user)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function OnEntitySleep(inst)

end

local function OnEntityWake(inst)
    -- if inst.components.fueled ~= nil and inst.components.fueled.consuming then
    --     StartSoundLoop(inst)
    -- end
end

local function CheckElementalBattery(inst)
	return nil
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 燃料系统相关. 使用自制燃料系统组件，这里的API 全留空
    local function OnFuelEmpty(inst) -- 能量耗尽
        inst.components.fueled:StopConsuming()
        BroadcastCircuitChanged(inst)
        StopBattery(inst)
    end
    --used by item as well
    local function CanAddFuelItem(inst, item, doer) -- 判断是否可以接受燃料物品
        return false
    end
    --used by item as well
    local function OnAddFuelAdjustLevels(inst, item, fuelvalue, doer)   -- 根据接受的物品切换能量类型

    end
    --V2C: this is newly supported callback, that happens earlier, just before the fuel item is destroyed
    -- 接受燃料物品，在燃料物品被删除前运行的callback
    local function OnAddFuelItem(inst, item, fuelvalue, doer)

    end
    local function OnAddFuel(inst)

    end
    local function OnUpdateFueled(inst)

    end
    local function OnFuelSectionChange(new, old, inst)

    end
    local function ConsumeBatteryAmount(inst, cost, share, doer) --- 消耗电池量 和相应的 任务启动

    end
    local function OnUsedIndirectly(inst, doer)

    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 加载、储存相关
    local function OnSave(inst, data)

    end

    local function OnLoad(inst, data, ents)

    end

    local function OnInit(inst)
        inst._inittask = nil
        inst.components.circuitnode:ConnectTo("engineeringbatterypowered")
    end

    local function OnLoadPostPass(inst)
        if inst._inittask ~= nil then
            inst._inittask:Cancel()
            OnInit(inst)
        end
    end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 放置指示器

    local PLACER_SCALE = 1.5

    local function OnUpdatePlacerHelper(helperinst)
        if not helperinst.placerinst:IsValid() then
            helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
            helperinst.AnimState:SetAddColour(0, 0, 0, 0)
        else
            local footprint = helperinst.placerinst.engineering_footprint_override or TUNING.WINONA_ENGINEERING_FOOTPRINT
            local range = TUNING.WINONA_BATTERY_RANGE - footprint
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

    local function OnEnableHelper(inst, enabled, recipename, placerinst)
        if enabled then
            if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
                inst.helper = CreateEntity()

                --[[Non-networked entity]]
                inst.helper.entity:SetCanSleep(false)
                inst.helper.persists = false

                inst.helper.entity:AddTransform()
                inst.helper.entity:AddAnimState()

                inst.helper:AddTag("CLASSIFIED")
                inst.helper:AddTag("NOCLICK")
                inst.helper:AddTag("placer")

                inst.helper.AnimState:SetBank("winona_battery_placement")
                inst.helper.AnimState:SetBuild("winona_battery_placement")
                inst.helper.AnimState:PlayAnimation("idle")
                inst.helper.AnimState:SetLightOverride(1)
                inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
                inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
                inst.helper.AnimState:SetSortOrder(1)
                inst.helper.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

                inst.helper.entity:SetParent(inst.entity)

                if placerinst and
                    placerinst.prefab ~= "winona_battery_low_item_placer" and
                    placerinst.prefab ~= "winona_battery_high_item_placer" and
                    recipename ~= "winona_battery_low" and
                    recipename ~= "winona_battery_high"
                then
                    inst.helper:AddComponent("updatelooper")
                    inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                    inst.helper.placerinst = placerinst
                    OnUpdatePlacerHelper(inst.helper)
                end
            end
        elseif inst.helper ~= nil then
            inst.helper:Remove()
            inst.helper = nil
        end
    end

    local function OnStartHelper(inst)--, recipename, placerinst)
        if inst.AnimState:IsCurrentAnimation("deploy") or inst.AnimState:IsCurrentAnimation("place") then
            inst.components.deployhelper:StopHelper()
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 
    local function acceptable_com_install(inst)
        local accept_item = {
                ["redgem"] = true,
                ["orangegem"] = true,
                ["yellowgem"] = true,
                ["greengem"] = true,
                ["bluegem"] = true,
                ["purplegem"] = true,
        }

        inst:ListenForEvent("Loramia_OnEntityReplicated.loramia_com_acceptable",function(inst,replica_com)
            replica_com:SetTestFn(function(inst,item,doer,right_click)
                if item and accept_item[item.prefab] then
                    return true
                end
                return false
            end)
            replica_com:SetText("loramia_building_sharpstrike_creation",STRINGS.ACTIONS.ADDFUEL)
        end)
        if not TheWorld.ismastersim then
            return
        end
        inst:AddComponent("loramia_com_acceptable")
        inst.components.loramia_com_acceptable:SetOnAcceptFn(function(inst,item,doer)
            if not ( item and accept_item[item.prefab] )then
                return false
            end
            if not inst.components.fueled:IsEmpty() then
                return false
            end
            ---------------------------------------------------------
            --- 物品消耗
                if item.components.stackable then
                    item.components.stackable:Get():Remove()
                else
                    item:Remove()
                end
            ---------------------------------------------------------
            ---
                inst.components.fueled:SetPercent(1)
                inst.components.fueled:StartConsuming()
                BroadcastCircuitChanged(inst)
                if inst.components.circuitnode:IsConnected() then
                    StartBattery(inst)
                end
            ---------------------------------------------------------

            return true
        end)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.3, 0.6)

	inst:SetPhysicsRadiusOverride(0.5)
	MakeObstaclePhysics(inst, inst.physicsradiusoverride)

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.PLACER_DEFAULT] / 2)

    inst:AddTag("structure")
	inst:AddTag("engineering")
    inst:AddTag("engineeringbattery")
    inst:AddTag("loramia_building_sharpstrike_creation")
    -----------------------------------------------------------------------------------------
    --- 动画
        inst.AnimState:SetBank("loramia_building_sharpstrike_creation")
        inst.AnimState:SetBuild("loramia_building_sharpstrike_creation")
        inst.AnimState:PlayAnimation("idle", true)

        inst.MiniMapEntity:SetIcon("loramia_building_sharpstrike_creation.tex")
    -----------------------------------------------------------------------------------------
    ---- 指示器
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
    -----------------------------------------------------------------------------------------
    ---- 燃料添加
        acceptable_com_install(inst)
    -----------------------------------------------------------------------------------------

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    -----------------------------------------------------------------------------------------
    --- 可检查
        inst:AddComponent("inspectable")
    -----------------------------------------------------------------------------------------
    --- 燃料
        inst:AddComponent("fueled")
        inst.components.fueled:SetDepletedFn(OnFuelEmpty)
        inst.components.fueled:SetCanTakeFuelItemFn(CanAddFuelItem)
        inst.components.fueled:SetTakeFuelFn(OnAddFuel)
        inst.components.fueled:SetUpdateFn(OnUpdateFueled)
        local fueled_time = 3*480
        inst.components.fueled.maxfuel = fueled_time or  3*480 -- 默认每秒消耗1点。
        inst.components.fueled:StartConsuming()
    -----------------------------------------------------------------------------------------
    --- 拆除
        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        -- inst.components.workable:SetOnWorkCallback(OnWorked)
        inst.components.workable:SetOnFinishCallback(function(inst)
            inst.components.lootdropper:DropLoot()
            local fx = SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx:SetMaterial("wood")
            inst:Remove()
        end)
    -----------------------------------------------------------------------------------------
    --- 电路模块
        inst:AddComponent("circuitnode")
        inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
        inst.components.circuitnode:SetFootprint(TUNING.WINONA_ENGINEERING_FOOTPRINT)
        inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
        inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
        inst.components.circuitnode.connectsacrossplatforms = false
        inst.components.circuitnode.rangeincludesfootprint = true
    -----------------------------------------------------------------------------------------
    -- 电池模块
        inst:AddComponent("battery")
        inst.components.battery.canbeused = CanBeUsedAsBattery
        inst.components.battery.onused = UseAsBattery
    -----------------------------------------------------------------------------------------
    --- 接入点更变
        inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)
    -----------------------------------------------------------------------------------------
    --- 作祟
        MakeHauntableWork(inst)
    -----------------------------------------------------------------------------------------
    ---
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        inst.OnLoadPostPass = OnLoadPostPass
        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake
        inst.CheckElementalBattery = CheckElementalBattery
        inst.ConsumeBatteryAmount = ConsumeBatteryAmount
        inst.OnUsedIndirectly = OnUsedIndirectly
    -----------------------------------------------------------------------------------------
    --- 初始化
        inst._batterytask = nil
        inst._inittask = inst:DoTaskInTime(0, OnInit)
        UpdateCircuitPower(inst)
    -----------------------------------------------------------------------------------------
    return inst
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


return Prefab("loramia_building_sharpstrike_creation", fn, assets)