-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----
    local item_list = {
        ["redgem"] = "redgem",
        ["bluegem"] = "bluegem",
        ["yellowgem"] = "yellowgem",
        ["purplegem"] = "purplegem",
        ["greengem"] = "greengem",
        ["thulecite"] = "thulecite",   -- 丢矿
        ["thulecite_pieces"] = "thulecite",  -- 丢矿碎片
        ["moonrocknugget"] = "moonrocknugget",
    }
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 安装容器界面
    local function container_Widget_change(theContainer)
        -----------------------------------------------------------------------------------
        ----- 容器界面名 --- 要独特一点，避免冲突
        local container_widget_name = "loramia_building_sharpstrike_creation_widget"

        -----------------------------------------------------------------------------------
        ----- 检查和注册新的容器界面
        local all_container_widgets = require("containers")
        local params = all_container_widgets.params
        if params[container_widget_name] == nil then
            params[container_widget_name] = {
                widget =
                {
                    slotpos = {
                        Vector3(0, 0, 0),
                    },
                    -- animbank = "ui_fish_box_5x4",
                    -- animbuild = "ui_fish_box_5x4",
                    pos = Vector3(-50, 0, 0),
                    side_align_tip = 160,
                },
                type = "chest",
                acceptsstacks = false,                
            }
            ------------------------------------------------------------------------------------------
            ---- item test
                params[container_widget_name].itemtestfn =  function(container_com, item, slot)
                    return item and item_list[item.prefab] or false
                end
            ------------------------------------------------------------------------------------------

            ------------------------------------------------------------------------------------------
        end
        
        theContainer:WidgetSetup(container_widget_name)
        ------------------------------------------------------------------------
        --- 开关声音
            -- if theContainer.widget then
            --     theContainer.widget.closesound = "turnoftides/common/together/water/splash/small"
            --     theContainer.widget.opensound = "turnoftides/common/together/water/splash/small"
            -- end
        ------------------------------------------------------------------------
    end

    local function add_container_before_not_ismastersim_return(inst)
        -------------------------------------------------------------------------------------------------
        ------ 添加背包container组件    --- 必须在 SetPristine 之后，
        -- local container_WidgetSetup = "wobysmall"
        if TheWorld.ismastersim then
            inst:AddComponent("container")
            -- inst.components.container.openlimit = 1  ---- 限制1个人打开
            -- inst.components.container:WidgetSetup(container_WidgetSetup)
            container_Widget_change(inst.components.container)

        else
            inst.OnEntityReplicated = function(inst)
                container_Widget_change(inst.replica.container)
            end
        end
        -------------------------------------------------------------------------------------------------
    end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 归一化坐标
    local function GetPointAtDistance(pt1,pt2,distance)
        return TUNING.LORAMIA_FN:GetPointAlongLineAtDistance(pt1,pt2,distance)
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----
    local LIGHT_SEARCH_RADIUS = 8*4    --- 探照范围
    local function GetClosestPoint2Player(inst) --- 玩家超出范围的时候，获取极限坐标
        local nearst_player = inst:GetNearestPlayer(true)
        local x,y,z = inst.Transform:GetWorldPosition()
        if nearst_player and nearst_player:IsValid() then
            ---- 归一化后指向那个位置
            local ret_pt = GetPointAtDistance(Vector3(x,y,z),Vector3(nearst_player.Transform:GetWorldPosition()),LIGHT_SEARCH_RADIUS)
            return ret_pt.x,0,ret_pt.z
        end
        return x,y,z
    end
    local function GetLightTargetPT(inst)  -- 获取探照坐标
        -- 紫宝石：优先探照没发疯的猪人。然后是最近的玩家。
        -- 其他时候：优先范围内最近玩家
        local item_type = inst:GetItemPrefabInContainer()
        local x,y,z = inst.Transform:GetWorldPosition()
        if item_type == "purplegem" then

            ------------------------------------------------------------------------------------------------
            --- 获取最近的没疯掉的猪
                local pigs = TheSim:FindEntities(x,y,z, LIGHT_SEARCH_RADIUS,{"pig"})
                local nearest_pig = nil
                local nearest_dist_sq = math.huge
                for k, temp_target in pairs(pigs) do
                    if temp_target.components.werebeast and not temp_target.components.werebeast:IsInWereState() then
                        local temp_dis_sq = inst:GetDistanceSqToInst(temp_target)
                        if temp_dis_sq < nearest_dist_sq then
                            nearest_dist_sq = temp_dis_sq
                            nearest_pig = temp_target
                        end
                    end
                end
                if nearest_pig then
                    return nearest_pig.Transform:GetWorldPosition()
                end
            ------------------------------------------------------------------------------------------------
            --- 获取最近的玩家
                local ents = TheSim:FindEntities(x,y,z, LIGHT_SEARCH_RADIUS,{"player"},{"playerghost"})
                local nearest_player = nil
                local nearest_dist_sq = math.huge
                for k, temp_target in pairs(ents) do
                    local temp_dis_sq = inst:GetDistanceSqToInst(temp_target)
                    if temp_dis_sq < nearest_dist_sq then
                        nearest_dist_sq = temp_dis_sq
                        nearest_player = temp_target
                    end
                end
                if nearest_player then
                    return nearest_player.Transform:GetWorldPosition()
                end
            ------------------------------------------------------------------------------------------------
            -- return x,y,z
            x,y,z = GetClosestPoint2Player(inst)
            return x,y,z
        else            
            if inst:IsNearPlayer(LIGHT_SEARCH_RADIUS,true) then
                local temp_player = inst:GetNearestPlayer(true)
                return temp_player.Transform:GetWorldPosition()
            end
            x,y,z = GetClosestPoint2Player(inst)
            return x,y,z
        end
    end
    local function light_fx_move_2_tar_pt(light_fx,tar_x,tar_y,tar_z) -- 让灯光移动到目标点
        local x,y,z = light_fx.Transform:GetWorldPosition()
        local dx = tar_x - x
        -- local dy = tar_y - y
        local dz = tar_z - z
        tar_x = x + dx * 0.1
        -- tar_y = y + dy * 0.1
        tar_z = z + dz * 0.1
        light_fx.Transform:SetPosition(tar_x,0,tar_z)
    end
    local function OnUpdateLightServer(inst)
        --------------------------------------------------------------------
        --- 白天关灯
            -- if TheWorld.state.isday then
            --     if inst.ligt_off_task == nil and inst.light_fx then
            --         inst.ligt_off_task = inst:DoTaskInTime(3,function()
            --             inst.light_fx:Remove()
            --             inst.light_fx = nil
            --             inst:PushEvent("light_off")
            --         end)
            --     end
            --     return
            -- end
        --------------------------------------------------------------------
        --- 
            if inst.components.fueled:IsEmpty() then
                if inst.ligt_off_task == nil and inst.light_fx then
                    inst.ligt_off_task = inst:DoTaskInTime(0,function()
                        inst.light_fx:Remove()
                        inst.light_fx = nil
                        inst:PushEvent("light_off")
                    end)
                end
                return
            end
        --------------------------------------------------------------------
        --- 其他时间开灯
            if inst.light_fx == nil or not inst.light_fx:IsValid() then
                inst.light_fx = SpawnPrefab("loramia_building_sharpstrike_creation_light")
                inst:ListenForEvent("onremove",function()
                    inst.light_fx:Remove()
                end)
                inst.light_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.light_fx.Ready = true
                inst:PushEvent("light_on")
            end
        --------------------------------------------------------------------
        ---
            local light_fx = inst.light_fx
            if light_fx == nil then
                return
            end
            light_fx.type = inst:GetItemPrefabInContainer()
        --------------------------------------------------------------------
        ---
            local tar_x,tar_y,tar_z = GetLightTargetPT(inst)
            -- light_fx.Transform:SetPosition(tar_x,tar_y,tar_z)
            light_fx_move_2_tar_pt(light_fx,tar_x,tar_y,tar_z)
        --------------------------------------------------------------------


    end
    local function entitywake_fn(inst)
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateLightServer)
    end
    local function entitysleep_fn(inst)
        inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateLightServer)
        if inst.light_fx then
            inst.light_fx:Remove()
            inst.light_fx = nil
        end
    end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return function(inst)
    ------------------------------------------------------------------------
    --- 刷新器
        inst:AddComponent("updatelooper")
    ------------------------------------------------------------------------
    --- 容器界面安装
        add_container_before_not_ismastersim_return(inst)
    ------------------------------------------------------------------------
    if not TheWorld.ismastersim then
        return
    end
    ------------------------------------------------------------------------
    --- 
        inst.GetItemPrefabInContainer = function(inst)
            local item = inst.components.container:GetItemInSlot(1)
            if item and item_list[item.prefab] then
                return item_list[item.prefab]
            end
            return "nil"
        end
    ------------------------------------------------------------------------
    ---
        inst:ListenForEvent("entitywake",entitywake_fn)
        inst:ListenForEvent("entitysleep",entitysleep_fn)
    ------------------------------------------------------------------------

end