-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_item_luminescent_crystal.zip"),
    Asset( "IMAGE", "images/inventoryimages/loramia_item_luminescent_crystal.tex" ),
    Asset( "ATLAS", "images/inventoryimages/loramia_item_luminescent_crystal.xml" ),
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 创建灯光
    local function create_light(eater)
        if eater.wormlight ~= nil then
            if eater.wormlight.prefab == "wormlight_light" then
                eater.wormlight.components.spell.lifetime = 0
                eater.wormlight.components.spell:ResumeSpell()
                return
            else
                eater.wormlight.components.spell:OnFinish()
            end
        end

        local light = SpawnPrefab("wormlight_light")
        light.components.spell.duration = 480 -- 发光持续时间
        light.components.spell:SetTarget(eater)
        if light:IsValid() then
            if light.components.spell.target == nil then
                light:Remove()
            else
                light.components.spell:StartSpell()
            end
        end
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 物品
    local function item_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("loramia_item_luminescent_crystal")
        inst.AnimState:SetBuild("loramia_item_luminescent_crystal")
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("preparedfood")


        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        -- inst.components.inventoryitem:ChangeImageName("bluegem")
        inst.components.inventoryitem.imagename = "loramia_item_luminescent_crystal"
        inst.components.inventoryitem.atlasname = "images/inventoryimages/loramia_item_luminescent_crystal.xml"
        inst.components.inventoryitem:SetSinks(true)



        ---------------------------------------------------------------------------------------------------
        --- 叠堆
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM
        ---------------------------------------------------------------------------------------------------
        ---
            inst:AddComponent("edible") -- 可食物组件
            inst.components.edible.foodtype = FOODTYPE.GOODIES
            inst.components.edible.hungervalue = 0
            inst.components.edible.sanityvalue = 0
            inst.components.edible.healthvalue = 0
            inst.components.edible:SetOnEatenFn(function(inst,eater)
                if eater and eater:HasTag("player") then
                    create_light(eater)
                end
            end)
        ---------------------------------------------------------------------------------------------------
        MakeHauntableLaunch(inst)

        return inst
    end
return Prefab("loramia_item_luminescent_crystal", item_fn, assets)