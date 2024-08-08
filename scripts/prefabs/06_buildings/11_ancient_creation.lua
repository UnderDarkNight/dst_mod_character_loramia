-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/loramia_building_ancient_creation.zip"),
}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 种子和植物切换
    local accept_item = {
        ["palmcone_seed"] = "palmcone_sapling",             --- 棕榈树
        ["moonbutterfly"] = "moonbutterfly_sapling",        --- 月树
        ["marblebean"] = "marblebean_sapling",              --- 大理石树
        ["twiggy_nut"] = "twiggy_nut_sapling",              --- 多枝树
        ["acorn"] = "acorn_sapling",                        --- 桦树
        ["pinecone"] = "pinecone_sapling",                  --- 常青树
    }
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- acceptable 物品接受
    local function acceptable_com_install(inst)

        inst:ListenForEvent("Loramia_OnEntityReplicated.loramia_com_acceptable",function(inst,replica_com)
            replica_com:SetTestFn(function(inst,item,doer,right_click)
                if item and accept_item[item.prefab] then
                    return true
                end
                return false
            end)
            replica_com:SetText("loramia_building_ancient_creation",STRINGS.ACTIONS.ADDCOMPOSTABLE)
        end)
        if not TheWorld.ismastersim then
            return
        end
        inst:AddComponent("loramia_com_acceptable")
        inst.components.loramia_com_acceptable:SetOnAcceptFn(function(inst,item,doer)
            ---------------------------------------------------------
            ---
                local x,y,z = inst.Transform:GetWorldPosition()
                local tree_prefab = accept_item[item.prefab]
            ---------------------------------------------------------
            --- 物品消耗

                if item.components.stackable then
                    item.components.stackable:Get():Remove()
                    -- seed = item.components.stackable:Get()
                else
                    item:Remove()
                    -- seed = item
                end
            ---------------------------------------------------------
            ---
                local tree = SpawnPrefab(tree_prefab)
                tree.Transform:SetPosition(x,y,z)
                local debuff_prefab = "loramia_debuff_ancient_creation"
                local debuff = nil
                while true do
                    debuff = tree:GetDebuff(debuff_prefab)
                    if debuff then
                        break
                    end
                    tree:AddDebuff(debuff_prefab,debuff_prefab)
                end
            ---------------------------------------------------------
            --
                local ret_plant = tree.growprefab or "pinecone_sapling"
                debuff.components.loramia_data:Set("ret_plant",ret_plant)
            ---------------------------------------------------------
            --
                TheWorld:PushEvent("itemplanted", { doer = doer, pos = Vector3(x,y,z) })
            ---------------------------------------------------------
            --- 
                inst:Remove()
            ---------------------------------------------------------
            return true
        end)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- workable
    local function OnFinishCallback(inst,worker)
        inst.components.lootdropper:SpawnLootPrefab("bluegem")
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end
    local function workable_install(inst)
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetWorkLeft(1)
        -- inst.components.workable:SetOnWorkCallback(onhit)
        inst.components.workable:SetOnFinishCallback(OnFinishCallback)

        --- 除非玩家主动敲打，否则不会掉落
        local old_WorkedBy = inst.components.workable.WorkedBy
        inst.components.workable.WorkedBy = function(self,worker, numworks,...)
            if worker and worker:HasTag("player") then
                return old_WorkedBy(self,worker, numworks,...)
            end
        end
        local old_WorkedBy_Internal = inst.components.workable.WorkedBy_Internal
        inst.components.workable.WorkedBy_Internal = function(self,worker, numworks,...)
            if worker and worker:HasTag("player") then
                return old_WorkedBy_Internal(self,worker, numworks,...)
            end
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- origin_fn
    local function origin_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:SetDeploySmartRadius(1) --recipe min_spacing/2
        MakeObstaclePhysics(inst, 0.5)

        inst.AnimState:SetBank("loramia_building_ancient_creation")
        inst.AnimState:SetBuild("loramia_building_ancient_creation")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:Pause()


        inst:AddTag("structure")

        inst.entity:SetPristine()
        ----------------------------------------------------------------------------------------------------
        ---
        ----------------------------------------------------------------------------------------------------
        ---
            acceptable_com_install(inst)
        ----------------------------------------------------------------------------------------------------
        if not TheWorld.ismastersim then
            return inst
        end

        ----------------------------------------------------------------------------------------------------
        ---
            inst:AddComponent("inspectable")

            inst:AddComponent("lootdropper")
        ----------------------------------------------------------------------------------------------------
        --- 
            workable_install(inst)
        ----------------------------------------------------------------------------------------------------
        MakeHauntableWork(inst)


        return inst
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- fx
    local function fx()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:SetDeploySmartRadius(1) --recipe min_spacing/2
        MakeObstaclePhysics(inst, 0.5)

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst.AnimState:SetBank("loramia_building_ancient_creation")
        inst.AnimState:SetBuild("loramia_building_ancient_creation")
        inst.AnimState:PlayAnimation("idle",true)
        -- inst.AnimState:SetSortOrder(1)
        inst.AnimState:SetMultColour(1,1,1,0.6)


        inst:AddTag("structure")

        inst.entity:SetPristine()
        ----------------------------------------------------------------------------------------------------
        ---
            -- if TheWorld.ismastersim then
            --     inst:AddComponent("loramia_data")
            -- end
        ----------------------------------------------------------------------------------------------------
        ---
            acceptable_com_install(inst)
        ----------------------------------------------------------------------------------------------------
        if not TheWorld.ismastersim then
            return inst
        end
        inst.AnimState:SetTime(math.random()*5)
        ----------------------------------------------------------------------------------------------------
        ---
            inst:AddComponent("lootdropper")
        ----------------------------------------------------------------------------------------------------
        ---
            inst:ListenForEvent("Set",function(inst,_table)
                inst.Ready = true
            end)
            inst:DoTaskInTime(0,function()
                if not inst.Ready then
                    inst:Remove()
                end
            end)
        ----------------------------------------------------------------------------------------------------



        return inst
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return Prefab("loramia_building_ancient_creation", origin_fn, assets),
    Prefab("loramia_building_ancient_creation_fx", fx, assets),
    MakePlacer("loramia_building_ancient_creation_placer", "loramia_building_ancient_creation", "loramia_building_ancient_creation", "idle")
