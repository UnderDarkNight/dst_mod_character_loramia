------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    间隔1天重置计数器

]]--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 
    local DAILY_SPAWN_NUM = 3 --- 每天最多生成3个飞船碎片
    AddPrefabPostInit("world",function(inst)        
        if not TheWorld.ismastersim then
            return
        end
        ---------------------------------------------------------------------------------------------
        ---
            if inst.components.loramia_data == nil then
                inst:AddComponent("loramia_data")
            end
        ---------------------------------------------------------------------------------------------
        ---
            inst:WatchWorldState("cycles",function()
                TheWorld.components.loramia_data:Set("spaceship_debris_num",0)
            end)
        ---------------------------------------------------------------------------------------------
        ---
           inst:ListenForEvent("loramia_event.shadowmeteor_explode",function(inst,pt)
                local ents = TheSim:FindEntities(pt.x,0,pt.z,0.5,{"boulder"})
                if #ents > 0 then -- 砸到的区域已经有其他逻辑生成的石头了，则不生成飞船碎片
                    return
                end
                if inst.components.loramia_data:Add("spaceship_debris_num",0) < DAILY_SPAWN_NUM and math.random() < 0.3 then
                    SpawnPrefab("loramia_building_spaceship_debris").Transform:SetPosition(pt.x,0,pt.z)
                    inst.components.loramia_data:Add("spaceship_debris_num",1)
                end
           end,TheWorld)
        ---------------------------------------------------------------------------------------------        
    end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 陨石
    AddPrefabPostInit("shadowmeteor",function(inst)        
        if not TheWorld.ismastersim then
            return
        end
        ---------------------------------------------------------------------------------------------
        inst:DoTaskInTime(1.33+0.1,function()
            TheWorld:PushEvent("loramia_event.shadowmeteor_explode",Vector3(inst.Transform:GetWorldPosition()))
        end)
        ---------------------------------------------------------------------------------------------        
    end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

