-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_building_guardian_creation.zip"),
}
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
--- circuitnode
    local function circuitnode_OnInit(inst)
        inst:DoTaskInTime(0,function()
            inst.components.circuitnode:ConnectTo("engineeringbattery")
        end)
    end
    local function Is_In_Battery_Area(inst)     ---- 在充电区域
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
        circuitnode_OnInit(inst)

        inst.AddBatteryPower = function()
            
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- workable
    local function OnFinishCallback(inst,worker)
        inst.components.lootdropper:SpawnLootPrefab("redgem")
        inst.components.lootdropper:SpawnLootPrefab("yellowgem")
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
---
    ---创建 激光
    local function CreateLaser(player,pt,onhitfn,workable_destroy_checker_fn)
        ---------------------------------------------------
        --- 修改自官方的激光代码
            local SECOND_BLAST_TIME = 22*FRAMES
            local NUM_STEPS = 10
            local STEP = 1.0
            local OFFSET = 2 - STEP
            local function SpawnBeam(inst, target_pos,onhitfn,workable_destroy_checker_fn)
                if target_pos == nil then
                    return
                end
            
                local ix, iy, iz = inst.Transform:GetWorldPosition()
            
                -- This is the "step" of fx spawning that should align with the position the beam is targeting.
                local target_step_num = RoundBiasedUp(NUM_STEPS * 2/5)
            
                local angle = nil
            
                -- gx, gy, gz is the point of the actual first beam fx
                local gx, gy, gz = nil, 0, nil
                local x_step = STEP
                if inst:GetDistanceSqToPoint(target_pos:Get()) < 4 then
                    angle = math.atan2(iz - target_pos.z, ix - target_pos.x)
            
                    -- If the target is too close, use the minimum distance
                    gx, gy, gz = inst.Transform:GetWorldPosition()
                    gx = gx + (2 * math.cos(angle))
                    gz = gz + (2 * math.sin(angle))
                else
                    angle = math.atan2(iz - target_pos.z, ix - target_pos.x)
            
                    gx, gy, gz = target_pos:Get()
                    gx = gx + (target_step_num * STEP * math.cos(angle))
                    gz = gz + (target_step_num * STEP * math.sin(angle))
                end
            
                local targets, skiptoss = {}, {}
                local sbtargets, sbskiptoss = {}, {}
                local x, z = nil, nil
                local trigger_time = nil
            
                local i = -1
                while i < NUM_STEPS do
                    i = i + 1
                    x = gx - i * x_step * math.cos(angle)
                    z = gz - i * STEP * math.sin(angle)
            
                    local first = (i == 0)
                    local prefab = (i > 0 and "loramia_spell_laser") or "loramia_spell_laserempty"
                    local x1, z1 = x, z
            
                    trigger_time = math.max(0, i - 1) * FRAMES
                    ---------------------------------------------------
                    ---- 发射激光
                        inst:DoTaskInTime(trigger_time, function(inst2)
                            local fx = SpawnPrefab(prefab)
                            if onhitfn then
                                fx:SetCustomDoDamageFn(function(fx,target)
                                    onhitfn(target)
                                end)
                            end
                            if workable_destroy_checker_fn then
                                fx:SetCustomWorkableDestroyCheckerFn(function(fx,target)
                                    print("6666666666",target)
                                    return workable_destroy_checker_fn(target)
                                end)
                            end
                            fx.caster = inst2
                            fx.Transform:SetPosition(x1, 0, z1)
                            fx:Trigger(0, targets, skiptoss)

                        end)
                    ---------------------------------------------------

                end
            
                inst:DoTaskInTime(i*FRAMES, function(inst2)
                    local fx = SpawnPrefab("loramia_spell_laser")
                    fx.Transform:SetPosition(x, 0, z)
                    fx:Trigger(0, targets, skiptoss)
                end)
            
                inst:DoTaskInTime((i+1)*FRAMES, function(inst2)
                    local fx = SpawnPrefab("loramia_spell_laser")
                    fx.Transform:SetPosition(x, 0, z)
                    fx:Trigger(0, targets, skiptoss)
                end)
            end
        ---------------------------------------------------
        ---- 官方的三叉代码
            local TRIBEAM_ANGLEOFF = PI/5
            local TRIBEAM_COS = math.cos(TRIBEAM_ANGLEOFF)
            local TRIBEAM_SIN = math.sin(TRIBEAM_ANGLEOFF)
            local TRIBEAM_COSNEG = math.cos(-TRIBEAM_ANGLEOFF)
            local TRIBEAM_SINNEG = math.sin(-TRIBEAM_ANGLEOFF)

            local ipos = player:GetPosition()
            -- local target_pos = inst.sg.statemem.target_pos
            local target_pos = pt
            
            if target_pos == nil then
                local angle = player.Transform:GetRotation() * DEGREES
                target_pos = ipos + Vector3(OFFSET * math.cos(angle), 0, -OFFSET * math.sin(angle))
            end
            SpawnBeam(player, target_pos,onhitfn,workable_destroy_checker_fn)
        ---------------------------------------------------
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local COMBAT_RADIUS = 20  --- 战斗半径
    local musthavetags = {"_combat"}
    local canthavetags = {"companion","player", "brightmare", "playerghost", "INLIMBO","flight","chester","hutch","DECOR", "FX","structure","wall","engineering","eyeturret"}
    local musthaveoneoftags = nil

    local function GetTarget(inst)

        local x,y,z = inst.Transform:GetWorldPosition()
        local targets = {}
        local ents = TheSim:FindEntities(x,y,z,COMBAT_RADIUS,musthavetags,canthavetags,musthaveoneoftags)
        for k, temp in pairs(ents) do
            if temp and temp.components.combat and temp.components.health and not temp.components.health:IsDead() then
                -- ret_targets_with_ditance[temp] = temp:GetDistanceSqToPoint(x,y,z)
                table.insert(targets,temp)
            end
        end

        if #targets == 0 then
            return nil
        end
        -----------------------------------------------------------------
        --- 不攻击没敌意的目标
            local ret_targets_with_ditance = {}
            for k,temp in pairs(targets) do
                local temp_target = temp.components.combat.target
                -- and temp_target:HasOneOfTags({"player","companion","structure","wall"})
                if temp_target then
                    ret_targets_with_ditance[temp] = temp:GetDistanceSqToPoint(x,y,z)
                end
            end
        -----------------------------------------------------------------
        --- 优先攻击对玩家有敌意的单位
            local nearest_target = nil
            local nearest_distance = nil
            for k, v in pairs(ret_targets_with_ditance) do
                if nearest_target == nil or nearest_distance > v then
                    nearest_target = k
                    nearest_distance = v
                end
            end
        -----------------------------------------------------------------
        return nearest_target
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- combat and health
    local ignore_action = {
        [ACTIONS.CHOP] = true,
        [ACTIONS.HAMMER] = true,
        [ACTIONS.MINE] = true,
        [ACTIONS.DIG] = true,
    }
    local workable_destroy_checker_fn = function(target)
        -- print("workable_destroy_checker_fn",target)
        if ignore_action[target.components.workable:GetWorkAction()] then
            return false
        end
        if target:HasOneOfTags({"structure","engineering","wall","plant"}) then
            return false
        end
        return true
    end
    local function combat_install(inst)
        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(3000)
        --- 连接状态下每秒+10
        inst:DoPeriodicTask(10,function()
            if Is_In_Battery_Area(inst) then
                inst.components.health:DoDelta(10,true)
            end
        end)

        inst:AddComponent("combat")

        inst:DoPeriodicTask(TUNING.LORAMIA_DEBUGGING_MODE and 1 or 5,function()
            local is_in_battery_area,battery_node = Is_In_Battery_Area(inst)
            local target = GetTarget(inst)
            if target and is_in_battery_area and battery_node then
                battery_node.components.fueled:DoDelta(-1)

                local laser_on_hit_fn = function(target)
                    target.components.combat:GetAttacked(inst,200)
                end
                CreateLaser(inst,Vector3(target.Transform:GetWorldPosition()),laser_on_hit_fn,workable_destroy_checker_fn)

            end
        end)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- building
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, 1)

        inst.AnimState:SetBank("loramia_building_guardian_creation")
        inst.AnimState:SetBuild("loramia_building_guardian_creation")
        inst.AnimState:PlayAnimation("idle",true)

        inst:AddTag("structure")
        inst:AddTag("engineering")
        inst:AddTag("engineeringbatterypowered") 
        inst:AddTag("loramia_building_guardian_creation")

        inst:AddTag("companion")

        inst.entity:SetPristine()
        ----------------------------------------------------------
        -- 指示器安装
            indicator_setup(inst)
        ----------------------------------------------------------
        if not TheWorld.ismastersim then
            return inst
        end


        inst:AddComponent("inspectable")
        ----------------------------------------------------------
        --- 战斗控制系统
            combat_install(inst)
        ----------------------------------------------------------
        --- 电器节点系统
            circuitnode_setup(inst)
        ----------------------------------------------------------
        --- 挖除
            workable_install(inst)
        ----------------------------------------------------------

        MakeHauntableLaunch(inst)

        return inst
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

        inst.AnimState:SetBank("loramia_building_guardian_creation")
        inst.AnimState:SetBuild("loramia_building_guardian_creation")
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

return Prefab("loramia_building_guardian_creation", fn, assets),
    MakePlacer("loramia_building_guardian_creation_placer", "loramia_building_guardian_creation", "loramia_building_guardian_creation", "idle", nil, nil, nil, nil, nil, nil, placer_postinit_fn)

