------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
------------------------------------------------------------------------------------------------------------------------------------------------------------
    require "prefabutil"
    local assets =
    {
        Asset("ANIM", "anim/lightning_rod.zip"),
        Asset("ANIM", "anim/lightning_rod_fx.zip"),
        Asset("MINIMAP_IMAGE", "lightningrod"),
    }
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 官方的雷电模块
    local function dozap(inst)
        if inst.zaptask ~= nil then
            inst.zaptask:Cancel()
        end

        inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")
        SpawnPrefab("lightning_rod_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst.zaptask = inst:DoTaskInTime(math.random(10, 40), dozap)
    end
    local ondaycomplete
    local function discharge(inst)
        if inst.charged then
            inst:StopWatchingWorldState("cycles", ondaycomplete)
            inst.AnimState:ClearBloomEffectHandle()
            inst.charged = false
            inst.chargeleft = nil
            inst.Light:Enable(false)
            if inst.zaptask ~= nil then
                inst.zaptask:Cancel()
                inst.zaptask = nil
            end
        end
    end
    local function ondaycomplete(inst)
        dozap(inst)
        if inst.chargeleft > 1 then
            inst.chargeleft = inst.chargeleft - 1
        else
            discharge(inst)
        end
    end
    local function setcharged(inst, charges)
        if not inst.charged then
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.Light:Enable(true)
            inst:WatchWorldState("cycles", ondaycomplete)
            inst.charged = true
        end
        inst.chargeleft = math.max(inst.chargeleft or 0, charges)
        dozap(inst)
    end
    local function onlightning(inst)
        setcharged(inst, 3)
    end
    local function OnSave(inst, data)
        if inst.charged then
            data.charged = inst.charged
            data.chargeleft = inst.chargeleft
        end
    end
    local function OnLoad(inst, data)
        if data ~= nil and data.charged and data.chargeleft ~= nil and data.chargeleft > 0 then
            setcharged(inst, data.chargeleft)
        end
    end
    local function getstatus(inst)
        return inst.charged and "CHARGED" or nil
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 电池
    local function CanBeUsedAsBattery(inst, user)
        if inst.charged then
            return true
        else
            return false, "NOT_ENOUGH_CHARGE"
        end
    end

    local function UseAsBattery(inst, user)
        discharge(inst)
    end

------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 能量槽和宠物系统
    local FUELED_PET_COST = 500         --- 宠物消耗数量
    local FUELED_UP_PER_HIT = 100       --- 单次雷击充电数量

    local function SpawnPet(inst,doer)  --- 创建宠物并绑定给玩家
        if inst.components.fueled.currentfuel < FUELED_PET_COST then
            return
        end
        inst.components.fueled:DoDelta(-FUELED_PET_COST)

        local monster = SpawnPrefab("rook_nightmare")
        -- scion.Transform:SetPosition(x,y,z)
        local debuff_prefab = "loramia_debuff_electromagnetic_tower_of_creation"
        while true do
            local debuff = monster:GetDebuff(debuff_prefab)
            if debuff then
                break
            end
            monster:AddDebuff(debuff_prefab,debuff_prefab)
        end
        doer:PushEvent("makefriend")
        monster.components.follower:SetLeader(doer)
        monster:PushEvent("pet_close_2_player")

    end
    local function fueled_enough_checker(inst) --- 能量检查
        -- if inst.components.fueled:IsEmpty() then
        if inst.components.fueled.currentfuel < FUELED_PET_COST then
            inst:RemoveTag("fueled_enough")
        else
            inst:AddTag("fueled_enough")
        end
    end
    local function fueled_sys_install(inst)
        inst:AddComponent("fueled")
        inst.components.fueled.maxfuel = 1000
        inst:ListenForEvent("lightningstrike",function()
            -- print("info : lightningstrike")
            inst.components.fueled:DoDelta(FUELED_UP_PER_HIT)
            fueled_enough_checker(inst)
        end)
        inst:ListenForEvent("percentusedchange",fueled_enough_checker)
        inst:DoTaskInTime(0,fueled_enough_checker)
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- workable
    local function OnFinishCallback(inst,worker)
        inst.components.lootdropper:SpawnLootPrefab("redgem")
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
------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 容器界面安装
    local function constructionsite_install(inst)
        inst:AddComponent("constructionsite")
        inst.components.constructionsite:SetConstructionPrefab("loramia_building_electromagnetic_tower_of_creation_container")
        inst.components.constructionsite:SetOnConstructedFn(function(inst,doer)
            inst.components.constructionsite.enabled  = true
            ----------------------------------------------------
            --- 
                -- print("++++++++++ 666666666666",inst,doer)
                SpawnPet(inst,doer)
                --- 清除内部物品
                for k, v in pairs(inst.components.constructionsite.materials) do
                    inst.components.constructionsite:RemoveMaterial(k,v.amount)
                end
                inst.components.constructionsite:DropAllMaterials()
            ----------------------------------------------------
        end)
        --------------------------------------------------------------------------------------------------------

        --------------------------------------------------------------------------------------------------------
        -- 打开界面后，给界面inst上tag，方便按钮那边确定是否激活
            inst.components.constructionsite:SetOnStartConstructionFn(function(inst,doer) 
                if doer.components.constructionbuilder then
                    local widget_inst = doer.components.constructionbuilder.constructioninst
                    if widget_inst then
                        if inst:HasTag("fueled_enough") then
                            widget_inst:AddTag("fueled_enough")
                        else
                            widget_inst:RemoveTag("fueled_enough")
                        end
                    end
                end
            end)
        --------------------------------------------------------------------------------------------------------
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
---- building_fn
    local function building_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddLight()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:SetDeploySmartRadius(0.5) --recipe min_spacing/2

        inst.MiniMapEntity:SetIcon("lightningrod.png")

        inst.Light:Enable(false)
        inst.Light:SetRadius(1.5)
        inst.Light:SetFalloff(1)
        inst.Light:SetIntensity(.5)
        inst.Light:SetColour(235/255,121/255,12/255)

        inst:AddTag("structure")
        inst:AddTag("lightningrod")
        inst:AddTag("loramia_building_electromagnetic_tower_of_creation")

        inst.AnimState:SetBank("lightning_rod")
        inst.AnimState:SetBuild("lightning_rod")
        inst.AnimState:PlayAnimation("idle")

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end
        ---------------------------------------------------
        --- 雷劈
            inst:ListenForEvent("lightningstrike", onlightning)
        ---------------------------------------------------
        -- 物品掉落
            inst:AddComponent("lootdropper")
        ---------------------------------------------------
        -- 挖掘拆除
            workable_install(inst)
        ---------------------------------------------------
        -- 检查
            inst:AddComponent("inspectable")
            inst.components.inspectable.getstatus = getstatus
        ---------------------------------------------------
        -- 电池
            inst:AddComponent("battery")
            inst.components.battery.canbeused = CanBeUsedAsBattery
            inst.components.battery.onused = UseAsBattery
        ---------------------------------------------------
            MakeSnowCovered(inst)
        ---------------------------------------------------
        --- 能量槽
            fueled_sys_install(inst)
        ---------------------------------------------------
        --- 容器界面安装
            constructionsite_install(inst)
        ---------------------------------------------------

        MakeHauntableWork(inst)

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        return inst
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
---- container_fn
    local all_container_widgets = require("containers")
    local params = all_container_widgets.params

    params.loramia_building_electromagnetic_tower_of_creation_container =
    {
        widget =
        {
            slotpos = {},
            animbank = "ui_construction_4x1",
            animbuild = "ui_construction_4x1",
            pos = Vector3(300, 0, 0),
            top_align_tip = 50,
            buttoninfo =
            {
                text = STRINGS.ACTIONS.APPLYCONSTRUCTION.GENERIC,
                position = Vector3(0, -94, 0),
            },
            --V2C: -override the default widget sound, which is heard only by the client
            --     -most containers disable the client sfx via skipopensnd/skipclosesnd,
            --      and play it in world space through the prefab instead.
            opensound = "dontstarve/wilson/chest_open",
            closesound = "dontstarve/wilson/chest_close",
            --
        },
        usespecificslotsforitems = true,
        type = "cooker",
    }

    for x = -1.5, 1.5, 1 do
        table.insert(params.loramia_building_electromagnetic_tower_of_creation_container.widget.slotpos, Vector3(x * 110, 8, 0))
    end

    function params.loramia_building_electromagnetic_tower_of_creation_container.itemtestfn(container, item, slot)
        local doer = container.inst.entity:GetParent()
        return doer ~= nil
            and doer.components.constructionbuilderuidata ~= nil
            and doer.components.constructionbuilderuidata:GetIngredientForSlot(slot) == item.prefab
    end

    function params.loramia_building_electromagnetic_tower_of_creation_container.widget.buttoninfo.fn(inst, doer)
        ----------------------------------------------------------------------------------
        --- 检查满

        ----------------------------------------------------------------------------------
        --- 检查是指定玩家
            if not inst:HasTag("fueled_enough") then
                return
            end
        ----------------------------------------------------------------------------------
        --- 按钮成功激活
            if inst.components.container ~= nil then
                BufferedAction(doer, inst, ACTIONS.APPLYCONSTRUCTION):Do()
            elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.APPLYCONSTRUCTION.code, inst, ACTIONS.APPLYCONSTRUCTION.mod_name)
            end
        ----------------------------------------------------------------------------------
    end

    function params.loramia_building_electromagnetic_tower_of_creation_container.widget.buttoninfo.validfn(inst)
        -- return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
        if not inst:HasTag("fueled_enough") then
            return false
        end

        local prefabs_with_num = {}
        local item_num = 0
        for k, cmd_table in pairs(CONSTRUCTION_PLANS["loramia_building_electromagnetic_tower_of_creation"]) do
            local item_prefab = cmd_table.type
            local amount = cmd_table.amount
            prefabs_with_num[item_prefab] = amount
            item_num = item_num + 1
        end

        local temp_count = 0
        for prefab, amount in pairs(prefabs_with_num) do
            if inst.replica.container:Has(prefab, amount) then
                temp_count = temp_count + 1
            end
        end
        return temp_count == item_num
    end

    local function container_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("bundle")

        --V2C: blank string for controller action prompt
        inst.name = " "
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst:AddComponent("container")
        inst.components.container:WidgetSetup("loramia_building_electromagnetic_tower_of_creation_container")

        inst.persists = false
        return inst
    end
------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[ 配方
        3合金板
        1电路板
        1齿轮
        1电线
    ]]--
    CONSTRUCTION_PLANS["loramia_building_electromagnetic_tower_of_creation"] = { 
        Ingredient("nitre", 3),
        Ingredient("rocks", 1),
        Ingredient("goldnugget", 1),
        Ingredient("marble", 1),
    }
------------------------------------------------------------------------------------------------------------------------------------------------------------

return Prefab("loramia_building_electromagnetic_tower_of_creation", building_fn, assets),
    Prefab("loramia_building_electromagnetic_tower_of_creation_container", container_fn, assets)
-- ,MakePlacer("lightning_rod_placer", "lightning_rod", "lightning_rod", "idle")
