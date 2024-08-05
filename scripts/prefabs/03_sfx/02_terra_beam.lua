local assets = {
    -- Asset("IMAGE", "images/inventoryimages/spell_reject_the_npc.tex"),
	-- Asset("ATLAS", "images/inventoryimages/spell_reject_the_npc.xml"),
	-- Asset("ANIM", "anim/npc_fx_chat_bubble.zip"),
}
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
    local MAX_LIGHT_FRAME = 14
    local MAX_LIGHT_RADIUS = 15

    -- dframes is like dt, but for frames, not time
    local function OnUpdateLight(inst, dframes)
        local done
        if inst._islighton:value() then
            local frame = inst._lightframe:value() + dframes
            done = frame >= MAX_LIGHT_FRAME
            inst._lightframe:set_local(done and MAX_LIGHT_FRAME or frame)
        else
            local frame = inst._lightframe:value() - dframes*3
            done = frame <= 0
            inst._lightframe:set_local(done and 0 or frame)
        end

        inst.Light:SetRadius(MAX_LIGHT_RADIUS * inst._lightframe:value() / MAX_LIGHT_FRAME)

        if done then
            inst._LightTask:Cancel()
            inst._LightTask = nil
        end
    end

    local function OnUpdateLightColour(inst)
        inst._lighttweener = inst._lighttweener + FRAMES * 1.25
        if inst._lighttweener > TWOPI then
            inst._lighttweener = inst._lighttweener - TWOPI
        end

        local red, green, blue
        if inst._iscrimson:value() then
            red = 0.90
            green = 0.20
            blue = 0.20
        else
            local x = inst._lighttweener
            local s = .15
            local b = 0.85
            local sin = math.sin

            red = sin(x) * s + b - s
            green = sin(x + 2/3 * PI) * s + b - s
            blue = sin(x - 2/3 * PI) * s + b - s
        end

        inst.Light:SetColour(red, green, blue)
    end

    local function OnLightDirty(inst)
        if inst._LightTask == nil then
            inst._LightTask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
        end
        OnUpdateLight(inst, 0)

        if not TheNet:IsDedicated() then
            if inst._islighton:value() then
                if inst._lightcolourtask == nil then
                    inst._lighttweener = 0
                    inst._lightcolourtask = inst:DoPeriodicTask(FRAMES, OnUpdateLightColour)
                end
            elseif inst._lightcolourtask ~= nil then
                inst._lightcolourtask:Cancel()
                inst._lightcolourtask = nil
            end
        end
    end


    local function TurnLightsOn(inst)
        inst._islighton:set(true)
        OnLightDirty(inst)
        inst._TurnLightsOnTask = nil
    end

    local function StartSummoning(inst, is_loading)
        -- Spawn the summoning beam, if we do not have one (and we shouldn't)
        inst.AnimState:PlayAnimation("activate_fx")
        inst.AnimState:PushAnimation("activated_idle_fx", true)
        -- ...including a delayed light activation
        inst._TurnLightsOnTask = inst:DoTaskInTime(7 * FRAMES, TurnLightsOn)

        inst.SoundEmitter:KillSound("shimmer")
        inst.SoundEmitter:PlaySound("terraria1/terrarium/beam_loop", "beam")
        if not is_loading then
            inst.SoundEmitter:PlaySound("terraria1/terrarium/beam_shoot")
        end        
    end
    local function TurnOn(inst, is_loading)
        if inst.is_on then
            return
        end
        inst.is_on = true
        StartSummoning(inst, is_loading)
    end

    local DEACTIVATE_TIME = 10*FRAMES
    local function TurnOff(inst)
        if not inst.is_on then
            return
        end

        inst.is_on = false

        inst.SoundEmitter:KillSound("shimmer")
        inst.SoundEmitter:KillSound("beam")

        if inst._TurnLightsOnTask ~= nil then
            inst._TurnLightsOnTask:Cancel()
            inst._TurnLightsOnTask = nil
        end
        inst._islighton:set(false)
        OnLightDirty(inst)


        inst.AnimState:PlayAnimation("deactivate_fx")
        inst:DoTaskInTime(DEACTIVATE_TIME, inst.Remove)
        inst.SoundEmitter:PlaySound("terraria1/terrarium/beam_stop")
    end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function fx()
    local inst = CreateEntity()

    inst.entity:AddSoundEmitter()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()


    inst.AnimState:SetBank("terrarium")
    inst.AnimState:SetBuild("terrarium")
    inst.AnimState:PlayAnimation("activated_idle_fx", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(-1)

    -----------------------------------------------------------------------------------------
    --- 灯光相关
        inst.entity:AddLight()

        inst.Light:SetRadius(0)
        inst.Light:SetIntensity(0.45)
        inst.Light:SetFalloff(1.8)
        inst.Light:SetColour(1, 1, 1)
        inst.Light:Enable(true)
        inst.Light:EnableClientModulation(true)

        inst._LightTask = nil
        inst._lightframe = net_smallbyte(inst.GUID, "terrarium._lightframe", "lightdirty")
        inst._iscrimson = net_bool(inst.GUID, "terrarium._iscrimson", "lightdirty")
        inst._islighton = net_bool(inst.GUID, "terrarium._islighton", "lightdirty")
        inst._islighton:set(false)
    -----------------------------------------------------------------------------------------



    inst:AddTag("DECOR")
    inst:AddTag("FX")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)
        return inst
    end

    -- inst.components.colouradder:OnSetColour(139/255,34/255,34/255,0.1)
    inst:ListenForEvent("Set",function(inst,_table)
        -- _table = {
        --     pt = Vector3(0,0,0),
        --     color = Vector3(255,255,255),        -- color / colour 都行
        --     MultColour_Flag = false ,        
        --     a = 0.1,
        --     speed = 1,
        --     sound = "",
        --     end_time = 10,
        --     end_fn = function() end,
        --     
        -- }
        if _table == nil then
            return
        end
        if _table.pt and _table.pt.x then
            inst.Transform:SetPosition(_table.pt.x,_table.pt.y,_table.pt.z)
        end
        ------------------------------------------------------------------------------------------------------------------------------------
        _table.color = _table.color or _table.colour
        if _table.color and _table.color.x then
            if _table.MultColour_Flag ~= true then
                inst:AddComponent("colouradder")
                inst.components.colouradder:OnSetColour(_table.color.x/255 , _table.color.y/255 , _table.color.z/255 , _table.a or 1)
            else
                inst.AnimState:SetMultColour(_table.color.x,_table.color.y, _table.color.z, _table.a or 1)
            end
        end
        ------------------------------------------------------------------------------------------------------------------------------------
        if _table.sound then
            inst.SoundEmitter:PlaySound(_table.sound)
        end

        if type(_table.speed) == "number" then
            inst.AnimState:SetDeltaTimeMultiplier(_table.speed)
        end

        inst.Ready = true

        -------------------------------------------------------------
        --- 激光时间
            TurnOn(inst)
            local end_time = _table.end_time
            if type(end_time) == "number" then
                inst:DoTaskInTime(end_time,function()
                    TurnOff(inst)
                    if _table.end_fn then
                        _table.end_fn()
                    end
                end)
            end
        -------------------------------------------------------------
    end)
    
    inst:ListenForEvent("TurnOn",function(inst,_table)
        inst:PushEvent("Set",_table) 
    end)
    inst:ListenForEvent("TurnOff",function(inst,_table)
        TurnOff(inst) 
    end)

    inst:DoTaskInTime(0,function()
        if inst.Ready ~= true then
            inst:Remove()
        end
    end)

    return inst
end

return Prefab("loramia_sfx_terra_beam",fx,assets)