------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    玩家进入 新一块地皮的时候，pushevent

    配合另外一个地图tag组件，触发对应地皮 enter 事件

]]--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddComponentPostInit("areaaware", function(self)
    --------------------------------------------------------------------------------------
        if not TheWorld.ismastersim then
            return
        end        
    --------------------------------------------------------------------------------------
    --- 参数
        self.loramia_last_tile_mid_pt_x = nil
        self.loramia_last_tile_mid_pt_z = nil
        self.loramia_last_tile_x = nil
        self.loramia_last_tile_y = nil
    --------------------------------------------------------------------------------------
    local old_UpdatePosition = self.UpdatePosition
    self.UpdatePosition = function(self,...)
        --------------------------------------------------------------------------------------
        ----
            local x,y,z = self.inst.Transform:GetWorldPosition()
            x,y,z = TheWorld.Map:GetTileCenterPoint(x,y,z)
            if self.loramia_last_tile_mid_pt_x ~= x or self.loramia_last_tile_mid_pt_z ~= z then
                local crash_flag,crash_reason =  pcall(function() --- 某些地图外做空间的MOD会造成崩溃，只能用pcall                    
                    local node_index = TheWorld.Map:GetNodeIdAtPoint(x, 0, z) or 0                
                    local node = TheWorld.topology.nodes[node_index] or {}
                    local tx, ty = TheWorld.Map:GetTileXYAtPoint(x,y,z)
                    local current_tile = TheWorld.Map:GetTileAtPoint(x,y,z) -- 地皮
                    self.inst:PushEvent("loramia_event.enter_new_tile",{
                        node_index = node_index,
                        tags = node.tags or {},
                        type = node.type,
                        center = node.cent,
                        tx = tx, -- 地块
                        ty = ty, -- 地块
                        tile = current_tile, --
                    })
                    -------------------------------------------------------------------------------
                    ----- 触发自制 event 组件
                        TheWorld.components.loramia_com_world_map_tile_sys:Active_Leave_Fns_By_Tile_XY(self.inst,self.loramia_last_tile_x or 0,self.loramia_last_tile_y or 0)
                        TheWorld.components.loramia_com_world_map_tile_sys:Active_Join_Fns_By_Tile_XY(self.inst,tx,ty)

                    -------------------------------------------------------------------------------
                    self.loramia_last_tile_mid_pt_x = x
                    self.loramia_last_tile_mid_pt_z = z
                    self.loramia_last_tile_x = tx
                    self.loramia_last_tile_y = ty
                end)
                if not crash_flag then
                    print("error in 02_areaaware")
                    print(crash_reason)
                end
            end
        --------------------------------------------------------------------------------------
        return old_UpdatePosition(self,...)
    end
end)