------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
------------------------------------------------------------------------------------------------------------------------------------------------
--
    local IRON_RHINO_MAX_HEALTH = TUNING["loramia.Config"].IRON_RHINO_MAX_HEALTH or 1000
    local IRON_RHINO_DAMAGE = TUNING["loramia.Config"].IRON_RHINO_DAMAGE or 100
    local IRON_RHINO_HEALTH_REGEN_PER_SECOND = TUNING["loramia.Config"].IRON_RHINO_HEALTH_REGEN_PER_SECOND or 1
------------------------------------------------------------------------------------------------------------------------------------------------

local function OnAttached(inst,target) -- 玩家得到 debuff 的瞬间。 穿越洞穴、重新进存档 也会执行。
    inst.entity:SetParent(target.entity)
    inst.Network:SetClassifiedTarget(target)
    inst.target = target


    target:ListenForEvent("startleashing",function() -- 成功连接到玩家,是follower发出的
        -----------------------------------------------------
        --- 获取绑定的玩家
            local player = target.components.follower:GetLeader()
            if player == nil then
                target:Remove()
                inst:Remove()
                return
            end
        -----------------------------------------------------
        --- 上tag
            target:AddTag("companion")      -- 友方tag,避免被炮台打
            target:RemoveTag("monster")     -- 避免被中立怪主动攻击
        -----------------------------------------------------
        ---重置怪物血量、伤害
            target.components.health:SetMaxHealth(IRON_RHINO_MAX_HEALTH)
            target.components.combat:SetDefaultDamage(IRON_RHINO_DAMAGE)
        -----------------------------------------------------
        --- 靠近玩家
            target:ListenForEvent("pet_close_2_player", function(target)
                if player == nil then
                    return
                end
                local temp_points = TUNING.LORAMIA_FN:GetSurroundPoints({
                    target = player,
                    range = 5,
                    num = 10
                })
                local ret_points = {}
                for k, temp_pt in pairs(temp_points) do
                    if TheWorld.Map:IsLandTileAtPoint(temp_pt.x, temp_pt.y,temp_pt.z) 
                        and TheWorld.Map:IsPassableAtPoint(temp_pt.x,temp_pt.y,temp_pt.z) then
                        table.insert(ret_points, temp_pt)
                    end
                end
                if #ret_points == 0 then
                    return
                end
                local pt = ret_points[math.random(#ret_points)]
                target.Transform:SetPosition(pt.x, pt.y, pt.z)
                target:DoTaskInTime(0,function()
                    SpawnPrefab("spawn_fx_medium").Transform:SetPosition(pt.x, pt.y, pt.z)
                    target:RestartBrain()                
                end)
                target.components.combat:DropTarget()
            end)
        -----------------------------------------------------
        --- 超出加载范围
            target:ListenForEvent("entitysleep", function(target)
                target:PushEvent("pet_close_2_player")
                target:DoTaskInTime(1,function()
                    target:RestartBrain()                
                end)
            end)
        -----------------------------------------------------
        --- 周期性任务        
            local task_fn = function()
                ---------- 检查玩家是否存在
                if player == nil or not player:IsValid() then
                    target:Remove()
                    inst:Remove()
                    return
                end
                ---------- 检查和玩家之间的距离
                -- local x1,y1,z1 = target.Transform:GetWorldPosition()
                -- local x2,y2,z2 = player.Transform:GetWorldPosition()
                -- local dist = math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) + (z1-z2)*(z1-z2))
                -- if dist > 50 then
                --     target:PushEvent("pet_close_2_player")
                -- end
                ---------- 检查和玩家之间的距离
                if target:GetDistanceSqToInst(player) > 50*50 then
                    target:PushEvent("pet_close_2_player")
                end
            end
        -----------------------------------------------------
        -- 怪物定期检查任务
            target:DoPeriodicTask(3,task_fn)
            -- 玩家定期检查任务
            player.__electromagnetic_tower_of_creation_pet_task = player.__electromagnetic_tower_of_creation_pet_task or {}
            player.__electromagnetic_tower_of_creation_pet_task[target] = player:DoPeriodicTask(3,task_fn)
        -----------------------------------------------------
        --- 死亡任务移除
            target:ListenForEvent("death", function(target)
                player.__electromagnetic_tower_of_creation_pet_task[target]:Cancel() 
            end)
            target:ListenForEvent("onremove", function(target)
                player.__electromagnetic_tower_of_creation_pet_task[target]:Cancel() 
            end)
        -----------------------------------------------------
        -- 掉落屏蔽
            if target.components.lootdropper then
                target.components.lootdropper.DropLoot = function(self,...)
                    self:SpawnLootPrefab("gears")
                    self:SpawnLootPrefab("trinket_6")
                end
            end
        -----------------------------------------------------
        -- 恢复血量
            target:DoPeriodicTask(5,function()
                if not target.components.health:IsDead() then
                    target.components.health:DoDelta(5*IRON_RHINO_HEALTH_REGEN_PER_SECOND,true)
                end
            end)
        -----------------------------------------------------
    end)
end

local function OnDetached(inst) -- 被外部命令  inst:RemoveDebuff 移除debuff 的时候 执行
    local target = inst.target
end

local function OnUpdate(inst)
    local target = inst.target

end

local function ExtendDebuff(inst)
    -- inst.countdown = 3 + (inst._level:value() < CONTROL_LEVEL and EXTEND_TICKS or math.floor(TUNING.STALKER_MINDCONTROL_DURATION / FRAMES + .5))
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("CLASSIFIED")



    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff.keepondespawn = true -- 是否保持debuff 到下次登陆
    -- inst.components.debuff:SetDetachedFn(inst.Remove)
    inst.components.debuff:SetDetachedFn(OnDetached)
    -- inst.components.debuff:SetExtendedFn(ExtendDebuff)
    -- ExtendDebuff(inst)

    -- inst:DoPeriodicTask(1, OnUpdate, nil, TheWorld.ismastersim)  -- 定时执行任务


    return inst
end

return Prefab("loramia_debuff_electromagnetic_tower_of_creation", fn)
