-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local assets = {

}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 放置辅助器
    local PLACER_SCALE = 1.5

    local function OnUpdatePlacerHelper(helperinst)
        if not helperinst.placerinst:IsValid() then
            helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
            helperinst.AnimState:SetAddColour(0, 0, 0, 0)
        else
            local footprint = helperinst.placerinst.engineering_footprint_override or TUNING.WINONA_ENGINEERING_FOOTPRINT
            local range = TUNING.WINONA_BATTERY_RANGE - footprint
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

    local function OnEnableHelper(inst, enabled, recipename, placerinst)
        if enabled then
            if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
                inst.helper = CreateEntity()

                --[[Non-networked entity]]
                inst.helper.entity:SetCanSleep(false)
                inst.helper.persists = false

                inst.helper.entity:AddTransform()
                inst.helper.entity:AddAnimState()

                inst.helper:AddTag("CLASSIFIED")
                inst.helper:AddTag("NOCLICK")
                inst.helper:AddTag("placer")

                inst.helper.AnimState:SetBank("winona_battery_placement")
                inst.helper.AnimState:SetBuild("winona_battery_placement")
                inst.helper.AnimState:PlayAnimation("idle")
                inst.helper.AnimState:SetLightOverride(1)
                inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
                inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
                inst.helper.AnimState:SetSortOrder(1)
                inst.helper.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

                inst.helper.entity:SetParent(inst.entity)

                if placerinst and
                    placerinst.prefab ~= "winona_battery_low_item_placer" and
                    placerinst.prefab ~= "winona_battery_high_item_placer" and
                    recipename ~= "winona_battery_low" and
                    recipename ~= "winona_battery_high"
                then
                    inst.helper:AddComponent("updatelooper")
                    inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                    inst.helper.placerinst = placerinst
                    OnUpdatePlacerHelper(inst.helper)
                end
            end
        elseif inst.helper ~= nil then
            inst.helper:Remove()
            inst.helper = nil
        end
    end

    local function OnStartHelper(inst)--, recipename, placerinst)
        if inst.AnimState:IsCurrentAnimation("deploy") or inst.AnimState:IsCurrentAnimation("place") then
            inst.components.deployhelper:StopHelper()
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetPhysicsRadiusOverride(0.5)
	MakeObstaclePhysics(inst, inst.physicsradiusoverride)

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.PLACER_DEFAULT] / 2)

    inst:AddTag("structure")
	inst:AddTag("engineering")
    inst:AddTag("engineeringbattery") -- 向外供电的物品

    inst.AnimState:SetBank("winona_battery_low")
    inst.AnimState:SetBuild("winona_battery_low")
    inst.AnimState:PlayAnimation("idle_charge", true)
	for i = 1, 6 do
		local sym = "m"..tostring(i)
		inst.AnimState:SetSymbolLightOverride(sym, 0.2)
		inst.AnimState:SetSymbolBloom(sym)
	end
	inst.AnimState:SetSymbolLightOverride("meter_bar", 0.2)
	inst.AnimState:SetSymbolBloom("meter_bar")
	inst.AnimState:SetSymbolLightOverride("sprk_1", 0.3)
	inst.AnimState:SetSymbolLightOverride("sprk_2", 0.3)
	inst.AnimState:SetSymbolLightOverride("horror_fx", 1)
	inst.AnimState:Hide("HORROR")

    inst.MiniMapEntity:SetIcon("winona_battery_low.png")

    -----------------------------------------------------------------------------------
    -- 放置圈圈指示器
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
    -----------------------------------------------------------------------------------

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    -----------------------------------------------------------------------------------
    ---
        inst:AddComponent("inspectable")
    -----------------------------------------------------------------------------------
    --- 可拆除
        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        -- inst.components.workable:SetOnWorkCallback(OnWorked)
        inst.components.workable:SetOnFinishCallback(function()
            
            inst:Remove()
        end)
    -----------------------------------------------------------------------------------
    --- 电路节点
        inst:AddComponent("circuitnode")
        inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
        inst.components.circuitnode:SetFootprint(TUNING.WINONA_ENGINEERING_FOOTPRINT)
        inst.components.circuitnode:SetOnConnectFn(function() -- 有电器连接的时候执行（成功连接才会执行）
            print("battery.onconnect",math.random())
        end)
        inst.components.circuitnode:SetOnDisconnectFn(function()  -- 有电器断开连接的时候执行
            if not inst.components.circuitnode:IsConnected() then 
                print("battery.disconnect : empty")
            else
                print("battery.disconnect : not empty")
            end
        end)
        inst.components.circuitnode.connectsacrossplatforms = false
        inst.components.circuitnode.rangeincludesfootprint = true
        -- inst.components.circuitnode.IsEnabled = function(self) -- 让这个组件一直启用
        --     return true
        -- end
        -- inst.components.circuitnode.nodes = {}
        inst:ListenForEvent("engineeringcircuitchanged",function(inst) --- 有新的连接进来（即便后面连接失败也会触发）
            print(" ++++++ battery.engineeringcircuitchanged",math.random())
        end)
    -----------------------------------------------------------------------------------
    ---
        inst.OnUsedIndirectly = function(inst,doer) --- 玩家在范围内新建电器的时候执行
            
        end
        inst.CheckElementalBattery = function(inst) -- 检查能量源、月光、噩梦 能量
            
        end
        inst.ConsumeBatteryAmount = function(inst, cost, share, doer) -- 消耗电池数量
            
        end
    -----------------------------------------------------------------------------------
    --- 电池组件
        inst:AddComponent("battery")
        inst.components.battery.canbeused = function(inst, user)
            return true
        end
        inst.components.battery.onused = function(inst,user)
            --- 更新并消耗？？
            print("battery.onused",math.random())
        end
    -----------------------------------------------------------------------------------
    ---
        inst:AddComponent("fueled")
    -----------------------------------------------------------------------------------
    ---
    -----------------------------------------------------------------------------------
    ---
    -----------------------------------------------------------------------------------


    return inst
end

return Prefab("loramia_building_sharpstrike_creation", fn, assets)