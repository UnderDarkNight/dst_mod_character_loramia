------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
    local temp_swtich_list = {
        ["evergreen_short"] = "evergreen",              -- 常青树
        ["deciduoustree_short"] = "deciduoustree",      -- 桦树
        ["palmconetree_short"] = "palmconetree",        -- 棕榈树
        ["moon_tree_short"] = "moon_tree",              -- 月树
        ["twiggy_short"] = "twiggytree",                -- 多枝树
        ["marbleshrub_short"] = "marbleshrub",          -- 大理石树
    }
    local max_stages = {
        ["evergreen"] = 4,      -- 常青树，带枯萎阶段
        ["deciduoustree"] = 3,  -- 桦树
        ["palmconetree"] = 3,   -- 棕榈树
        ["moon_tree"] = 3,      -- 月树
        ["twiggytree"] = 4,     -- 多枝树,带枯萎阶段
        ["marbleshrub"] = 3,    -- 大理石树
    }
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function OnAttached(inst,target) -- 玩家得到 debuff 的瞬间。 穿越洞穴、重新进存档 也会执行。
    inst.entity:SetParent(target.entity)
    inst.Network:SetClassifiedTarget(target)
    inst.target = target
    ----------------------------------------------------------------------------------------------------------
    ---
        local fx = target:SpawnChild("loramia_building_ancient_creation_fx")
        fx:PushEvent("Set",{

        })
        target.loramia_debuff_ancient_creation = inst
        inst.fx = fx
        target:AddTag("has_ancient_creation_buff")
    ----------------------------------------------------------------------------------------------------------
    --- 树苗移除生长之后，继续绑定BUFF
        target:ListenForEvent("onremove",function()
            local ret_plant_prefab = inst.components.loramia_data:Get("ret_plant")
            if ret_plant_prefab then
                local x,y,z = target.Transform:GetWorldPosition()
                -----------------------------------------------------
                ---- 寻找距离最近的目标树木，重新上buff
                    local ents = TheSim:FindEntities(x,y,z,2)
                    local ret_tree = nil
                    local min_dis = 100000
                    for k,tempInst in pairs(ents) do
                        if tempInst.prefab == ret_plant_prefab or (temp_swtich_list[ret_plant_prefab] == tempInst.prefab)
                        then 
                            local temp_dis = tempInst:GetDistanceSqToPoint(x,y,z)
                            if temp_dis < min_dis then
                                ret_tree = tempInst
                                min_dis = temp_dis
                            end
                        end
                    end
                -----------------------------------------------------
                ---- 绑定buff
                    if ret_tree then
                        local debuff_prefab = "loramia_debuff_ancient_creation"
                        local debuff = nil
                        while true do
                            debuff = ret_tree:GetDebuff(debuff_prefab)
                            if debuff then
                                break
                            end
                            ret_tree:AddDebuff(debuff_prefab,debuff_prefab)
                        end
                    end
                -----------------------------------------------------
            end
        end)
    ----------------------------------------------------------------------------------------------------------
    --- 屏蔽阶段退回
        if target.components.growable then
            -- local old_SetStage = target.components.growable.SetStage
            -- target.components.growable.SetStage = function(self,stage)
            local old_DoGrowth = target.components.growable.DoGrowth
            target.components.growable.DoGrowth = function(self,...)
                if self.stage == 3 then
                    return false
                end
                return old_DoGrowth(self,...)
            end
        end
    ----------------------------------------------------------------------------------------------------------
    --- 屏蔽原有的掉落组件
        if target.components.lootdropper and TUNING["loramia.Config"].ANCIENT_CREATION_SPAWN_LOOT_SWTICH then
            target.components.lootdropper.SpawnLootPrefab = function()                
            end
        end
    ----------------------------------------------------------------------------------------------------------
    --- 刷掉落物
        if TUNING["loramia.Config"].ANCIENT_CREATION_SPAWN_LOOT_SWTICH then
            target:WatchWorldState("cycles",function()
                if inst.components.loramia_data:Add("spawn_cd_day",1) > TUNING["loramia.Config"].ANCIENT_CREATION_SPAWN_LOOT_CD_DAY then
                    pcall(function()
                                if target:HasTag("stump") then
                                    return
                                end
                                inst.components.loramia_data:Set("spawn_cd_day",0)
                                local loots = target.components.lootdropper and target.components.lootdropper:GenerateLoot() or {"log","log"}
                                if #loots == 0 then
                                    return
                                end
                                local ret_prefab = loots[math.random(#loots)] or "log"
                                if ret_prefab then
                                    inst.components.lootdropper:SpawnLootPrefab(ret_prefab,Vector3(target.Transform:GetWorldPosition()))
                                end
                    end)
                end
            end)
        end
    ----------------------------------------------------------------------------------------------------------
    --- 挖掘
        if target.components.workable ~= nil then
            target:RemoveComponent("workable")
            target:AddComponent("workable")
        else
            target:AddComponent("workable")
        end
        local function OnFinishCallback(target,worker)
            inst.components.lootdropper:SpawnLootPrefab("bluegem",Vector3(target.Transform:GetWorldPosition()))
            local fx = SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(target.Transform:GetWorldPosition())
            target:Remove()
        end
        target.components.workable:SetWorkAction(ACTIONS.DIG)
        target.components.workable:SetWorkLeft(1)
        target.components.workable:SetOnFinishCallback(OnFinishCallback) 
        --- 除非玩家主动敲打，否则不会掉落
        local old_WorkedBy = target.components.workable.WorkedBy
        target.components.workable.WorkedBy = function(self,worker, numworks,...)
            if worker and worker:HasTag("player") then
                return old_WorkedBy(self,worker, numworks,...)
            end
        end
        local old_WorkedBy_Internal = target.components.workable.WorkedBy_Internal
        target.components.workable.WorkedBy_Internal = function(self,worker, numworks,...)
            if worker and worker:HasTag("player") then
                return old_WorkedBy_Internal(self,worker, numworks,...)
            end
        end
        target:ListenForEvent("worked",function()
            target:DoTaskInTime(0,function()
                if target:IsValid() then                
                    OnFinishCallback(target,nil)
                end
            end)
        end)
    ----------------------------------------------------------------------------------------------------------
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

    inst:DoPeriodicTask(1, OnUpdate, nil, TheWorld.ismastersim)  -- 定时执行任务

    inst:AddComponent("loramia_data")
    inst:AddComponent("lootdropper")

    return inst
end

return Prefab("loramia_debuff_ancient_creation", fn)
