---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    天体的 激光

]]--
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TUNING.LORAMIA_SPELL_LASER_DAMAGE = 200  --- 默认伤害


local assets =
{
    Asset("ANIM", "anim/alterguardian_laser_hit_sparks_fx.zip"),
}

local assets_scorch =
{
    Asset("ANIM", "anim/burntground.zip"),
}

local assets_trail =
{
    Asset("ANIM", "anim/lavaarena_staff_smoke_fx.zip"),
}

local prefabs =
{
    "loramia_spell_laserscorch",
    "loramia_spell_lasertrail",
    "loramia_spell_laserhit",
}

local LAUNCH_SPEED = .2
local RADIUS = .7

local function SetLightRadius(inst, radius)
    inst.Light:SetRadius(radius)
end

local function DisableLight(inst)
    inst.Light:Enable(false)
end

-- local DAMAGE_CANT_TAGS = { "brightmareboss", "brightmare", "playerghost", "INLIMBO", "DECOR", "FX" }
local DAMAGE_CANT_TAGS = { "companion","player", "brightmare", "playerghost", "INLIMBO", "DECOR", "FX" }
local DAMAGE_ONEOF_TAGS = { "_combat", "pickable", "NPC_workable", "CHOP_workable", "HAMMER_workable", "MINE_workable", "DIG_workable" }
local LAUNCH_MUST_TAGS = { "_inventoryitem" }
local LAUNCH_CANT_TAGS = { "locomotor", "INLIMBO" }

local function DoDamage(inst, targets, skiptoss, skipscorch)
    inst.task = nil

    local x, y, z = inst.Transform:GetWorldPosition()

    -- First, get our presentation out of the way, since it doesn't change based on the find results.
    if inst.AnimState ~= nil then
        inst.AnimState:PlayAnimation("hit_"..tostring(math.random(5)))
        inst:Show()
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)

        inst.Light:Enable(true)
        inst:DoTaskInTime(4 * FRAMES, SetLightRadius, .5)
        inst:DoTaskInTime(5 * FRAMES, DisableLight)

        if not skipscorch and TheWorld.Map:IsPassableAtPoint(x, 0, z, false) then
            local laserscorch = SpawnPrefab("loramia_spell_laserscorch")
            laserscorch.Transform:SetPosition(x, 0, z)
            inst:ScorchSetting(laserscorch)
        end

        local fx = SpawnPrefab("loramia_spell_lasertrail")
        fx.Transform:SetPosition(x, 0, z)
        fx:FastForward(GetRandomMinMax(.3, .7))

        inst:TrailSetting(fx)

    else
        inst:DoTaskInTime(2 * FRAMES, inst.Remove)
    end

    inst.components.combat.ignorehitrange = true
    for _, v in ipairs(TheSim:FindEntities(x, 0, z, RADIUS + 3, nil, DAMAGE_CANT_TAGS, DAMAGE_ONEOF_TAGS)) do
        if not targets[v] and v:IsValid() and
                not (v.components.health ~= nil and v.components.health:IsDead()) then
            local range = RADIUS + v:GetPhysicsRadius(.5)
            local dsq_to_laser = v:GetDistanceSqToPoint(x, y, z)
            if dsq_to_laser < range * range then
                v:PushEvent("onalterguardianlasered")

                local isworkable = false
                if v.components.workable ~= nil then
                    local work_action = v.components.workable:GetWorkAction()
                    --V2C: nil action for NPC_workable (e.g. campfires)
                    isworkable =
                        (   work_action == nil and v:HasTag("NPC_workable") ) or
                        (   v.components.workable:CanBeWorked() and
                            (   work_action == ACTIONS.CHOP or
                                work_action == ACTIONS.HAMMER or
                                work_action == ACTIONS.MINE or
                                (   work_action == ACTIONS.DIG and
                                    v.components.spawner == nil and
                                    v.components.childspawner == nil
                                )
                            )
                        )
                    --- 额外检查是否可摧毁
                    -- print("test",v,isworkable,inst:HasCustomWorkableDestroyCheckerFn(),inst:HasCustomWorkableDestroyCheckerFn() and inst:CustomWorkable_CanDestroy(v))
                    if isworkable and inst:HasCustomWorkableDestroyCheckerFn() then
                        isworkable = inst:CustomWorkable_CanDestroy(v) or false
                    end 
                end
                if isworkable then
                    targets[v] = true
                    v.components.workable:Destroy(inst)

                    -- Completely uproot trees.
                    if v:HasTag("stump") then
                        v:Remove()
                    end
                elseif v.components.pickable ~= nil
                        and v.components.pickable:CanBePicked()
                        and not v:HasTag("intense") then
                    targets[v] = true
                    local num = v.components.pickable.numtoharvest or 1
                    local product = v.components.pickable.product
                    local x1, y1, z1 = v.Transform:GetWorldPosition()
                    v.components.pickable:Pick(inst) -- only calling this to trigger callbacks on the object
                    if product ~= nil and num > 0 then
                        for i = 1, num do
                            local loot = SpawnPrefab(product)
                            loot.Transform:SetPosition(x1, 0, z1)
                            skiptoss[loot] = true
                            targets[loot] = true
                            Launch(loot, inst, LAUNCH_SPEED)
                        end
                    end
                elseif v.components.combat == nil and v.components.health ~= nil then
                    targets[v] = true
                elseif inst.components.combat:CanTarget(v) and not inst:HasCustomDamageFn() then
                    targets[v] = true
                    if inst.caster ~= nil and inst.caster:IsValid() then
                        inst.caster.components.combat.ignorehitrange = true
                        inst.caster.components.combat:DoAttack(v)
                        inst.caster.components.combat.ignorehitrange = false
                    else
                        inst.components.combat:DoAttack(v)
                    end
                    SpawnPrefab("loramia_spell_laserhit"):SetTarget(v)

                    if not v.components.health:IsDead() then
                        if v.components.freezable ~= nil then
                            if v.components.freezable:IsFrozen() then
                                v.components.freezable:Unfreeze()
                            elseif v.components.freezable.coldness > 0 then
                                v.components.freezable:AddColdness(-2)
                            end
                        end
                        if v.components.temperature ~= nil then
                            local maxtemp = math.min(v.components.temperature:GetMax(), 10)
                            local curtemp = v.components.temperature:GetCurrent()
                            if maxtemp > curtemp then
                                v.components.temperature:DoDelta(math.min(10, maxtemp - curtemp))
                            end
                        end
                        if v.components.sanity ~= nil then
                            v.components.sanity:DoDelta(TUNING.GESTALT_ATTACK_DAMAGE_SANITY)
                        end
                    end
                elseif inst.components.combat:CanTarget(v) and inst:HasCustomDamageFn() then
                    targets[v] = true
                    inst:DoCustomDamage(v)
                    SpawnPrefab("loramia_spell_laserhit"):SetTarget(v)
                end
            end
        end
    end
    inst.components.combat.ignorehitrange = false

    -- After lasering stuff, try tossing any leftovers around.
    for _, v in ipairs(TheSim:FindEntities(x, 0, z, RADIUS + 3, LAUNCH_MUST_TAGS, LAUNCH_CANT_TAGS)) do
        if not skiptoss[v] then
            local range = RADIUS + v:GetPhysicsRadius(.5)
            if v:GetDistanceSqToPoint(x, y, z) < range * range then
                if v.components.mine ~= nil then
                    targets[v] = true
                    skiptoss[v] = true
                    v.components.mine:Deactivate()
                end
                if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
                    targets[v] = true
                    skiptoss[v] = true
                    Launch(v, inst, LAUNCH_SPEED)
                end
            end
        end
    end

end

local function Trigger(inst, delay, targets, skiptoss, skipscorch)
    if inst.task ~= nil then
        inst.task:Cancel()
        if (delay or 0) > 0 then
            inst.task = inst:DoTaskInTime(delay, DoDamage, targets or {}, skiptoss or {}, skipscorch)
        else
            DoDamage(inst, targets or {}, skiptoss or {}, skipscorch)
        end
    end
end

local function KeepTargetFn()
    return false
end

local function common_fn(isempty)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    if not isempty then
        inst.entity:AddAnimState()
        inst.AnimState:SetBank("alterguardian_laser_hits_sparks")
        inst.AnimState:SetBuild("alterguardian_laser_hit_sparks_fx")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetLightOverride(1)

        inst.entity:AddLight()
        inst.Light:SetIntensity(.6)
        inst.Light:SetRadius(1)
        inst.Light:SetFalloff(.7)
        inst.Light:SetColour(0.1, 0.4, 1.0)
        inst.Light:Enable(false)
    end

    inst:Hide()

    inst:AddTag("notarget")
    inst:AddTag("hostile")

    inst:SetPrefabNameOverride("deerclops")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.LORAMIA_SPELL_LASER_DAMAGE)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst.task = inst:DoTaskInTime(0, inst.Remove)
    inst.Trigger = Trigger
    inst.persists = false
    ----------------------------------------
    -- 自定义伤害组件
        function inst:SetCustomDoDamageFn(fn)
            if type(fn) == "function" then
                self.__custom_do_damage_Fn = fn
            end
        end
        function inst:DoCustomDamage(target)
            if self.__custom_do_damage_Fn ~= nil then
                self.__custom_do_damage_Fn(self, target)
            end
        end
        function inst:HasCustomDamageFn()
            return self.__custom_do_damage_Fn ~= nil
        end
    ----------------------------------------
    --- 自定义破坏组件
        function inst:SetCustomWorkableDestroyCheckerFn(fn)
            if type(fn) == "function" then
                self.__custom_workable_destroy_checker_Fn = fn
            end
        end
        function inst:HasCustomWorkableDestroyCheckerFn()
            return self.__custom_workable_destroy_checker_Fn ~= nil
        end
        function inst:CustomWorkable_CanDestroy(target)
            return self.__custom_workable_destroy_checker_Fn(self, target)
        end
    ----------------------------------------
    --- trail fn
        function inst:SetTrailFn(fn)
            if type(fn) == "function" then
                self.__trail_Fn = fn
            end
        end
        function inst:TrailSetting(fx)
            if self.__trail_Fn ~= nil then
                self.__trail_Fn(fx)
            end
        end
    ----------------------------------------
    -- 地面印记执行函数
        function inst:SetScorchFn(fn)
            if type(fn) == "function" then
                self.__scorch_Fn = fn
            end
        end
        function inst:ScorchSetting(fx)
            if self.__scorch_Fn ~= nil then
                self.__scorch_Fn(fx)
            end
        end
    ----------------------------------------

    return inst
end

local function fn()
    return common_fn(false)
end

local function emptyfn()
    return common_fn(true)
end

local SCORCH_BLUE_FRAMES = 20
local SCORCH_DELAY_FRAMES = 0
local SCORCH_FADE_FRAMES = 5

local function Scorch_OnFadeDirty(inst)
    --V2C: hack alert: using SetHightlightColour to achieve something like OverrideAddColour
    --     (that function does not exist), because we know this FX can never be highlighted!
    if inst._fade:value() > SCORCH_FADE_FRAMES + SCORCH_DELAY_FRAMES then
        local k = (inst._fade:value() - SCORCH_FADE_FRAMES - SCORCH_DELAY_FRAMES) / SCORCH_BLUE_FRAMES
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour(0, 0, k, 0)
    elseif inst._fade:value() >= SCORCH_FADE_FRAMES then
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour()
    else
        local k = inst._fade:value() / SCORCH_FADE_FRAMES
        k = k * k
        inst.AnimState:OverrideMultColour(1, 1, 1, k)
        inst.AnimState:SetHighlightColour()
    end
end

local function Scorch_OnUpdateFade(inst)
    if inst._fade:value() > 1 then
        inst._fade:set_local(inst._fade:value() - 1)
        Scorch_OnFadeDirty(inst)
    elseif TheWorld.ismastersim then
        inst:Remove()
    elseif inst._fade:value() > 0 then
        inst._fade:set_local(0)
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)
    end
end

local function scorchfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("burntground")
    inst.AnimState:SetBank("burntground")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst._fade = net_byte(inst.GUID, "loramia_spell_laserscorch._fade", "fadedirty")
    inst._fade:set(SCORCH_BLUE_FRAMES + SCORCH_DELAY_FRAMES + SCORCH_FADE_FRAMES)

    inst:DoPeriodicTask(0, Scorch_OnUpdateFade)
    Scorch_OnFadeDirty(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", Scorch_OnFadeDirty)

        return inst
    end

    inst.Transform:SetRotation(math.random() * 360)
    inst.persists = false

    return inst
end

local function FastForwardTrail(inst, pct)
    if inst._task ~= nil then
        inst._task:Cancel()
    end
    local len = inst.AnimState:GetCurrentAnimationLength()
    pct = math.clamp(pct, 0, 1)
    inst.AnimState:SetTime(len * pct)
    inst._task = inst:DoTaskInTime(len * (1 - pct) + 2 * FRAMES, inst.Remove)
end

local function trailfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("lavaarena_staff_smoke_fx")
    inst.AnimState:SetBuild("lavaarena_staff_smoke_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, 0, 1, 0)
    inst.AnimState:SetMultColour(0, 0, 1, 1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst._task = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)

    inst.FastForward = FastForwardTrail

    return inst
end

local function OnRemoveHit(inst)
    if inst.target ~= nil and inst.target:IsValid() then
        if inst.target.components.colouradder == nil then
            if inst.target.components.freezable ~= nil then
                inst.target.components.freezable:UpdateTint()
            else
                inst.target.AnimState:SetAddColour(0, 0, 0, 0)
            end
        end
        if inst.target.components.bloomer == nil then
            inst.target.AnimState:ClearBloomEffectHandle()
        end
    end
end

local function UpdateHit(inst, target)
    if target:IsValid() then
        local oldflash = inst.flash
        inst.flash = math.max(0, inst.flash - .075)
        if inst.flash > 0 then
            local c = math.min(1, inst.flash)
            if target.components.colouradder ~= nil then
                target.components.colouradder:PushColour(inst, 0, 0, c, 0)
            else
                target.AnimState:SetAddColour(0, 0, c, 0)
            end
            if inst.flash < .3 and oldflash >= .3 then
                if target.components.bloomer ~= nil then
                    target.components.bloomer:PopBloom(inst)
                else
                    target.AnimState:ClearBloomEffectHandle()
                end
            end
            return
        end
    end
    inst:Remove()
end

local function SetTarget(inst, target)
    if inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = nil

        inst.target = target
        inst.OnRemoveEntity = OnRemoveHit

        if target.components.bloomer ~= nil then
            target.components.bloomer:PushBloom(inst, "shaders/anim.ksh", -1)
        else
            target.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end
        inst.flash = .8 + math.random() * .4
        inst:DoPeriodicTask(0, UpdateHit, nil, target)
        UpdateHit(inst, target)
    end
end

local function hitfn()
    local inst = CreateEntity()

    inst:AddTag("CLASSIFIED")
    --[[Non-networked entity]]
    inst.persists = false

    inst.SetTarget = SetTarget
    inst.inittask = inst:DoTaskInTime(0, inst.Remove)

    return inst
end
------------------------------------------------------------------------------------------------------------------------
--- 控制器
    local function CreateLaser(_cmd_table)
        ---------------------------------------------------
        --- 控制表
            local player = _cmd_table.attacker              --- 攻击者
            local pt = _cmd_table.pt                        --- 目标坐标
            local onhitfn = _cmd_table.onhitfn              --- 怪物击中执行函数 function(target) end
            local workable_destroy_checker_fn = _cmd_table.workable_destroy_checker_fn  --- 带workable的检查 function(target) return true end
            local trailfn = _cmd_table.trailfn              --- 尾部执行函数 function(fx) end
            local scorchfn = _cmd_table.scorchfn            --- 地面印记执行函数 function(fx) end
        ---------------------------------------------------
        --- 修改自官方的激光代码
            local SECOND_BLAST_TIME = 22*FRAMES
            local NUM_STEPS = 10
            local STEP = 1.0
            local OFFSET = 2 - STEP
            local function SpawnBeam(inst, target_pos)
                if target_pos == nil then
                    return
                end
            
                local ix, iy, iz = inst.Transform:GetWorldPosition()
            
                -- This is the "step" of fx spawning that should align with the position the beam is targeting.
                local target_step_num = RoundBiasedUp(NUM_STEPS * 2/5)
            
                local angle = nil
            
                -- gx, gy, gz is the point of the actual first beam fx
                local gx, gy, gz = nil, 0, nil
                local x_step = STEP
                if inst:GetDistanceSqToPoint(target_pos:Get()) < 4 then
                    angle = math.atan2(iz - target_pos.z, ix - target_pos.x)
            
                    -- If the target is too close, use the minimum distance
                    gx, gy, gz = inst.Transform:GetWorldPosition()
                    gx = gx + (2 * math.cos(angle))
                    gz = gz + (2 * math.sin(angle))
                else
                    angle = math.atan2(iz - target_pos.z, ix - target_pos.x)
            
                    gx, gy, gz = target_pos:Get()
                    gx = gx + (target_step_num * STEP * math.cos(angle))
                    gz = gz + (target_step_num * STEP * math.sin(angle))
                end
            
                local targets, skiptoss = {}, {}
                local sbtargets, sbskiptoss = {}, {}
                local x, z = nil, nil
                local trigger_time = nil
            
                local i = -1
                while i < NUM_STEPS do
                    i = i + 1
                    x = gx - i * x_step * math.cos(angle)
                    z = gz - i * STEP * math.sin(angle)
            
                    local first = (i == 0)
                    local prefab = (i > 0 and "loramia_spell_laser") or "loramia_spell_laserempty"
                    local x1, z1 = x, z
            
                    trigger_time = math.max(0, i - 1) * FRAMES
                    ---------------------------------------------------
                    ---- 发射激光
                        inst:DoTaskInTime(trigger_time, function(inst2)
                            local fx = SpawnPrefab(prefab)
                            -------------------------------------------------------------------
                            --- 控制函数
                                if onhitfn then
                                    fx:SetCustomDoDamageFn(function(fx,target)
                                        onhitfn(target)
                                    end)
                                end
                                if workable_destroy_checker_fn then
                                    fx:SetCustomWorkableDestroyCheckerFn(function(fx,target)
                                        return workable_destroy_checker_fn(target)
                                    end)
                                end
                                fx:SetTrailFn(trailfn)
                            -------------------------------------------------------------------
                            fx.caster = inst2
                            fx.Transform:SetPosition(x1, 0, z1)
                            fx:Trigger(0, targets, skiptoss)

                        end)
                    ---------------------------------------------------

                end
            
                inst:DoTaskInTime(i*FRAMES, function(inst2)
                    local fx = SpawnPrefab("loramia_spell_laser")
                    fx.Transform:SetPosition(x, 0, z)
                    fx:Trigger(0, targets, skiptoss)
                end)
            
                inst:DoTaskInTime((i+1)*FRAMES, function(inst2)
                    local fx = SpawnPrefab("loramia_spell_laser")
                    fx.Transform:SetPosition(x, 0, z)
                    fx:Trigger(0, targets, skiptoss)
                end)
            end
        ---------------------------------------------------
        ---- 官方的三叉代码
            local TRIBEAM_ANGLEOFF = PI/5
            local TRIBEAM_COS = math.cos(TRIBEAM_ANGLEOFF)
            local TRIBEAM_SIN = math.sin(TRIBEAM_ANGLEOFF)
            local TRIBEAM_COSNEG = math.cos(-TRIBEAM_ANGLEOFF)
            local TRIBEAM_SINNEG = math.sin(-TRIBEAM_ANGLEOFF)

            local ipos = player:GetPosition()
            -- local target_pos = inst.sg.statemem.target_pos
            local target_pos = pt
            
            if target_pos == nil then
                local angle = player.Transform:GetRotation() * DEGREES
                target_pos = ipos + Vector3(OFFSET * math.cos(angle), 0, -OFFSET * math.sin(angle))
            end
            SpawnBeam(player, target_pos)
        ---------------------------------------------------
    end
    local function laser_spell_caster()
        local inst = CreateEntity()
        if not TheWorld.ismastersim then
            return inst
        end
        inst:ListenForEvent("Set",function(inst,_table)
            CreateLaser(_table)
            inst:Remove()
        end)
        inst:DoTaskInTime(0,inst.Remove)
        return inst
    end
------------------------------------------------------------------------------------------------------------------------

return Prefab("loramia_spell_laser", fn, assets, prefabs),
    Prefab("loramia_spell_laserempty", emptyfn, assets, prefabs),
    Prefab("loramia_spell_laserscorch", scorchfn, assets_scorch),   --- 地面烧焦的痕迹
    Prefab("loramia_spell_lasertrail", trailfn, assets_trail),      --- 冒出的火焰
    Prefab("loramia_spell_laserhit", hitfn),

    Prefab("loramia_spell_laser_custom_caster", laser_spell_caster) -- 施法器


