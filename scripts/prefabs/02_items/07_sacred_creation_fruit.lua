

local assets =
{
    Asset("ANIM", "anim/mushroom_spore.zip"),
    Asset("ANIM", "anim/mushroom_spore_red.zip"),
    Asset("ANIM", "anim/mushroom_spore_blue.zip"),
}

-- local data =
-- {
--     small =
--     { --Green
--         build = "mushroom_spore",
--         lightcolour = {146/255, 225/255, 146/255},
--     },
--     medium =
--     { --Red
--         build = "mushroom_spore_red",
--         lightcolour = {197/255, 126/255, 126/255},
--     },
--     tall =
--     { --Blue
--         build = "mushroom_spore_blue",
--         lightcolour = {111/255, 111/255, 227/255},
--     },
-- }
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 头脑
    local brain = require "brains/sporebrain"
    local SPORE_TAGS = {"loramia_item_sacred_creation_fruit"}
    local function checkforcrowding(inst)
        local x, y, z = inst.Transform:GetWorldPosition()
        local spores = TheSim:FindEntities(x,y,z, TUNING.MUSHSPORE_MAX_DENSITY_RAD, SPORE_TAGS)
        if #spores > TUNING.MUSHSPORE_MAX_DENSITY then
            -- inst.components.perishable:SetPercent(0)
        else
            inst.crowdingtask = inst:DoTaskInTime(TUNING.MUSHSPORE_DENSITY_CHECK_TIME + math.random()*TUNING.MUSHSPORE_DENSITY_CHECK_VAR, checkforcrowding)
        end
    end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1, .5)

    inst.AnimState:SetBuild("mushroom_spore_blue")
    inst.AnimState:SetBank("mushroom_spore")
    inst.AnimState:PlayAnimation("flight_cycle", true)

    -- inst.DynamicShadow:Enable(false)

    inst.Light:SetColour(unpack({111/255, 111/255, 227/255}))
    inst.Light:SetIntensity(0.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(1)
    -- inst.Light:Enable(false)

    inst.AnimState:SetScale(2,2,2)

    inst.Light:Enable(true)
    inst.DynamicShadow:Enable(true)

    inst.DynamicShadow:SetSize(.8, .5)

    -- inst:AddTag("show_spoilage")
    inst:AddTag("loramia_item_sacred_creation_fruit")
    inst:AddTag("flying")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------------------------------------------------
    -- 检查组件
        inst:AddComponent("inspectable")
    ---------------------------------------------------------------
    -- 丢东西
        inst:AddComponent("lootdropper")
    ---------------------------------------------------------------
    -- 战斗、血量组件
        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(1)
        inst:AddComponent("combat")
    ---------------------------------------------------------------
    -- 移动控制
        inst:AddComponent("knownlocations")

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.components.locomotor:SetTriggersCreep(false)
        inst.components.locomotor.walkspeed = 2

        inst:SetStateGraph("SGspore")
        inst:SetBrain(brain)

        inst.crowdingtask = inst:DoTaskInTime(1 + math.random()*TUNING.MUSHSPORE_DENSITY_CHECK_VAR, checkforcrowding)
    ---------------------------------------------------------------
    -- 
        inst:WatchWorldState("cycles",function(inst)
            inst:DoTaskInTime(math.random(3,5),function(inst)
                if TheWorld.state.isnight or TheWorld:HasTag("cave") then
                    
                else
                    inst.components.health:Kill()
                end
            end)
        end)
        inst:ListenForEvent("death",function(inst)
            inst.components.lootdropper:SpawnLootPrefab(math.random() < 0.7 and "wormlight_lesser" or "wormlight")            
        end)
    ---------------------------------------------------------------


    return inst
end



return Prefab("loramia_item_sacred_creation_fruit", fn, assets)
