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
            inst.components.circuitnode:SetFootprint(TUNING.WINONA_ENGINEERING_FOOTPRINT)
            inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
            inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
            inst.components.circuitnode.connectsacrossplatforms = false
            inst.components.circuitnode.rangeincludesfootprint = true
        ----------------------------------------------------------------------------------
        --- 物品切换
            inst:ListenForEvent("item_deployed",item_deployed)
            -- inst.Loramia_AddBatteryPower = function(inst,PERIOD,master_node)
            --     print("++++",PERIOD,master_node)
            -- end
            inst.Loramia_AddBatteryPower = Loramia_AddBatteryPower
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
    local function placer_postinit_fn(inst)
        
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return Prefab("loramia_building_swiftstrike_creation", fn, assets),
    MakePlacer("loramia_building_swiftstrike_creation_placer", "loramia_building_swiftstrike_creation", "loramia_building_swiftstrike_creation", "down_loop", nil, nil, nil, nil, nil, nil, placer_postinit_fn, nil, nil)
