-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/loramia_building_esoteric_creation.zip"),
}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- workable
    local function OnFinishCallback(inst,worker)
        inst.components.lootdropper:SpawnLootPrefab("loramia_item_alloy_circuit_board")
        inst.components.lootdropper:SpawnLootPrefab("loramia_item_alloy_circuit_board")
        inst.components.lootdropper:SpawnLootPrefab("loramia_item_luminous_alloy_board")
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
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- acceptable
    local function is_in_battery_area(inst)     ---- 在充电区域
        if not inst.components.circuitnode:IsConnected() then
            return false
        end
        local ret_flag = false
        local battery = nil
        inst.components.circuitnode:ForEachNode(function(inst, node)
            if ret_flag == false and node and node:HasTag("engineeringbattery") then
                if node.components.fueled and not node.components.fueled:IsEmpty() and node.components.fueled.consuming then
                    ret_flag = true
                    battery = node
                end
            end
        end)
        return ret_flag,battery
    end
    local function GetItemStackNum(item)
        if item.components.stackable then
            return item.components.stackable:StackSize()
        else
            return 1
        end
    end
    -- local function IsFruitOrVeggie(item) --- 蔬菜和水果
    --     local cooking = require("cooking")
    --     local ingredients = cooking.ingredients
    --     local data = ingredients[item.prefab]
    --     if type(data) == "table" then
    --         local tags = data.tags or {}
    --         if tags and (tags["fruit"] or tags["veggie"]) then
    --             return true
    --         end
    --     end
    --     return false
    -- end
    --------------------------------------------------------------------------------------------------------
    --- 种子植物对应
        local temp_Fruit_Veggie_List = {
            ["asparagus"] = "asparagus_seeds",                      --- 芦笋种子
            ["carrot"] = "carrot_seeds",                            --- 胡萝卜种子
            ["corn"] = "corn_seeds",                                --- 玉米种子
            ["eggplant"] = "eggplant_seeds",                        --- 茄子种子
            ["garlic"] = "garlic_seeds",                            --- 大蒜种子
            ["onion"] = "onion_seeds",                              --- 洋葱种子
            ["pepper"] = "pepper_seeds",                            --- 辣椒种子
            ["potato"] = "potato_seeds",                            --- 土豆种子
            ["pumpkin"] = "pumpkin_seeds",                          --- 南瓜种子
            ["tomato"] = "tomato_seeds",                            --- 番茄种子
            ["dragonfruit"] = "dragonfruit_seeds",                  --- 火龙果种子
            ["durian"] = "durian_seeds",                            --- 榴莲种子
            ["pomegranate"] = "pomegranate_seeds",                  --- 石榴种子
            ["watermelon"] = "watermelon_seeds",                    --- 西瓜种子
        }
        local Fruit_Veggie_2_Seed_List = {}
        for origin_prefab,seed_name in pairs(temp_Fruit_Veggie_List) do
            Fruit_Veggie_2_Seed_List[origin_prefab] = seed_name
            Fruit_Veggie_2_Seed_List[origin_prefab.."_cooked"] = seed_name
            Fruit_Veggie_2_Seed_List[origin_prefab.."_dried"] = seed_name
        end
    --------------------------------------------------------------------------------------------------------
    --- 肉类
        local function IsMeat(item)
            local cooking = require("cooking")
            local ingredients = cooking.ingredients
            local data = ingredients[item.prefab]
            if type(data) == "table" then
                local tags = data.tags or {}
                if tags["meat"] or tags["fish"] then
                    return true
                end
            end
            return false
        end
    --------------------------------------------------------------------------------------------------------
    --- 糖类
        local function IsSweetener(item)
            local cooking = require("cooking")
            local ingredients = cooking.ingredients
            local data = ingredients[item.prefab]
            if type(data) == "table" then
                local tags = data.tags or {}
                if tags["sweetener"]  then
                    return true
                end
            end
            return false
        end
    --------------------------------------------------------------------------------------------------------
    local function acceptable_install(inst)
        inst:ListenForEvent("Loramia_OnEntityReplicated.loramia_com_acceptable",function(inst,replica_com)
            replica_com:SetText("loramia_building_primordial_creation",STRINGS.ACTIONS.GIVE.GENERIC)
            replica_com:SetSGAction("give")
            replica_com:SetTestFn(function(inst,item,doer,right_click)
                return true
            end)
        end)
        if not TheWorld.ismastersim then
            return
        end

        inst:AddComponent("loramia_com_acceptable")
        inst.components.loramia_com_acceptable:SetOnAcceptFn(function(inst,item,doer)
            if not is_in_battery_area(inst) then
                return false
            end
            ---------------------------------------------------------------------------
            --- 
                local item_num = GetItemStackNum(item)
            ---------------------------------------------------------------------------
            ---  花草切换
                local cutgrass_switch_list = {
                    ["petals"] = true,              --- 花瓣
                    ["petals_evil"] = true,         --- 恶魔花瓣
                    ["succulent_picked"] = true,    --- 蕨菜
                    ["foliage"] = true,             --- 多肉
                }
                if cutgrass_switch_list[item.prefab] then
                    TUNING.LORAMIA_FN:GiveItemByName(doer,"cutgrass",item_num)
                    inst:PushEvent("play_ring_sound")
                    item:Remove()
                    return true
                end
            ---------------------------------------------------------------------------
            --- 种子切换
                if Fruit_Veggie_2_Seed_List[item.prefab] then
                    TUNING.LORAMIA_FN:GiveItemByName(doer,Fruit_Veggie_2_Seed_List[item.prefab],item_num)
                    TUNING.LORAMIA_FN:GiveItemByName(doer,"compost",item_num)
                    inst:PushEvent("play_ring_sound")
                    item:Remove()
                    return true
                end
            ---------------------------------------------------------------------------
            --- 肉类切换
                if IsMeat(item) then
                    TUNING.LORAMIA_FN:GiveItemByName(doer,"spoiled_food",item_num)
                    TUNING.LORAMIA_FN:GiveItemByName(doer,"boneshard",item_num)
                    inst:PushEvent("play_ring_sound")
                    item:Remove()
                    return true
                end
            ---------------------------------------------------------------------------
            --- 糖类
                if IsSweetener(item) then
                    TUNING.LORAMIA_FN:GiveItemByName(doer,"ice",item_num)
                    inst:PushEvent("play_ring_sound")
                    item:Remove()
                    return true
                end
            ---------------------------------------------------------------------------
            --- 荧光果、发光浆果
                local light_fruit_list = {
                    ["wormlight"] = true,
                    ["wormlight_lesser"] = true,
                    ["lightbulb"] = true,
                }
                if light_fruit_list[item.prefab] then
                    TUNING.LORAMIA_FN:GiveItemByName(doer,"loramia_item_luminescent_crystal",item_num)
                    inst:PushEvent("play_ring_sound")
                    item:Remove()
                    return true
                end
            ---------------------------------------------------------------------------
            return false
        end)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- circuitnode
    -- local function circuitnode_OnInit(inst)
    --     inst:DoTaskInTime(0,function()
    --         inst.components.circuitnode:ConnectTo("engineeringbattery")
    --     end)
    -- end
    local function OnConnectCircuit(inst) -- 物品接入
        
    end

    local function OnDisconnectCircuit(inst) -- 物品断开
        if inst.components.circuitnode:IsConnected() then

        end
    end
    local function circuitnode_setup(inst)



        inst:AddComponent("circuitnode")
        inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
        -- inst.components.circuitnode:SetFootprint(TUNING.WINONA_ENGINEERING_FOOTPRINT)
        inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
        inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
        -- inst.components.circuitnode.connectsacrossplatforms = false
        -- inst.components.circuitnode.rangeincludesfootprint = true
        inst:DoTaskInTime(0,function()
            inst.components.circuitnode:ConnectTo("engineeringbattery")
        end)

        inst.AddBatteryPower = function()
            
        end
        
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 指示器安装
    local PLACER_SCALE = 1.5

    local function OnUpdatePlacerHelper(helperinst)
        if not helperinst.placerinst:IsValid() then
            helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
            helperinst.AnimState:SetAddColour(0, 0, 0, 0)
        else
            local range = TUNING.WINONA_BATTERY_RANGE - TUNING.WINONA_ENGINEERING_FOOTPRINT
            local hx, hy, hz = helperinst.Transform:GetWorldPosition()
            local px, py, pz = helperinst.placerinst.Transform:GetWorldPosition()
            --<= match circuitnode FindEntities range tests
            if distsq(hx, hz, px, pz) <= range * range and TheWorld.Map:GetPlatformAtPoint(hx, hz) == TheWorld.Map:GetPlatformAtPoint(px, pz) then
                helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
            else
                helperinst.AnimState:SetAddColour(0, 0, 0, 0)
            end
        end
    end

    local function CreatePlacerBatteryRing()
        local inst = CreateEntity()

        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOCLICK")
        inst:AddTag("placer")

        inst.AnimState:SetBank("winona_battery_placement")
        inst.AnimState:SetBuild("winona_battery_placement")
        inst.AnimState:PlayAnimation("idle_small")
        inst.AnimState:SetLightOverride(1)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(1)
        inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

        return inst
    end

    local function CreatePlacerRing()
        local inst = CreateEntity()

        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOCLICK")
        inst:AddTag("placer")

        inst.AnimState:SetBank("winona_spotlight_placement")
        inst.AnimState:SetBuild("winona_spotlight_placement")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetAddColour(0, .2, .5, 0)
        inst.AnimState:SetLightOverride(1)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(1)
        inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

        CreatePlacerBatteryRing().entity:SetParent(inst.entity)

        return inst
    end

    local function OnEnableHelper(inst, enabled, recipename, placerinst)
        if enabled then
            if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
                if recipename == "winona_spotlight" or (placerinst and placerinst.prefab == "winona_spotlight_item_placer") then
                    inst.helper = CreatePlacerRing()
                    inst.helper.entity:SetParent(inst.entity)
                else
                    inst.helper = CreatePlacerBatteryRing()
                    inst.helper.entity:SetParent(inst.entity)
                    if placerinst and (
                        placerinst.prefab == "winona_battery_low_item_placer" or
                        placerinst.prefab == "winona_battery_high_item_placer" or
                        recipename == "winona_battery_low" or
                        recipename == "winona_battery_high"
                    ) then
                        inst.helper:AddComponent("updatelooper")
                        inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                        inst.helper.placerinst = placerinst
                        OnUpdatePlacerHelper(inst.helper)
                    end
                end
            end
        elseif inst.helper ~= nil then
            inst.helper:Remove()
            inst.helper = nil
        end
    end

    local function OnStartHelper(inst)--, recipename, placerinst)
        if inst.AnimState:IsCurrentAnimation("place") then
            inst.components.deployhelper:StopHelper()
        end
    end
    local function indicator_setup(inst)
        if not TheNet:IsDedicated() then
            inst:AddComponent("deployhelper")
            inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
            inst.components.deployhelper:AddRecipeFilter("winona_catapult")
            inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
            inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
            inst.components.deployhelper:AddKeyFilter("winona_battery_engineering")
            inst.components.deployhelper.onenablehelper = OnEnableHelper
            inst.components.deployhelper.onstarthelper = OnStartHelper
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)


    -- inst.MiniMapEntity:SetIcon("loramia_building_esoteric_creation.tex")

    -- inst.AnimState:SetBank("loramia_building_esoteric_creation")
    -- inst.AnimState:SetBuild("loramia_building_esoteric_creation")
    -- inst.AnimState:PlayAnimation("idle",true)

    inst.AnimState:SetBank("loramia_building_esoteric_creation")
    inst.AnimState:SetBuild("loramia_building_esoteric_creation")
    inst.AnimState:PlayAnimation("idle",true)

    inst:AddTag("tent")
    inst:AddTag("structure")
    inst:AddTag("engineering")
    inst:AddTag("engineeringbatterypowered") 
    inst:AddTag("loramia_building_esoteric_creation")

    -----------------------------------------------------------
    --- acceptable
        acceptable_install(inst)
    -----------------------------------------------------------
    --- 指示器安装
        indicator_setup(inst)
    -----------------------------------------------------------
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    -----------------------------------------------------------
    --- 
        inst:ListenForEvent("play_ring_sound",function()
            inst.SoundEmitter:PlaySound("dontstarve/common/together/celestial_orb/active")
        end)
    -----------------------------------------------------------
    --- 
        inst:AddComponent("inspectable")
    -----------------------------------------------------------
    --- 
        inst:AddComponent("lootdropper")
    -----------------------------------------------------------
    --- 官方的workable
        workable_install(inst)
    -----------------------------------------------------------
    --- 官方的电器系统
        circuitnode_setup(inst)
    -----------------------------------------------------------
    inst.AddBatteryPower = function() end
    -----------------------------------------------------------

    MakeHauntableLaunch(inst)

    return inst
end

----------------------------------------------------------------------------------------------------------------------
--- placer
    local function CreatePlacerSpotlight()
        local inst = CreateEntity()

        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOCLICK")
        inst:AddTag("placer")

        inst.Transform:SetTwoFaced()

        inst.AnimState:SetBank("loramia_building_esoteric_creation")
        inst.AnimState:SetBuild("loramia_building_esoteric_creation")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetLightOverride(1)

        return inst
    end
    local function placer_postinit_fn(inst)
        --Show the spotlight placer on top of the spotlight range ground placer
        --Also add the small battery range indicator

        local placer2 = CreatePlacerBatteryRing()
        placer2.entity:SetParent(inst.entity)
        inst.components.placer:LinkEntity(placer2)

        placer2 = CreatePlacerSpotlight()
        placer2.entity:SetParent(inst.entity)
        inst.components.placer:LinkEntity(placer2)

        inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

        inst.deployhelper_key = "winona_battery_engineering"
    end
----------------------------------------------------------------------------------------------------------------------

return Prefab("loramia_building_esoteric_creation", fn, assets),
    MakePlacer("loramia_building_esoteric_creation_placer", "loramia_building_esoteric_creation", "loramia_building_esoteric_creation", "idle", nil, nil, nil, nil, nil, nil, placer_postinit_fn)


