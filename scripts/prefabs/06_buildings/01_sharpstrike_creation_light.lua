-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    红宝石：让探照范围升温，效率按篝火最大火为准
    蓝宝石：让探照范围降温，效率按冰篝火最大火为准
    黄宝石：改为半径5格的范围照亮
    紫宝石：优先探照猪人，其次再探照玩家，范围内玩家每分钟下降500san，猪人会发疯。
    绿宝石：范围内玩家每秒回复5生命、5san
    铥矿/铥矿碎片：范围内玩家每3次受到攻击就能触发一次铥矿皇冠的免伤效果。
    月石：让花变成草簇，杀死光圈范围内的影怪，让猪和狗变成月石雕塑


]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets = {}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local LIGHT_RADIUS = 2
    local LIGHT_RADIUS_SQ = LIGHT_RADIUS * LIGHT_RADIUS
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local light_type_fn = {
        -------------------------------------------------------------------------------------------
        ["nil"] = function(inst)
            -- print("info switich to nil")            
        end,
        -------------------------------------------------------------------------------------------
        ["redgem"] = function(inst)
            -- 红宝石：让探照范围升温，效率按篝火最大火为准
            -- print("info switich to redgem")
            inst.components.heater.heatfn = function(inst)
                return 100
            end
            inst.components.heater:SetThermics(true, false)
        end,
        -------------------------------------------------------------------------------------------
        ["bluegem"] = function(inst)
            -- 蓝宝石：让探照范围降温，效率按冰篝火最大火为准
            -- print("info switich to bluegem")
            inst.Light:SetColour(0 / 255, 255 / 255, 255 / 255)
            inst.components.heater.heatfn = function(inst)
                return -100
            end
            inst.components.heater:SetThermics(false, true)
        end,
        -------------------------------------------------------------------------------------------
        ["yellowgem"] = function(inst)
            --- 黄宝石：改为半径5格的范围照亮
            -- print("info switich to yellowgem")
            inst.Light:SetRadius(20)            
        end,
        -------------------------------------------------------------------------------------------
        ["purplegem"] = function(inst)
            -- 紫宝石：优先探照猪人，其次再探照玩家，范围内玩家每分钟下降500san，猪人会发疯。
            -- print("info switich to purplegem")
            ------------------------------------------------------------------
            -- 参数

            ------------------------------------------------------------------
            --- 创建掉 San 控制器
                local san_controller = inst:SpawnChild("loramia_building_sharpstrike_creation_light_sanityaura")
                san_controller.components.sanityaura.GetAura = function(self,player)
                    if player and self.inst:GetDistanceSqToInst(player) < LIGHT_RADIUS_SQ then
                        return -(TUNING.SANITYAURA_MED/4)*50
                    end
                    return 0
                end
                san_controller.Ready = true
                inst.san_controller = san_controller
            ------------------------------------------------------------------
            --- 创建疯猪控制器
                inst.__light_task = inst:DoPeriodicTask(1,function()
                    local x,y,z = inst.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x,y,z,LIGHT_RADIUS, {"pig"},{"werepig"})
                    for k, temp_target in pairs(ents) do
                        if temp_target and temp_target.components.werebeast then
                            if not temp_target.components.werebeast:IsInWereState() then
                                temp_target.components.werebeast:TriggerDelta(3)
                            end
                        end
                    end
                end)
            ------------------------------------------------------------------
        end,
        -------------------------------------------------------------------------------------------
        ["greengem"] = function(inst)
            -- 绿宝石：范围内玩家每秒回复5生命、5san
            -- print("info switich to greengem")
            inst.__light_task = inst:DoPeriodicTask(1,function(inst)
                local x,y,z = inst.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x,y,z,LIGHT_RADIUS, {"player"},{"playerghost"})
                for k, player in pairs(ents) do
                    if player then
                        if player.components.health then
                            player.components.health:DoDelta(5,true)
                        end
                        if player.components.sanity then
                            player.components.sanity:DoDelta(5,true)
                        end
                    end
                end
            end)
        end,
        -------------------------------------------------------------------------------------------
        ["thulecite"] = function(inst)   -- 丢矿
            -- 铥矿/铥矿碎片：范围内玩家每3次受到攻击就能触发一次铥矿皇冠的免伤效果。
            inst.__sheild_count = inst.__sheild_count or {}
            inst.__sheild_tasks = inst.__sheild_tasks or {}
            inst.__sheild_fx = inst.__sheild_fx or {}
            inst.___thulecite_fn_in_player = inst.___thulecite_fn_in_player or function(player,attacker, damage, weapon, stimuli, spdamage) -- 挂载到玩家身上，每次被攻击都会执行
                if damage > 0 then
                    local index = tostring(player.userid)
                    inst.__sheild_count[index] = (inst.__sheild_count[index] or 0) + 1  --- 计数
                    if inst.__sheild_count[index] == 4 then  -- 够3次,上计时任务和特效。
                        inst.__sheild_tasks[index] = player:DoTaskInTime(3,function(player)
                            inst.__sheild_tasks[index] = nil
                            inst.__sheild_count[index] = 0
                            -- inst.__sheild_fx[index]:Remove()
                            inst.__sheild_fx[index]:kill_fx()
                        end)
                        local fx = player:SpawnChild("forcefieldfx")
                        fx.Transform:SetPosition(0,0.2,0)
                        inst.__sheild_fx[index] = fx
                    end
                    if inst.__sheild_tasks[index] then -- 计时任务存在期间，免疫任何伤害
                        inst.__sheild_count[index] = 0 -- 重置计数器
                        damage = 0
                        spdamage = nil
                        player.SoundEmitter:PlaySound("dontstarve/impacts/impact_forcefield_armour_dull")
                    end
                end
                return damage,spdamage
            end
            inst.___thulecite_players = inst.___thulecite_players or {}

            inst.__light_task = inst:DoPeriodicTask(0.5,function(inst)
                -----------------------------------------------------
                --- 寻找玩家并套上函数
                    local x,y,z = inst.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x,y,z,LIGHT_RADIUS, {"player"},{"playerghost"})
                    local temp_list = {}
                    for k, player in pairs(ents) do
                        local temp_flag = false
                        if player.components.health and not player.components.health:IsDead() then
                            temp_flag = true
                        elseif player.components.health == nil then
                            temp_flag = true
                        end
                        if temp_flag then
                            temp_list[player] = true
                            player.components.loramia_com_combat_hook:Set(inst,inst.___thulecite_fn_in_player)
                        end
                    end
                -----------------------------------------------------
                --- 刷新列表，把范围外的玩家移除
                    for player, flag in pairs(inst.___thulecite_players) do
                        if not temp_list[player] then
                            player.components.loramia_com_combat_hook:Remove(inst)  
                        end
                    end
                    inst.___thulecite_players = temp_list
                -----------------------------------------------------
            end)

            inst.__swtiched_fn = function() --- 模式切换后，移除玩家身上的函数
                for player, flag in pairs(inst.___thulecite_players) do
                    player.components.loramia_com_combat_hook:Remove(inst)                    
                end
                inst.___thulecite_players = nil
                for k, temp_task in pairs(inst.__sheild_tasks) do
                    temp_task:Cancel()
                end
                inst.__sheild_tasks = nil
                for k, temp_fx in pairs(inst.__sheild_fx) do
                    temp_fx:Remove()
                end
                inst.__sheild_fx = nil
                inst.__sheild_count = nil
            end            
        end,
        -------------------------------------------------------------------------------------------
        ["moonrocknugget"] = function(inst)
            -- 月石：让花变成草簇，杀死光圈范围内的影怪，让猪和狗变成月石雕塑
            -- 
            local function IsShadowMonster(target)
                if target:HasTags({"monster","shadow"}) 
                    and not target:HasOneOfTags({"player","epic","FX","companion","isdead","INLIMBO", "notarget", "noattack", "invisible"})
                    and target.components.health and target.components.combat
                    then
                        return true
                    end
                return false
            end
            inst.__light_task = inst:DoPeriodicTask(0.3,function(inst)
                local x,y,z = inst.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x,y,z,LIGHT_RADIUS)
                for k, temp_target in pairs(ents) do
                    if temp_target:HasTag("flower") and temp_target.components.pickable and temp_target.components.pickable:CanBePicked() then
                        local tx,ty,tz = temp_target.Transform:GetWorldPosition()
                        temp_target:Remove()
                        SpawnPrefab("grass").Transform:SetPosition(tx,ty,tz)
                        SpawnPrefab("chester_transform_fx").Transform:SetPosition(tx,ty,tz)
                    elseif temp_target:HasOneOfTags({"hound","pig"}) and not temp_target:HasOneOfTags({"player"}) then
                        local temp = temp_target
                        local tx, ty, tz = temp.Transform:GetWorldPosition()
                        local rot = temp.Transform:GetRotation()
                        if temp:HasTag("hound") then
                            local new = SpawnPrefab(math.random() < 0.5 and "gargoyle_hounddeath" or "gargoyle_houndatk")
                            new.Transform:SetPosition(tx,ty,tz)
                            new.Transform:SetRotation(rot)
                            temp:Remove()
                        elseif temp:HasTag("pig") then
                            local new = SpawnPrefab(math.random() < 0.5 and "gargoyle_werepigdeath" or "gargoyle_werepigatk")
                            new.Transform:SetPosition(tx,ty,tz)
                            new.Transform:SetRotation(rot)
                            temp:Remove()
                        end
                        SpawnPrefab("beefalo_transform_fx").Transform:SetPosition(tx,ty,tz)
                    elseif IsShadowMonster(temp_target) then
                        local tx, ty, tz = temp_target.Transform:GetWorldPosition()
                        temp_target.components.health:DoDelta(-1000000000000)                        
                        SpawnPrefab("statue_transition_2").Transform:SetPosition(tx,ty,tz)
                    end
                end
            end)
        end,
        -------------------------------------------------------------------------------------------
    }
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local function set_light_default(inst) --- 设置默认值
        ------------------------------------------------
        --
            inst.Light:SetRadius(LIGHT_RADIUS)  -- 重置半径
        ------------------------------------------------
        -- 停掉周期性任务
            if inst.__light_task then
                inst.__light_task:Cancel()
                inst.__light_task = nil
            end
        ------------------------------------------------
        -- 重置颜色
            inst.Light:SetColour(255 / 255, 248 / 255, 198 / 255)
        ------------------------------------------------
        --- 重置热量
            inst.components.heater.heatfn = function(inst)
                return 0
            end
            inst.components.heater:SetThermics(true, false)
        ------------------------------------------------
        --- San控制器
            if inst.san_controller then
                inst.san_controller:Remove()
                inst.san_controller = nil
            end
        ------------------------------------------------
        ---
            if inst.__swtiched_fn then
                inst.__swtiched_fn()
                inst.__swtiched_fn = nil
            end
        ------------------------------------------------
    end
    local function light_update_fn(inst)
        if inst.last_type ~= inst.type then
            set_light_default(inst)
            if type(light_type_fn[inst.type]) == "function" then
                light_type_fn[inst.type](inst)
            end
            inst.last_type = inst.type
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddLight()
        inst.entity:AddNetwork()
        inst.entity:AddAnimState()
    
        inst:AddTag("FX")
        inst:AddTag("NOBLOCK")
        inst:AddTag("HASHEATER")
        inst:AddTag("loramia_building_sharpstrike_creation_light")

        inst.entity:AddLight()
        inst.Light:SetFalloff(.9)
        inst.Light:SetIntensity(0.94)
        inst.Light:SetRadius(2)
        inst.Light:SetColour(255 / 255, 248 / 255, 198 / 255)
        inst.Light:Enable(true)
        
        -- inst.AnimState:SetBank("cane")
        -- inst.AnimState:SetBuild("swap_cane")
        -- inst.AnimState:PlayAnimation("idle")


        inst.entity:SetPristine()    
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        ---------------------------------------------------------
        --- 热量
            inst:AddComponent("heater")
            inst.components.heater.heatfn = function(inst)
                return 0
            end
        ---------------------------------------------------------
        --- 掉San
            -- inst:AddComponent("sanityaura")
            -- inst.components.sanityaura.GetAura = function(self,...)
            --     return 0
            -- end
        ---------------------------------------------------------
        -- 类型和任务
            inst.type = "nil"
            inst.last_type = "nil"
            inst:DoPeriodicTask(0.1,light_update_fn)
        ---------------------------------------------------------
        --- 
            inst:DoTaskInTime(0,function(inst)
                if not inst.Ready then
                    inst:Remove()
                end
            end)
        ---------------------------------------------------------
        return inst
    end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local function sanityaura_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddLight()
        inst.entity:AddNetwork()
        inst.entity:AddAnimState()
        
        -- inst.AnimState:SetBank("cane")
        -- inst.AnimState:SetBuild("swap_cane")
        -- inst.AnimState:PlayAnimation("idle")


        inst.entity:SetPristine()    
        if not TheWorld.ismastersim then
            return inst
        end


        ---------------------------------------------------------
        --- 掉San
            inst:AddComponent("sanityaura")
            inst.components.sanityaura.GetAura = function(self,player)
                return 0
            end
        ---------------------------------------------------------
        --- 
            inst:DoTaskInTime(0,function(inst)
                if not inst.Ready then
                    inst:Remove()
                end
            end)
        ---------------------------------------------------------
        return inst
    end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


return Prefab("loramia_building_sharpstrike_creation_light", fn, assets),
    Prefab("loramia_building_sharpstrike_creation_light_sanityaura", sanityaura_fn, assets)