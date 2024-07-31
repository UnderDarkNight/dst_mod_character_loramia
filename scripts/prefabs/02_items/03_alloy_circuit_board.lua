-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_item_alloy_circuit_board.zip"),
    Asset( "IMAGE", "images/inventoryimages/loramia_item_alloy_circuit_board.tex" ),
    Asset( "ATLAS", "images/inventoryimages/loramia_item_alloy_circuit_board.xml" ),
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 速度加速器 
    local speed_mult_inst = nil
    local function GetSpeedMultInst()
        if speed_mult_inst == nil or not speed_mult_inst:IsValid() then
            speed_mult_inst = CreateEntity()
        end
        return speed_mult_inst
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 坐标检查
    local function Check_Can_Deploy_At_Point(x,y,z)
        if TheWorld.Map:IsDockAtPoint(x,y,z) then
            return false
        end
        if TheWorld.Map:IsOceanIceAtPoint(x,y,z) then
            return false
        end
        if TheWorld.Map:IsOceanAtPoint(x,y,z) then
            return false
        end
        -- if not TheWorld.Map:IsLandTileAtPoint(x,y,z) then
        --     return true
        -- end
        return true
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 物品
    local function item_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("loramia_item_alloy_circuit_board")
        inst.AnimState:SetBuild("loramia_item_alloy_circuit_board")
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("deploykititem")

        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        -- inst.components.inventoryitem:ChangeImageName("bluegem")
        inst.components.inventoryitem.imagename = "loramia_item_alloy_circuit_board"
        inst.components.inventoryitem.atlasname = "images/inventoryimages/loramia_item_alloy_circuit_board.xml"
        inst.components.inventoryitem:SetSinks(true)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)

        ---------------------------------------------------------------------------------------------------
        --- 叠堆
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM
        ---------------------------------------------------------------------------------------------------
        ---
            inst:AddComponent("deployable")                
            inst.components.deployable.ondeploy = function(inst, pt, deployer)
                if pt and pt.x and Check_Can_Deploy_At_Point(pt.x,0,pt.z) then
                    local tx,ty = TheWorld.components.loramia_com_world_map_tile_sys:Get_Tile_XY_By_World_Point(pt)
                    if not TheWorld.components.loramia_com_world_map_tile_sys:Has_Tag_In_Tile_XY(tx,ty,"alloy_board") then
                        local fix_pt = TheWorld.components.loramia_com_world_map_tile_sys:Get_World_Point_By_Tile_XY(tx,ty)
                        SpawnPrefab("loramia_tile_alloy_circuit_board"):PushEvent("on_deploy",{pt = fix_pt})
                        inst.components.stackable:Get():Remove()
                    end
                end            
            end
            inst.components.deployable:SetDeployMode(DEPLOYMODE.WALL)
            inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.MEDIUM)
        ---------------------------------------------------------------------------------------------------
        MakeHauntableLaunch(inst)

        return inst
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 
    local function ground_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        -- inst.entity:AddMiniMapEntity()
        -- inst.MiniMapEntity:SetIcon("little_garden_natural_resources_paving_stones_map_icon.tex")
        -- inst.MiniMapEntity:SetPriority(-1)

        inst.AnimState:SetBank("loramia_item_alloy_circuit_board")
        inst.AnimState:SetBuild("loramia_item_alloy_circuit_board")
        inst.AnimState:PlayAnimation("turn_off")
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetSortOrder(0)

        -- inst:AddTag("NOCLICK")      --- 不可点击
        -- inst:AddTag("CLASSIFIED")   --  私密的，client 不可观测， FindEntity 默认过滤
        inst:AddTag("NOBLOCK")      -- 不会影响种植和放置
        -- inst:AddTag("little_garden_natural_resources_paving_stones")


        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        ---------------------------------------------------------------------------------------------
        --- 物品检查
            -- inst:AddComponent("inspectable")
        ---------------------------------------------------------------------------------------------
        --- 可敲打、掉落
            inst:AddComponent("lootdropper")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnFinishCallback(function()
                inst.components.lootdropper:SpawnLootPrefab("loramia_item_alloy_circuit_board")
                inst:Remove()
            end)
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
            -- inst.components.workable:SetOnWorkCallback(onhit)
        ---------------------------------------------------------------------------------------------
        --- 放置
            inst:ListenForEvent("on_deploy",function(_,_table)
                local pt = _table.pt
                inst.Transform:SetPosition(pt.x, pt.y, pt.z)
            end)
        ---------------------------------------------------------------------------------------------
        --- 
            inst.players_in_tile = {}
            local function add_player_2_list(player)
                table.insert(inst.players_in_tile,player)                
            end
            local function remove_player_from_list(player)
                local new_table = {}
                for i,v in ipairs(inst.players_in_tile) do
                    if v ~= player then
                        table.insert(new_table,v)
                    end
                end
                inst.players_in_tile = new_table
            end
            local function has_player_in_tile()
                return #inst.players_in_tile > 0
            end
            local function tile_color_switch()
                if has_player_in_tile() then
                    inst.AnimState:PlayAnimation("turn_on")
                else
                    inst.AnimState:PlayAnimation("turn_off")
                end
            end
            local function add_speed_mult(player)
                if player.components.locomotor then
	                player.components.locomotor:SetExternalSpeedMultiplier(GetSpeedMultInst(), "alloy_circuit_board",TUNING.LORAMIA_DEBUGGING_MODE and 2 or 1.2)
                end
            end
            local function remove_speed_mult(player)
                if player.components.locomotor then
                    if not TheWorld.components.loramia_com_world_map_tile_sys:Has_Tag_In_Point(Vector3(player.Transform:GetWorldPosition()),"alloy_circuit_board") then
                        player.components.locomotor:RemoveExternalSpeedMultiplier(GetSpeedMultInst(), "alloy_circuit_board")
                    end
                end
            end
            inst.__player_enter_tile_fn = function(player,tx,ty)
                -- print(" +++ player enter tile")
                add_player_2_list(player)
                tile_color_switch()
                add_speed_mult(player)
            end
            inst.__player_leave_tile_fn = function(player,tx,ty)
                -- print(" --- player leave tile")
                inst:DoTaskInTime(0,function()
                    remove_player_from_list(player)
                    tile_color_switch()
                    remove_speed_mult(player)
                end)
            end
            inst:DoTaskInTime(0,function()
                local tx,ty = TheWorld.components.loramia_com_world_map_tile_sys:Get_Tile_XY_By_World_Point(inst.Transform:GetWorldPosition())
                TheWorld.components.loramia_com_world_map_tile_sys:Add_Join_Event_Fn_To_Tile_XY(tx,ty,inst.__player_enter_tile_fn)
                TheWorld.components.loramia_com_world_map_tile_sys:Add_Leave_Event_Fn_To_Tile_XY(tx,ty,inst.__player_leave_tile_fn)
                TheWorld.components.loramia_com_world_map_tile_sys:Add_Tag_To_Tile_XY(tx,ty,"alloy_circuit_board")
                TheWorld.components.loramia_com_world_map_tile_sys:Add_Tag_To_Tile_XY(tx,ty,"alloy_board")
            end)
            inst:ListenForEvent("onremove",function()
                local tx,ty = TheWorld.components.loramia_com_world_map_tile_sys:Get_Tile_XY_By_World_Point(inst.Transform:GetWorldPosition())
                TheWorld.components.loramia_com_world_map_tile_sys:Remove_Join_Event_Fn_From_Tile_XY(tx,ty,inst.__player_enter_tile_fn)
                TheWorld.components.loramia_com_world_map_tile_sys:Remove_Leave_Event_Fn_From_Tile_XY(tx,ty,inst.__player_leave_tile_fn)
                TheWorld.components.loramia_com_world_map_tile_sys:Remove_Tag_From_Tile_XY(tx,ty,"alloy_circuit_board")
                TheWorld.components.loramia_com_world_map_tile_sys:Remove_Tag_From_Tile_XY(tx,ty,"alloy_board")
            end)
        ---------------------------------------------------------------------------------------------



        return inst
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- plcaer 
    local function placer_postinit_fn(inst)
        if inst.components.placer then
            inst.components.placer.snap_to_tile = true
            inst.components.placer.override_testfn = function(inst)
                local x,y,z = inst.Transform:GetWorldPosition()
                if Check_Can_Deploy_At_Point(x,y,z) then
                    return true
                else
                    return false
                end
            end
        end
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return Prefab("loramia_item_alloy_circuit_board", item_fn, assets),
    MakePlacer("loramia_item_alloy_circuit_board_placer", "loramia_item_alloy_circuit_board", "loramia_item_alloy_circuit_board", "yellow", true, nil, nil, nil, nil, nil, placer_postinit_fn, nil, nil),
    Prefab("loramia_tile_alloy_circuit_board", ground_fn, assets)
