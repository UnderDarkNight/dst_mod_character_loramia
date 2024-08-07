------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local assets =
    {
        Asset("ANIM", "anim/loramia_building_sacred_creation.zip"),
    }
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 参数表
    local AREA_RADIUS = 4*8
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 控制器
    local AllTileNodeController = {}
    function AllTileNodeController:AddNode(inst)
        self.nodes = self.nodes or {}
        self.nodes_index = self.nodes_index or {}
        if self.nodes_index[inst] then
            return
        end
        table.insert(self.nodes, inst)
        self.nodes_index[inst] = true

        inst:ListenForEvent("onremove",function()
            self.nodes_index[inst] = nil
            local new_table = {}
            for k, v in ipairs(self.nodes) do
                if v ~= inst then
                    table.insert(new_table, v)
                end
            end
            self.nodes = new_table
        end)
    end
    function AllTileNodeController:GetNearestNode(x,y,z,radius)
        self.nodes = self.nodes or {}
        radius = radius or 2
        local radius_sq = radius*radius
        for k, v in pairs(self.nodes) do
            if v and v:IsValid() and v:GetDistanceSqToPoint(x,y,z) <= radius_sq then
                return v
            end
        end
        return nil
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 获取地块坐标
    local function Get_Tile_Center_Pos(x, y, z, radius)
        local temp_tiles = {}
        while radius > 2 do
            -- 计算这一圈需要的点数
            -- local num_points = math.ceil(2 * math.pi * radius / 4)
            local num_points = math.ceil(2 * math.pi * radius / 4)*10
            
            local points = TUNING.LORAMIA_FN:GetSurroundPoints({
                target = Vector3(x, y, z),
                range = radius,
                num = num_points,
            })

            for k, temp_pt in ipairs(points) do
                local tx, ty = TheWorld.Map:GetTileXYAtPoint(temp_pt.x, 0, temp_pt.z)
                local index = tostring(tx) .. "_" .. tostring(ty)
                if not temp_tiles[index] then
                    temp_tiles[index] = {tx = tx, ty = ty}
                end
            end
            radius = radius - 3  -- 每个地块4x4，所以每次递减3
        end
        
        local ret_center_points = {}
        local ret_tiles = {}
        for k, temp_tile in pairs(temp_tiles) do
            local center_point = Vector3(TheWorld.Map:GetTileCenterPoint(temp_tile.tx, temp_tile.ty))
            table.insert(ret_center_points, center_point)
            table.insert(ret_tiles, {x = temp_tile.tx, y = temp_tile.ty})
        end        
        return ret_center_points,ret_tiles
    end

------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 下雨保护器
    local moisture_inst = nil
    local function GetMoistureInst()
        if moisture_inst == nil then
            moisture_inst = CreateEntity()
        end
        return moisture_inst
    end
    local function Moisture_Protecter_Active(player)
        if player.components.moisture then
            player.components.moisture:ForceDry(true,GetMoistureInst())
        end
    end
    local function Moisture_Protecter_Deactive(player)
        if player.components.moisture then
            player.components.moisture:ForceDry(false,GetMoistureInst())
        end
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 过热保护器
    local OVERHEAT_TEMPERATURE = 35
    local function Overheat_Protecter_Active(player)
        if player.loramia_building_sacred_creation_overheat_task or player.components.temperature == nil then
            return
        end
        player.loramia_building_sacred_creation_overheat_task = player:DoPeriodicTask(0.1, function()
            local current_temperature = player.components.temperature:GetCurrent()
            if current_temperature > OVERHEAT_TEMPERATURE then
                player.components.temperature:DoDelta(-(current_temperature - OVERHEAT_TEMPERATURE)/2)
            end
        end)
    end
    local function Overheat_Protecter_Deactive(player)
        if player.loramia_building_sacred_creation_overheat_task then
            player.loramia_building_sacred_creation_overheat_task:Cancel()
            player.loramia_building_sacred_creation_overheat_task = nil
        end
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 玩家出入地块触发函数
    local function tile_enter_fn(player,tx,ty)
        player.components.loramia_com_rpc_event:PushEvent("loramia_event.starry_night_filter",true)
        Overheat_Protecter_Active(player)
        Moisture_Protecter_Active(player)
    end
    local function tile_leave_fn(player,tx,ty)
        player:DoTaskInTime(0,function()
            local x,y,z = player.Transform:GetWorldPosition()
            if TheWorld.components.loramia_com_world_map_tile_sys:Has_Tag_In_Point(x,y,z,"sacred_creation") 
                or TheWorld.components.loramia_com_world_map_tile_sys:Has_Tag_In_Point(x,y,z,"sacred_creation_marker") then
                    return
            else
                player.components.loramia_com_rpc_event:PushEvent("loramia_event.starry_night_filter",false)
                Overheat_Protecter_Deactive(player)
                Moisture_Protecter_Deactive(player)
            end
        end)
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 初始化
    local function init_event_install(inst)
        inst:ListenForEvent("inited",function(inst)
            -----------------------------------------------------------------------------------
            ---- 获取属于自己的地块坐标
                local x, y, z = inst.Transform:GetWorldPosition()
                local tx,ty = TheWorld.Map:GetTileXYAtPoint(x, 0, z)
                local temp_center_points,temp_tiles = Get_Tile_Center_Pos(x, y, z, AREA_RADIUS)

                -- local ret_tiles = {}
                -- for k, temp_tile in ipairs(temp_tiles) do
                --     if temp_tile.x ~= tx and temp_tile.y ~= ty then
                --         table.insert(ret_tiles, temp_tile)
                --     end
                -- end
                -- local ret_center_points = {}
                -- for k, temp_center_point in ipairs(temp_center_points) do
                --     if temp_center_point.x ~= x and temp_center_point.z ~= z then
                --         table.insert(ret_center_points, temp_center_point)
                --     end
                -- end
            -----------------------------------------------------------------------------------
            --- 上玩家出入函数
                -- TheWorld.components.loramia_com_world_map_tile_sys:Add_Join_Event_Fn_To_Tile_XY(tx,ty,tile_enter_fn)
                -- TheWorld.components.loramia_com_world_map_tile_sys:Add_Leave_Event_Fn_To_Tile_XY(tx,ty,tile_leave_fn)
                -- inst:ListenForEvent("onremove",function(inst)
                --     TheWorld.components.loramia_com_world_map_tile_sys:Remove_Join_Event_Fn_From_Tile_XY(tx,ty,tile_enter_fn)
                --     TheWorld.components.loramia_com_world_map_tile_sys:Remove_Leave_Event_Fn_From_Tile_XY(tx,ty,tile_leave_fn)
                --     local players = TheSim:FindEntities(x,y,z,3,{"player"})
                --     for k, player in ipairs(players) do
                --         tile_leave_fn(player,tx,ty)
                --     end
                -- end)
                local tile = SpawnPrefab("loramia_building_sacred_creation_marker")
                tile:PushEvent("Set",{
                    pt = Vector3(x,y,z),
                })
                tile:DoTaskInTime(0.5,function()                    
                    TheWorld.components.loramia_com_world_map_tile_sys:Remove_Tag_From_Tile_XY(tx,ty,"sacred_creation_marker")
                end)
                inst:ListenForEvent("onremove",function(inst)
                    tile:Remove()
                end)
            -----------------------------------------------------------------------------------
            --- 上标记
                TheWorld.components.loramia_com_world_map_tile_sys:Add_Tag_To_Tile_XY(tx,ty,"sacred_creation") -- 属于自己的位置上tag
                inst:ListenForEvent("onremove",function(inst)
                    TheWorld.components.loramia_com_world_map_tile_sys:Remove_Tag_From_Tile_XY(tx,ty,"sacred_creation") -- 移除自己的tag
                end)
            -----------------------------------------------------------------------------------
            --- 
            -----------------------------------------------------------------------------------
            --- 子节点 标记
                inst.child_nodes = {}
                local refresh_task = nil
                inst:ListenForEvent("link",function(inst,temp_node) --- marker的链接返回事件
                    inst.child_nodes[temp_node] = true
                    if refresh_task == nil then
                        refresh_task = inst:DoTaskInTime(0,function()
                            refresh_task = nil
                            local new_table = {}
                            for tempInst, flag in pairs(inst.child_nodes) do
                                if tempInst:IsValid() then
                                    new_table[tempInst] = true
                                end
                            end
                            inst.child_nodes = new_table
                        end)
                    end
                end)
            -----------------------------------------------------------------------------------
            -- 给水果生成位置上marker inst 。使用标记 inst 控制生成
                for k, temp_pt in pairs(temp_center_points) do
                    if TheWorld.components.loramia_com_world_map_tile_sys:Has_Tag_In_Point(temp_pt,"sacred_creation") 
                        or TheWorld.components.loramia_com_world_map_tile_sys:Has_Tag_In_Point(temp_pt,"sacred_creation_marker") then
                        -- print("有标记")
                    else
                        local temp_marker = SpawnPrefab("loramia_building_sacred_creation_marker") -- 生成标记
                        temp_marker:PushEvent("Set",{
                            pt = temp_pt,
                            father = inst,
                        })
                    end
                end
                inst:ListenForEvent("onremove",function(inst) --- 树木移除的。用来处理多棵树重复覆盖的问题。
                    for tempInst, flag in pairs(inst.child_nodes) do
                        local tempPT = Vector3(tempInst.Transform:GetWorldPosition())
                        local ents = TheSim:FindEntities(tempPT.x,0,tempPT.z,AREA_RADIUS+2,{"loramia_building_sacred_creation"})
                        if #ents == 0 then
                            tempInst:Remove()
                        else
                            tempInst:PushEvent("Set",{father = ents[1]}) --- 重新绑定给另外一个父节点。
                        end
                    end 
                end)
            -----------------------------------------------------------------------------------
            --- 
                inst.ret_tile_center_points = temp_center_points
                inst.ret_tiles = temp_tiles
            -----------------------------------------------------------------------------------
            --- 
            -----------------------------------------------------------------------------------            

        end)
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- workable
    local function OnFinishCallback(inst,worker)
        for i = 1, 10, 1 do
            inst.components.lootdropper:SpawnLootPrefab("loramia_item_alloy_circuit_board")            
        end
        for i = 1, 2, 1 do
            inst.components.lootdropper:SpawnLootPrefab("loramia_item_luminous_alloy_board")            
        end
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
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- building
    local function building_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddLight()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()
    
        MakeObstaclePhysics(inst, 1)    

    
        inst.MiniMapEntity:SetIcon("loramia_building_sacred_creation.tex")
    
        inst.AnimState:SetBank("loramia_building_sacred_creation")
        inst.AnimState:SetBuild("loramia_building_sacred_creation")
        inst.AnimState:PlayAnimation("idle",true)
    
        inst:AddTag("structure")
        inst:AddTag("loramia_building_sacred_creation")

        inst.entity:SetPristine()
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
            workable_install(inst)
        -----------------------------------------------------------
        --- 
            inst:AddComponent("lootdropper")
        -----------------------------------------------------------
        --- 修正自己的坐标
            inst:DoTaskInTime(0,function(inst)
                local tx, ty = TheWorld.Map:GetTileXYAtPoint(inst.Transform:GetWorldPosition())
                local x,y,z = TheWorld.Map:GetTileCenterPoint(tx, ty)
                inst.Transform:SetPosition(x,y,z)
                inst:PushEvent("inited")
            end)
        -----------------------------------------------------------
        --- 初始化
            init_event_install(inst)
        -----------------------------------------------------------
        --- 水果生成逻辑
            local fn = require("prefabs/06_buildings/09_sacred_creation_fruit_spawn_logic")
            if type(fn) == "function" then
                fn(inst)
            end
        -----------------------------------------------------------
        -- 
            inst.AllTileNodeController = AllTileNodeController
        -----------------------------------------------------------
        -- 雨水屏蔽 （会产生屏蔽圈圈）
            -- inst:AddComponent("raindome")
            -- inst.components.raindome:SetRadius(AREA_RADIUS)
            -- inst.components.raindome:Enable()
        -----------------------------------------------------------
        --- 屏蔽雷击
            inst:AddComponent("lightningblocker")
            inst.components.lightningblocker:SetBlockRange(AREA_RADIUS)
            -- inst.components.lightningblocker:SetOnLightningStrike(OnLightningStrike)
        -----------------------------------------------------------

        return inst
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- placer post init
    local function placer_postinit_fn(inst)
        if inst.components.placer then
            inst.components.placer.snap_to_tile = true
            inst.components.placer.override_testfn = function(inst)
                -- -- print("+++++++++++",inst.Transform:GetWorldPosition())
                -- local x,y,z = inst.Transform:GetWorldPosition()
                return true
            end
        end
        inst.fx = {}
        local ret_center_points,_ = Get_Tile_Center_Pos(0,0,0,AREA_RADIUS)
        -- print("#######",#ret_center_points)
        for k, temp_pt in pairs(ret_center_points) do            
            local temp_fx = inst:SpawnChild("loramia_sfx_tile_outline")
            temp_fx:PushEvent("Set",{
                MultColour_Flag = true,
                pt = temp_pt,
                color = Vector3(1,1,1),
                a = 0.2,
            })
        end
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 地块 marker

    local function tile_marker_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddLight()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst:AddTag("NOCLICK")
        inst:AddTag("FX")
        inst:AddTag("NOBLOCK")
        inst:AddTag("CLASSIFIED")
        inst:AddTag("INLIMBO")
        inst:AddTag("loramia_building_sacred_creation_marker")

        -- inst.AnimState:SetBank("cane")
        -- inst.AnimState:SetBuild("swap_cane")
        -- inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetBank("loramia_building_sacred_creation")
        inst.AnimState:SetBuild("loramia_building_sacred_creation")
        -- inst.AnimState:PlayAnimation("tile")
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetSortOrder(-1)
        -- inst.AnimState:SetMultColour(1,1,1,0.5)

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst.AnimState:PlayAnimation("tile"..math.random(6),true)
        inst.AnimState:SetTime(5*math.random(10000)/10000)
        inst.AnimState:SetScale(1.5,1.5,1.5)

        inst:ListenForEvent("Set",function(inst,_table)
            
            -------------------------------------------------------------------------------------
            --- 坐标
                local pt = _table.pt
                if pt then
                    inst.Transform:SetPosition(pt.x,0,pt.z)
                    TheWorld.components.loramia_com_world_map_tile_sys:Add_Tag_To_Tile_By_Point(pt,"sacred_creation_marker")
                    inst:ListenForEvent("onremove",function(inst)
                        TheWorld.components.loramia_com_world_map_tile_sys:Remove_Tag_From_Tile_By_Point(pt,"sacred_creation_marker")
                    end)
                end
            -------------------------------------------------------------------------------------
            --- 连接给父节点
                if _table.father then
                    _table.father:PushEvent("link",inst)
                end
            -------------------------------------------------------------------------------------

            inst.Ready = true
        end)
        -------------------------------------------------------------------------------------
        ---- 初始化
            inst:DoTaskInTime(0,function()
                if not inst.Ready then
                    inst:Remove()
                    return
                end
                local x,y,z = inst.Transform:GetWorldPosition()
                local tx,ty = TheWorld.Map:GetTileXYAtPoint(x,y,z)
                TheWorld.components.loramia_com_world_map_tile_sys:Add_Join_Event_Fn_To_Tile_XY(tx,ty,tile_enter_fn)
                TheWorld.components.loramia_com_world_map_tile_sys:Add_Leave_Event_Fn_To_Tile_XY(tx,ty,tile_leave_fn)
                inst:ListenForEvent("onremove",function(inst)
                    TheWorld.components.loramia_com_world_map_tile_sys:Remove_Join_Event_Fn_From_Tile_XY(tx,ty,tile_enter_fn)
                    TheWorld.components.loramia_com_world_map_tile_sys:Remove_Leave_Event_Fn_From_Tile_XY(tx,ty,tile_leave_fn)
                    -----------------------------------------------------------------
                    ---- 在当前地块的玩家直接触发事件
                        local players = TheSim:FindEntities(x,y,z,3,{"player"})
                        for k, player in ipairs(players) do
                            tile_leave_fn(player,tx,ty)
                        end
                    -----------------------------------------------------------------
                end)
                -----------------------------------------------------------------
                ---- 在当前地块的玩家直接触发事件
                    local players = TheSim:FindEntities(x,y,z,3,{"player"})
                    for k, player in ipairs(players) do
                        tile_enter_fn(player,tx,ty)
                    end
                -----------------------------------------------------------------
            end)
        -------------------------------------------------------------------------------------
        ---- 生成水果
            inst:ListenForEvent("spawn_fruit",function(inst)
                local fruit_node = inst.fruit_node
                if not (fruit_node == nil or not fruit_node:IsValid()) then
                    return
                end
                local x,y,z = inst.Transform:GetWorldPosition()
                local offset_x = math.random(-20,20)/10
                local offset_z = math.random(-20,20)/10
                SpawnPrefab("loramia_building_sacred_creation_fruit"):PushEvent("Set",{
                    pt = Vector3(x+offset_x,y,z+offset_z),
                    father = inst,
                })
            end)
            inst:ListenForEvent("onremove",function(inst)
                if inst.fruit_node and inst.fruit_node:IsValid() then
                    inst.fruit_node:PushEvent("fall")
                end
            end)
        -------------------------------------------------------------------------------------
        ----
            inst.AllTileNodeController = AllTileNodeController
            AllTileNodeController:AddNode(inst)
        -------------------------------------------------------------------------------------
        return inst
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
return Prefab("loramia_building_sacred_creation", building_fn, assets)
    ,MakePlacer("loramia_building_sacred_creation_placer", "loramia_building_sacred_creation", "loramia_building_sacred_creation", "idle", nil, nil, nil, nil, nil, nil, placer_postinit_fn, nil, nil)
    ,Prefab("loramia_building_sacred_creation_marker", tile_marker_fn, assets)
