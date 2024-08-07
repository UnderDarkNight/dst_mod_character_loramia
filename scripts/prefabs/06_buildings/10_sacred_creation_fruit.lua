-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[



]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_building_sacred_creation_fruit.zip"),
}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- animstate 
    local function animstate_switch_event_setup(inst)
        -----------------------------------------------------------------------
        --- 水果状态刷新
            inst:ListenForEvent("fruit_fresh",function()
                if inst:HasTag("has_fruit") then
                    inst.AnimState:PlayAnimation("idle_fruit",true)
                else
                    inst.AnimState:PlayAnimation("idle_nofruit",true)
                end
            end)
        -----------------------------------------------------------------------
        --- 刷新的时候播放动画
            inst:ListenForEvent("new_spawn",function()
                inst.AnimState:PlayAnimation("spawn")
                inst.AnimState:PushAnimation("idle_fruit",true)
                inst:AddTag("has_fruit")
            end)
        -----------------------------------------------------------------------
        --- fruit_grow 水果生长
            inst:ListenForEvent("fruit_grow",function()
                inst.AnimState:PlayAnimation("fruit_grow")
                inst.AnimState:PushAnimation("idle_fruit",true)
                inst:AddTag("has_fruit")
            end)
        -----------------------------------------------------------------------
        ---  掉落
            inst:ListenForEvent("fall",function()
                inst:AddTag("INLIMBO")
                inst:AddTag("CLASSIFIED")
                inst:AddTag("NOCLICK")
                inst:AddTag("INLIMBO")
                inst:AddTag("FX")

                local x,y,z = inst.Transform:GetWorldPosition()
                if TheWorld.Map:IsOceanAtPoint(x,y,z) or not TheWorld.Map:IsPassableAtPoint(x,y,z) then --- 海洋或者虚空
                    inst.AnimState:PlayAnimation("fall_ocean")
                else
                    inst.AnimState:PlayAnimation("fall_land")
                end

                if inst:HasTag("has_fruit") then
                    inst.AnimState:Show("FRUIT")
                else
                    inst.AnimState:Hide("FRUIT")
                end
                -- inst:ListenForEvent("animover",function()
                --     inst.components.lootdropper:SpawnLootPrefab("trinket_6")
                --     inst:Remove()
                -- end)
                inst:DoTaskInTime(1,function()
                    inst.components.lootdropper:SpawnLootPrefab("trinket_6")
                    inst:Remove()
                end)
            
            end)
        -----------------------------------------------------------------------
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- workable
    local axe_equipment_tag = ACTIONS.CHOP.id.."_tool"
    local function has_axe(doer)
        return doer.replica.inventory:EquipHasTag( axe_equipment_tag )
    end
    local function workable_install(inst)
        inst:ListenForEvent("Loramia_OnEntityReplicated.loramia_com_workable",function(inst,replica_com)
            replica_com:SetSGAction("give")
            replica_com:SetText("loramia_building_sacred_creation_fruit",STRINGS.ACTIONS.PICK.HARVEST)
            replica_com:SetTestFn(function(inst,doer,right_click)
                if has_axe(doer) and not inst:HasTag("has_fruit") then
                    replica_com:SetText("loramia_building_sacred_creation_fruit",STRINGS.ACTIONS.CHOP)
                    replica_com:SetSGAction("chop")
                    return true
                else
                    replica_com:SetText("loramia_building_sacred_creation_fruit",STRINGS.ACTIONS.PICK.HARVEST)
                    replica_com:SetSGAction("give")
                    if inst:HasTag("has_fruit") then
                        return true
                    end
                end
                return false
            end)
        end)
        if not TheWorld.ismastersim then
            return
        end
        inst:AddComponent("loramia_com_workable")
        inst.components.loramia_com_workable:SetOnWorkFn(function(inst,doer)
            if has_axe(doer) and not inst:HasTag("has_fruit") then
                ----------------------------------------------------------------------------------------------
                ---
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
                    inst:PushEvent("fall")
                ----------------------------------------------------------------------------------------------
            else
                ----------------------------------------------------------------------------------------------
                --- 采集
                    inst.components.loramia_data:Set("has_fruit",false)
                    inst:RemoveTag("has_fruit")
                    inst:PushEvent("fruit_fresh")
                    -----------------------------------------------
                    --- 采集
                        -- doer.components.inventory:GiveItem(SpawnPrefab("log"))
                        SpawnPrefab("loramia_item_sacred_creation_fruit").Transform:SetPosition(inst.Transform:GetWorldPosition())
                    -----------------------------------------------
                ----------------------------------------------------------------------------------------------
            end
            return true
        end)
        inst.components.loramia_data:AddOnLoadFn(function()
            if inst.components.loramia_data:Get("has_fruit") then
                inst:AddTag("has_fruit")
                inst:PushEvent("fruit_fresh")
            end
        end)
        inst.components.loramia_data:AddOnSaveFn(function()
            if inst:HasTag("has_fruit") then
                inst.components.loramia_data:Set("has_fruit",true)
            end
        end)
        inst:DoTaskInTime(0,function(inst)
            inst:PushEvent("fruit_fresh")            
        end)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- cmd event 控制器事件
    local function control_event_install(inst)
        ------------------------------------------------------------------------
        --- 生成设置器
            inst:ListenForEvent("Set",function(inst,_table)
                _table = _table or {
                    -- pt = Vector3(0,0,0),
                    -- father = inst,
                }
                if _table.pt then
                    inst.Transform:SetPosition(_table.pt.x,0,_table.pt.z)
                end
                if _table.father then
                    inst.father_node = _table.father
                    _table.father.fruit_node = inst
                end
                inst:PushEvent("new_spawn")
            end)
        ------------------------------------------------------------------------
        --- 重新连接到父亲节点
            local get_father_node = function(inst)
                local x,y,z = inst.Transform:GetWorldPosition()
                local tree = TheSim:FindFirstEntityWithTag("loramia_building_sacred_creation") 
                if tree and tree.AllTileNodeController then
                    local nearest_tile_node = tree.AllTileNodeController:GetNearestNode(x,y,z,2)
                    return nearest_tile_node
                end
                return nil
            end
            inst:DoTaskInTime(0.5,function(inst)
                if inst.father_node then
                    return
                end

                local father_node = get_father_node(inst)
                if father_node then
                    inst.father_node = father_node
                    inst.father_node.fruit_node = inst
                else
                   inst:Remove()
                --    print("fake error fruit_node remove") 
                end
            end)
        ------------------------------------------------------------------------
        --- 果子重新生长
            inst:WatchWorldState("cycles",function()
                if not inst:HasTag("has_fruit") then
                    if inst.components.loramia_data:Add("fruit_grow_days",1) >= ( TUNING.LORAMIA_DEBUGGING_MODE and 1 or 5) then
                        inst:PushEvent("fruit_grow")
                    end
                else
                    inst.components.loramia_data:Set("fruit_grow_days",0)                    
                end
            end)
        ------------------------------------------------------------------------

    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----- 灯光组件
    -- local INTENSITY = .5
    local INTENSITY = .9

    local function randomizefadein()
        return math.random(1, 31)
    end

    local function randomizefadeout()
        return math.random(32, 63)
    end

    local function immediatefadeout()
        return 0
    end

    local function resolvefaderate(x)
        --immediate fadeout -> 0
        --randomize fadein -> INTENSITY * FRAMES / (3 + math.random() * 2)
        --randomize fadeout -> -INTENSITY * FRAMES / (.75 + math.random())
        return (x == 0 and 0)
            or (x < 32 and INTENSITY * FRAMES / (3 + (x - 1) / 15))
            or INTENSITY * FRAMES / ((32 - x) / 31 - .75)
    end
    local function updatefade(inst, rate)
        inst._fadeval:set_local(math.clamp(inst._fadeval:value() + rate, 0, INTENSITY))

        --Client light modulation is enabled:
        inst.Light:SetIntensity(inst._fadeval:value())

        if rate == 0 or
            (rate < 0 and inst._fadeval:value() <= 0) or
            (rate > 0 and inst._fadeval:value() >= INTENSITY) then
            inst._fadetask:Cancel()
            inst._fadetask = nil
            if inst._fadeval:value() <= 0 and TheWorld.ismastersim then
                -- inst:AddTag("NOCLICK")
                inst.Light:Enable(false)
            end
        end
    end

    local function fadein(inst)
        local ismastersim = TheWorld.ismastersim
        if not ismastersim or resolvefaderate(inst._faderate:value()) <= 0 then
            if ismastersim then
                -- inst:RemoveTag("NOCLICK")
                inst.Light:Enable(true)
                -- inst.AnimState:PlayAnimation("swarm_pre")
                -- inst.AnimState:PushAnimation("swarm_loop", true)
                inst._faderate:set(randomizefadein())
            end
            if inst._fadetask ~= nil then
                inst._fadetask:Cancel()
            end
            local rate = resolvefaderate(inst._faderate:value()) * math.clamp(1 - inst._fadeval:value() / INTENSITY, 0, 1)
            inst._fadetask = inst:DoPeriodicTask(FRAMES, updatefade, nil, rate)
            if not ismastersim then
                updatefade(inst, rate)
            end
        end
    end

    local function fadeout(inst)
        local ismastersim = TheWorld.ismastersim
        if not ismastersim or resolvefaderate(inst._faderate:value()) > 0 then
            if ismastersim then
                -- inst.AnimState:PlayAnimation("swarm_pst")
                inst._faderate:set(randomizefadeout())
            end
            if inst._fadetask ~= nil then
                inst._fadetask:Cancel()
            end
            local rate = resolvefaderate(inst._faderate:value()) * math.clamp(inst._fadeval:value() / INTENSITY, 0, 1)
            inst._fadetask = inst:DoPeriodicTask(FRAMES, updatefade, nil, rate)
            if not ismastersim then
                updatefade(inst, rate)
            end
        end
    end

    local function OnFadeRateDirty(inst)
        local rate = resolvefaderate(inst._faderate:value())
        if rate > 0 then
            fadein(inst)
        elseif rate < 0 then
            fadeout(inst)
        elseif inst._fadetask ~= nil then
            inst._fadetask:Cancel()
            inst._fadetask = nil
            inst._fadeval:set_local(0)

            --Client light modulation is enabled:
            inst.Light:SetIntensity(0)
        end
    end

    local function updatelight(inst)
        if TheWorld.state.isnight then
            fadein(inst)
        else
            fadeout(inst)
        end
    end
    local function OnIsNight(inst)
        inst:DoTaskInTime(2 + math.random(), updatelight)
    end
    local function light_event_install(inst)
        inst._fadeval = net_float(inst.GUID, "fireflies._fadeval")
        inst._faderate = net_smallbyte(inst.GUID, "fireflies._faderate", "onfaderatedirty")
        inst._fadetask = nil
        if not TheWorld.ismastersim then
            return
        end
        inst:WatchWorldState("isnight", OnIsNight)
        OnIsNight(inst)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("loramia_building_sacred_creation_fruit")
    -- inst.AnimState:SetBank("oceanvine")
    inst.AnimState:SetBuild("loramia_building_sacred_creation_fruit")
    -- inst.AnimState:PlayAnimation("idle",true)

    inst.entity:AddLight()
    -- inst.Light:SetFalloff(1)
    inst.Light:SetFalloff(0.3)
    inst.Light:SetIntensity(0)
    inst.Light:SetRadius(2)
    inst.Light:SetColour(150/255, 255/255, 255/255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)


    inst:AddTag("structure")
    inst:AddTag("NOBLOCK")      -- 不会影响种植和放置
    inst:AddTag("flying")

    inst.entity:SetPristine()
    -----------------------------------------------------------
    --- 
        animstate_switch_event_setup(inst)
    -----------------------------------------------------------
    --- 
        if TheWorld.ismastersim then
            inst:AddComponent("loramia_data")
        end
    -----------------------------------------------------------
    ---
        workable_install(inst)
    -----------------------------------------------------------
    ---- 灯光
        light_event_install(inst)
    -----------------------------------------------------------

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
    ---
        control_event_install(inst)
    -----------------------------------------------------------
    ---
    -----------------------------------------------------------
    return inst
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return Prefab("loramia_building_sacred_creation_fruit", fn, assets)