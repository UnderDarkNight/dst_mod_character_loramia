-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/swap_llmy_anchor.zip"),
    Asset( "IMAGE", "images/inventoryimages/loramia_weapon_laser_cannon.tex" ),
    Asset( "ATLAS", "images/inventoryimages/loramia_weapon_laser_cannon.xml" ),
}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
    local function onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object","swap_llmy_anchor","swap_llmy_anchor")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end

    local function onunequip(inst, owner)
        owner.AnimState:ClearOverrideSymbol("swap_object")
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 施法消耗
    local HUNGER_COST = TUNING["loramia.Config"].LASER_CANNON_HUNGER_VALUE_COST or 150
    local RECHARGE_COST = TUNING["loramia.Config"].LASER_CANNON_RECHARGE_VALUE_COST or 5
    local function CheckCanCastSpell(inst,doer)
        if doer.replica.hunger:GetCurrent() < HUNGER_COST then
            return false
        end
        if doer.replica.loramia_com_recharge:GetCurrent() < RECHARGE_COST then
            return false
        end
        return true
    end
    local function DoSpellCastCost(inst,doer)
        doer.components.hunger:DoDelta(-HUNGER_COST,true)
        doer.components.loramia_com_recharge:DoDelta(-RECHARGE_COST)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---创建 激光
    local function CreateLaser(player,pt,onhitfn)
        SpawnPrefab("loramia_spell_laser_custom_caster"):PushEvent("Set",{
            attacker = player,
            pt = pt,
            onhitfn = onhitfn,
        })
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 归一化坐标
    local function GetPointAtDistance(pt1,pt2,distance)
        return TUNING.LORAMIA_FN:GetPointAlongLineAtDistance(pt1,pt2,distance)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 点、目标 通用施法组件
    local function spell_caster_setup(inst)
        inst:ListenForEvent("Loramia_OnEntityReplicated.loramia_com_point_and_target_spell_caster",function(inst,replica_com)
            replica_com:SetAllowCanCastOnImpassable(true) -- 可以右键海中释放
            replica_com:SetDistance(10) -- 释放距离
            replica_com:SetTestFn(function(inst,doer,target,pt,right_click)
                if not right_click then
                    return false
                end
                --------------------------------------------------------------------------------
                ---
                    if target == doer then
                        return false
                    end
                    if not CheckCanCastSpell(inst,doer) then
                        return false
                    end
                --------------------------------------------------------------------------------
                return true
            end)
            replica_com:SetText("laser_cannon",TUNING.LORAMIA_FN:GetStringsTable("loramia_weapon_laser_cannon","action_str") or "发射") -- 显示文本
            replica_com:SetSGAction("loramia_laser_cannon_shoot") -- 配置执行的sg
            -- replica_com:SetPreActionFn(function(inst,doer,target,pt)
            -- end)
        end)
        if TheWorld.ismastersim then
            local main_com = inst:AddComponent("loramia_com_point_and_target_spell_caster")
            main_com:SetSpellFn(function(inst,doer,target,pt)
                if not CheckCanCastSpell(inst,doer) then
                    return false
                end
                -- print("+++++",doer,target,pt)
                ------------------------------------------------------------------------------------------------------------------------------
                --- 坐标提取。不论右键的是 某物品或者地面，统一修正为坐标。
                    local ret_pt = nil
                    if target then
                        ret_pt = Vector3(target.Transform:GetWorldPosition())
                    elseif type(pt) == "table" and pt.x then
                        ret_pt = pt
                    end
                    if ret_pt == nil then
                        return false
                    end
                ------------------------------------------------------------------------------------------------------------------------------
                --[[
                     【笔记】由于使用的是天体BOSS的激光，算法上 目标坐标 和 玩家坐标，锁死在 4 距离，则是动画上最佳效果。
                      需要一套算法，把 ret_pt 锁死在射线轴 上距离玩家 4 距离的坐标点上。
                     ]]--
                    -- local dis_sq = doer:GetDistanceSqToPoint(ret_pt.x,ret_pt.y,ret_pt.z)
                    -- local dis = math.sqrt(dis_sq)
                    -- print("dis",dis)
                    ret_pt = GetPointAtDistance(Vector3(doer.Transform:GetWorldPosition()),ret_pt,4)
                -------------------------------------------------------------------------------------------------------------------------------
                DoSpellCastCost(inst,doer)
                local laser_on_hit_fn = function(target)
                    if target.components.health and target.components.combat then
                        target.components.combat:GetAttacked(doer, TUNING["loramia.Config"].LASER_CANNON_DAMAGE or 200, inst)
                    end
                end
                CreateLaser(doer,ret_pt,laser_on_hit_fn)
                return true
            end)
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- onhitother  普通攻击，以目标为中心，半径1.5 aoe
    local AOE_RADIUS = 1.5
    if TUNING.LORAMIA_DEBUGGING_MODE then
        AOE_RADIUS = 10
    end
    local function onhitother(inst, attacker, target)
        if inst.aoe_doing_flag then -- 上锁
            return
        end
        local x,y,z = target.Transform:GetWorldPosition()
        local musthavetags = {"_combat"}
        local canthavetags = {"companion","player", "brightmare", "playerghost", "INLIMBO", "DECOR", "FX"}
        local musthaveoneoftags = nil
        -- local ents = TheSim:FindEntities(x,y,z,AOE_RADIUS, musthavetags, canthavetags, musthaveoneoftags)
        -- local ret_aoe_targets = {}
        -- for k, temp_target in pairs(ents) do
        --     if temp_target and temp_target ~= target then                
        --         if temp_target.components.health and temp_target.components.combat then
        --             table.insert(ret_aoe_targets,temp_target)
        --         end
        --     end
        -- end
        inst.aoe_doing_flag = true
        attacker.components.combat:DoAreaAttack(target,AOE_RADIUS,inst,nil,nil,canthavetags)
        inst.aoe_doing_flag = false
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.AnimState:SetBank("swap_llmy_anchor")
    inst.AnimState:SetBuild("swap_llmy_anchor")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")
    inst:AddTag("tool")

    inst.entity:SetPristine()
    --------------------------------------------------------------------------------
    ---
        spell_caster_setup(inst)
    --------------------------------------------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end

    --------------------------------------------------------------------------------
    -- 普通武器
        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(40)
        inst.components.weapon:SetRange(1.5)
        inst.components.weapon:SetOnAttack(onhitother)
    --------------------------------------------------------------------------------
    -- 可检查、物品图标
        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        -- inst.components.inventoryitem:ChangeImageName("cane")
        inst.components.inventoryitem.imagename = "loramia_weapon_laser_cannon"
        inst.components.inventoryitem.atlasname = "images/inventoryimages/loramia_weapon_laser_cannon.xml"
    --------------------------------------------------------------------------------
    --- 可穿戴
        inst:AddComponent("equippable")
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable.restrictedtag = "loramia"
    --------------------------------------------------------------------------------
    -- 当锤子用
        inst:AddComponent("tool")
        inst.components.tool:SetAction(ACTIONS.HAMMER)
    --------------------------------------------------------------------------------
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("loramia_weapon_laser_cannon", fn, assets)
