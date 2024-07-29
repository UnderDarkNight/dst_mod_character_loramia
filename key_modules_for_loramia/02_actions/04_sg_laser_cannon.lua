------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    改造 来自老王MOD的相关sg动作

]]--
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
--- server 
AddStategraphState("wilson", State{
    name = "loramia_laser_cannon_shoot",
    tags = {"attack", "notalking", "abouttoattack", "autopredict"},
        
    onenter = function(inst)

        inst.components.locomotor:Stop()
        inst.AnimState:SetDeltaTimeMultiplier(0.8)
        inst.AnimState:PlayAnimation("homura_rpg")

        inst.sg.statemem.projectiledelay = (11 - 1)*FRAMES*1.3  
        inst.SoundEmitter:PlaySound('lw_homura/rpg/pre_3d') 
        --inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/charge")
    end,

    timeline=
    {
        TimeEvent(11*1.3*FRAMES, function(inst)
            inst:PerformBufferedAction()
            inst.Physics:SetMotorVel(-10, 0, 0)
            inst.sg:RemoveStateTag("abouttoattack")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/charge")

        end),

        TimeEvent(20*1.3*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        TimeEvent(21*1.3*FRAMES, function(inst) inst.sg:GoToState('idle') end),
    },


    onupdate = function(inst, dt)
        if (inst.sg.statemem.projectiledelay or 0) > 0 then
            inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
            if inst.sg.statemem.projectiledelay <= 0 then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end
    end,

    events=
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end ),
    },

    onexit = function(inst)
        inst.AnimState:SetDeltaTimeMultiplier(1) 
        -- inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            -- inst.components.combat:CancelAttack()
        end
    end,
})

------------------------------------------------------------------------------------------------------------------------------------------------------
-- client side
    AddStategraphState('wilson_client', State{
        name = "loramia_laser_cannon_shoot",
        tags = {"attack", "notalking", "abouttoattack"},
        server_states = { "loramia_laser_cannon_shoot" },
        onenter = function(inst)

            inst.components.locomotor:Stop()
            inst.AnimState:SetDeltaTimeMultiplier(0.8)
            inst.AnimState:PlayAnimation("homura_rpg")
            inst.sg.statemem.projectiledelay = (11 - 1)*FRAMES*1.3
            -- inst.SoundEmitter:PlaySound('lw_homura/rpg/pre_3d')

            inst:PerformPreviewBufferedAction()
        end,

        timeline=
        {
            TimeEvent(11*1.3*FRAMES, function(inst)
                inst.Physics:SetMotorVel(-10, 0, 0)
                inst:ClearBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end),

            TimeEvent(20*1.3*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
            TimeEvent(21*1.3*FRAMES, function(inst) inst.sg:GoToState('idle') end),
        },


        onupdate = function(inst, dt)
            if (inst.sg.statemem.projectiledelay or 0) > 0 then
                inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end
            if inst.sg:ServerStateMatches() then
            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1) 
            if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
                -- inst.replica.combat:CancelAttack()
            end
        end,
    })

------------------------------------------------------------------------------------------------------------------------------------------------------
