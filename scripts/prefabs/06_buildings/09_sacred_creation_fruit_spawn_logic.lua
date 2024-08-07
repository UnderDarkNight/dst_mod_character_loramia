------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

每5天在穹顶范围内任意一格位置垂下1个采集点，
上有可采集物“增殖的创造物”，若摘下，
则5天后重新长出，若不摘下，则“增值的创造物”在天亮时在范围内附近增殖一个采集点，

]]--
------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local TreeHasFruit = function(inst)
        inst.child_nodes = inst.child_nodes or {}
        for tile_node, v in pairs(inst.child_nodes) do
            if tile_node and tile_node.fruit_node and tile_node.fruit_node:IsValid() then
                return true
            end
        end
        return false
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 刷新水果
    local SpawnFruit = function(inst)
        inst.child_nodes = inst.child_nodes or {}
        local tile_nodes = {}
        for temp_node, v in pairs(inst.child_nodes) do
            if temp_node.fruit_node == nil or not temp_node.fruit_node:IsValid() then
                table.insert(tile_nodes, temp_node)
            end
        end
        if #tile_nodes == 0 then
            return
        end
        local ret_tile_node = tile_nodes[math.random(#tile_nodes)]
        if ret_tile_node then
            ret_tile_node:PushEvent("spawn_fruit")
            inst.components.loramia_data:Set("fruit_spawn_cd_day",0)
            if TUNING.LORAMIA_DEBUGGING_MODE then
                print(" +++++++++++ tree spawn fruit ++++++++++++++ ")
            end
        end
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
return function(inst)
    
    inst:WatchWorldState("cycles",function()
        


        if TreeHasFruit(inst) then
            ------- 如果已经有水果存在，则继续新增水果
            SpawnFruit(inst)
            return
        end

        ------- 如果没有水果存在，计数5天后新增水果
        if inst.components.loramia_data:Add("fruit_spawn_cd_day",1) >= 5 then
            SpawnFruit(inst)
        end


    end)
    
end