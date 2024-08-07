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
                        doer.components.inventory:GiveItem(SpawnPrefab("log"))
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
    return inst
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return Prefab("loramia_building_sacred_creation_fruit", fn, assets)