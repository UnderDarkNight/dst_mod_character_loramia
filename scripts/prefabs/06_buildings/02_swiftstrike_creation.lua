-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_building_swiftstrike_creation.zip"),
    Asset( "IMAGE", "images/inventoryimages/loramia_building_swiftstrike_creation.tex" ),
    Asset( "ATLAS", "images/inventoryimages/loramia_building_swiftstrike_creation.xml" ),
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local function OnConnectCircuit(inst) -- 物品接入

    end

    local function OnDisconnectCircuit(inst) -- 物品断开
        if inst.components.circuitnode:IsConnected() then

        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- mine 陷阱组件
    local function OnExplodeFn(inst, target)  --- 触发陷阱
        inst.AnimState:PlayAnimation("up")
        if target then
            inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_trigger")
            target.components.combat:GetAttacked(inst, 150)
        end
        -- inst.components.fueled:DoDelta(-100)
        inst.components.loramia_data:Set("is_spring",true) -- 记录伸出状态
    end
    local function OnResetFn(inst)   --- 重置陷阱为收缩状态
        if inst.components.inventoryitem ~= nil then
            inst.components.inventoryitem.nobounce = true
        end
        if not inst:IsInLimbo() then
            -- inst.MiniMapEntity:SetEnabled(true)
        end
        if not inst.AnimState:IsCurrentAnimation("down_loop") then
            inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_reset")
            inst.AnimState:PlayAnimation("down")
            inst.AnimState:PushAnimation("down_loop", false)
        end
        inst.components.loramia_data:Set("is_spring",false) -- 记录伸出状态
    end
    local function OnSprungFn(inst)  --- 保持弹出状态
        if inst.components.inventoryitem ~= nil then
            inst.components.inventoryitem.nobounce = true
        end
        if not inst:IsInLimbo() then
            -- inst.MiniMapEntity:SetEnabled(true)
        end
        inst.AnimState:PlayAnimation("up_loop")
        inst.components.loramia_data:Set("is_spring",true) -- 记录伸出状态
    end
    local function OnDeactivateFn(inst) --- 保持收缩状态
        if inst.components.inventoryitem ~= nil then
            inst.components.inventoryitem.nobounce = false
        end
        -- inst.MiniMapEntity:SetEnabled(false)
        inst.AnimState:PlayAnimation("down_loop")
        inst.components.loramia_data:Set("is_spring",false) -- 记录伸出状态
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 物品放置、初始化状态切换
    local function item_deployed(inst)
        -----------------------------------------------------------
        --- 添加tag 方便连接电器
            inst:AddTag("engineering")
            inst:AddTag("engineeringbatterypowered") 
            inst:AddTag("structure")
            inst:AddTag("loramia_building_swiftstrike_creation")
        -----------------------------------------------------------
        --- 移除物品组件
            if inst.components.inventoryitem ~= nil then
                inst:RemoveComponent("inventoryitem")
            end
        -----------------------------------------------------------
        ---  伸出状态初始化
            if inst.components.loramia_data:Get("is_spring") then
                inst.components.mine:Spring()
            else
                inst.components.mine:Reset()
            end
        -----------------------------------------------------------
        ---  尝试连接发电机
            inst.components.circuitnode:ConnectTo("engineeringbattery")
        -----------------------------------------------------------
        --- 可挖掘
            inst:AddComponent("lootdropper")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnFinishCallback(function()
                inst.components.lootdropper:SpawnLootPrefab("loramia_building_swiftstrike_creation")
                -- inst.components.lootdropper:SpawnLootPrefab("bluegem")
                inst:Remove()
            end)
        -----------------------------------------------------------
    end
    local function ondeploy(inst, pt, deployer)
        -- inst.components.mine:Reset()
        inst.Physics:Stop()
        inst.Physics:Teleport(pt:Get())
        inst.components.loramia_data:Set("deployed",true)
        inst.components.loramia_data:Set("is_spring",false) -- 记录伸出状态
        inst:PushEvent("item_deployed")
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 电池刷新
    local function Loramia_AddBatteryPower(inst,PERIOD,master_node)
        -- print("++++ currentfuel ",inst.components.fueled.currentfuel)
        if inst.components.fueled:IsFull() then
            if inst.components.loramia_data:Get("is_spring") and inst.__auto_reset_task == nil then
                inst.__auto_reset_task = inst:DoTaskInTime(5,function()
                    inst.components.mine:Reset()
                    inst.components.fueled:DoDelta(-100)
                    inst:DoTaskInTime(2,function()
                        inst.__auto_reset_task = nil                        
                    end)
                end)
            end
            return
        end
        inst.components.fueled:DoDelta(4)  --- 开始充能
    end
    local function Normal_AddBatteryPower(inst,value)
        if inst.components.fueled:IsFull() then
            if inst.components.loramia_data:Get("is_spring") and inst.__auto_reset_task == nil then
                inst.__auto_reset_task = inst:DoTaskInTime(5,function()
                    inst.components.mine:Reset()
                    inst.components.fueled:DoDelta(-100)
                    inst:DoTaskInTime(2,function()
                        inst.__auto_reset_task = nil                        
                    end)
                end)
            end
            return
        end
        inst.components.fueled:DoDelta(0.1)  --- 开始充能
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
---
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("loramia_building_swiftstrike_creation")
        inst.AnimState:SetBuild("loramia_building_swiftstrike_creation")
        inst.AnimState:PlayAnimation("item")

        MakeInventoryPhysics(inst)
        inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.LESS] / 2)

        -- local scale = 1
        -- inst.AnimState:SetScale(scale, scale, scale)

        inst:AddTag("engineering")


        inst.entity:SetPristine()
        ----------------------------------------------------------------------------------
        --- 放置指示器
            indicator_setup(inst)
        ----------------------------------------------------------------------------------
        if not TheWorld.ismastersim then
            return inst
        end

        ----------------------------------------------------------------------------------
            inst:AddComponent("inspectable")
        ----------------------------------------------------------------------------------
        --- 物品组件
            inst:AddComponent("inventoryitem")
            -- inst.components.inventoryitem:ChangeImageName("cane")
            inst.components.inventoryitem.imagename = "loramia_building_swiftstrike_creation"
            inst.components.inventoryitem.atlasname = "images/inventoryimages/loramia_building_swiftstrike_creation.xml"
            inst.components.inventoryitem:SetSinks(true)
            inst.components.inventoryitem:SetOnDroppedFn(function(inst)
                inst.components.mine:Deactivate()
            end)
        ----------------------------------------------------------------------------------
        --- 数据
            inst:AddComponent("loramia_data")
        ----------------------------------------------------------------------------------
        --- 陷阱系统
            inst:AddComponent("mine")
            inst.components.mine:SetRadius(TUNING.TRAP_TEETH_RADIUS)
            inst.components.mine:SetAlignment("player")
            inst.components.mine:SetOnExplodeFn(OnExplodeFn)
            inst.components.mine:SetOnResetFn(OnResetFn)
            inst.components.mine:SetOnSprungFn(OnSprungFn)
            inst.components.mine:SetOnDeactivateFn(OnDeactivateFn)
            inst.components.mine:SetReusable(false)  --- 不可手动重置
        ----------------------------------------------------------------------------------
        --- 能量槽
            inst:AddComponent("fueled")
            inst.components.fueled.maxfuel = 100
        ----------------------------------------------------------------------------------
        --- 电器节点
            inst:AddComponent("circuitnode")
            inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
            -- inst.components.circuitnode:SetFootprint(TUNING.WINONA_ENGINEERING_FOOTPRINT)
            inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
            inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
            -- inst.components.circuitnode.connectsacrossplatforms = false
            -- inst.components.circuitnode.rangeincludesfootprint = true
        ----------------------------------------------------------------------------------
        --- 物品切换
            inst:ListenForEvent("item_deployed",item_deployed)
            -- inst.Loramia_AddBatteryPower = function(inst,PERIOD,master_node)
            --     print("++++",PERIOD,master_node)
            -- end
            inst.Loramia_AddBatteryPower = Loramia_AddBatteryPower
            inst.AddBatteryPower = Normal_AddBatteryPower
        ----------------------------------------------------------------------------------
        --- 物品部署
            inst:AddComponent("deployable")
            inst.components.deployable.ondeploy = ondeploy
            inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)
        ----------------------------------------------------------------------------------
        --- 初始化
            inst:DoTaskInTime(0,function()
                if inst.components.loramia_data:Get("deployed") then
                    inst:RemoveComponent("inventoryitem")
                    inst:PushEvent("item_deployed")
                end
            end)
        ----------------------------------------------------------------------------------
        --- 作祟
            inst:AddComponent("hauntable")
            inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
                if inst.components.mine == nil or inst.components.mine.inactive then
                    inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
                    Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
                    return true
                elseif not inst.components.mine.issprung then
                    return false
                elseif math.random() <= TUNING.HAUNT_CHANCE_OFTEN then
                    inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
                    inst.components.mine:Reset()
                    return true
                end
                return false
            end)
        ----------------------------------------------------------------------------------
        --- 挖掘

        ----------------------------------------------------------------------------------


        return inst
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- placer
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

        inst.AnimState:SetBank("loramia_building_swiftstrike_creation")
        inst.AnimState:SetBuild("loramia_building_swiftstrike_creation")
        inst.AnimState:PlayAnimation("down_loop")
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
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return Prefab("loramia_building_swiftstrike_creation", fn, assets),
    MakePlacer("loramia_building_swiftstrike_creation_placer", "loramia_building_swiftstrike_creation", "loramia_building_swiftstrike_creation", "down_loop", nil, nil, nil, nil, nil, nil, placer_postinit_fn, nil, nil)
