
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ 界面调试
    local Widget = require "widgets/widget"
    local Image = require "widgets/image" -- 引入image控件
    local UIAnim = require "widgets/uianim"


    local Screen = require "widgets/screen"
    local AnimButton = require "widgets/animbutton"
    local ImageButton = require "widgets/imagebutton"
    local Menu = require "widgets/menu"
    local Text = require "widgets/text"
    local TEMPLATES = require "widgets/redux/templates"
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local flg,error_code = pcall(function()
    print("WARNING:PCALL START +++++++++++++++++++++++++++++++++++++++++++++++++")
    local x,y,z =    ThePlayer.Transform:GetWorldPosition()  
    ----------------------------------------------------------------------------------------------------------------    ----------------------------------------------------------------------------------------------------------------
    ----
        -- local HungerBadge = ThePlayer.HUD.controls.status.stomach
        -- local circleframe = HungerBadge.circleframe
        -- circleframe:Show()
        -- circleframe:GetAnimState():OverrideSymbol("frame_circle","loramia_status_meter","frame_circle")
        -- circleframe:GetAnimState():Hide("icon")

        -- local icon = circleframe:AddChild(UIAnim())
        -- icon:GetAnimState():SetBank("loramia_status_meter")
        -- icon:GetAnimState():SetBuild("loramia_status_meter")
        -- icon:GetAnimState():PlayAnimation("icon_1")
        -- local icon_sacle = 0.6
        -- icon:SetScale(icon_sacle,icon_sacle,icon_sacle)

        -- icon.inst:ListenForEvent("hungerdelta",function(_,data)
        --     data = data or {}
        --     local percent = data.newpercent or 1
        --     -- print("hunger percent",percent)
        --     if percent <= 0.25 then
        --         icon:GetAnimState():PlayAnimation("icon_4")
        --         HungerBadge.anim:GetAnimState():SetMultColour( 255 / 255, 0 / 255, 0 / 255, 1)
        --     elseif percent <= 0.5 then
        --         icon:GetAnimState():PlayAnimation("icon_3")
        --         HungerBadge.anim:GetAnimState():SetMultColour( 255 / 255, 204 / 255, 51 / 255, 1)
        --     elseif percent <= 0.75 then
        --         icon:GetAnimState():PlayAnimation("icon_2")
        --         HungerBadge.anim:GetAnimState():SetMultColour( 255 / 255, 204 / 255, 51 / 255, 1)
        --     else
        --         icon:GetAnimState():PlayAnimation("icon_1")
        --         HungerBadge.anim:GetAnimState():SetMultColour( 0 / 255, 255 / 255, 255 / 255, 1)
        --     end
        -- end,ThePlayer)

        -- circleframe.icon = icon
    ----------------------------------------------------------------------------------------------------------------
    ---
        -- ThePlayer.components.hunger:DoDelta(-10)
    ----------------------------------------------------------------------------------------------------------------
    --- 新的能量条
        -- local front_root = ThePlayer.HUD.controls.status


        



    ----------------------------------------------------------------------------------------------------------------
    ---
        -- if ThePlayer.test_task then
        --     ThePlayer.test_task:Cancel()
        -- end

        -- local up_flag = true
        -- ThePlayer.test_task = ThePlayer:DoPeriodicTask(0.5,function(inst)
        --     if up_flag then
        --         inst.components.loramia_com_recharge:DoDelta(1)
        --         if inst.components.loramia_com_recharge:GetPercent() == 1 then
        --             up_flag = false
        --         end
        --     else
        --         inst.components.loramia_com_recharge:DoDelta(-1)
        --         if inst.components.loramia_com_recharge:GetPercent() == 0 then
        --             up_flag = true
        --         end
        --     end
        -- end)
    ----------------------------------------------------------------------------------------------------------------
    ---
            -- local item = TheSim:FindFirstEntityWithTag("loramia_special_item")
            -- item.components.equippable.dapperness = TUNING.DAPPERNESS_HUGE
        -- ThePlayer.components.loramia_com_recharge:DoDelta(-100)
    ----------------------------------------------------------------------------------------------------------------
    ---
            -- TUNING.__light_test_fn = function(inst)
            --     inst.Light:SetFalloff(0.9)
            --     inst.Light:SetIntensity(.7)
            --     inst.Light:SetRadius(2.5)
            --     inst.Light:SetColour(0 / 255, 255 / 255, 255 / 255)
            -- end
    ----------------------------------------------------------------------------------------------------------------
    ---
            -- local battery = (TheSim:FindEntities(x,y,z,10,{"engineeringbattery"}) or {})[1]
            -- local item = (TheSim:FindEntities(x,y,z,10,{"loramia_building_guardian_creation"}) or {})[1]
            -- print(item,battery)
            -- -- -- item.components.circuitnode:ConnectTo("engineeringbattery")
            -- -- -- battery.components.circuitnode:ConnectTo("engineeringbatterypowered")
            -- -- -- item.components.circuitnode:AddNode(battery)
            -- -- -- battery.components.circuitnode:AddNode(item)
            -- print("IsConnected",item.components.circuitnode:IsConnected())

            -- -- battery.components.circuitnode:ForEachNode(function(inst, node)
            -- --     print("++++",inst, node)
            -- -- end)
            -- -- -- battery.components.fueled:DoDelta(-1000)
            -- -- -- battery.components.fueled:DoDelta(100)
            -- -- -- battery.components.fueled:StartConsuming()
            -- -- print(battery.components.fueled:GetDebugString())


            -- -- -- local battery_nodes = battery.components.circuitnode.nodes
            -- -- -- print(battery_nodes)
            -- -- -- print(battery:GetCurrentPlatform(),item:GetCurrentPlatform())

            -- item.components.circuitnode:ForEachNode(function(inst, node)
            --     print("++++",inst, node)
            -- end)
    ----------------------------------------------------------------------------------------------------------------
    ---
            -- local ents = TheSim:FindEntities(x,y,z,30,{"loramia_building_sharpstrike_creation_light"})
            -- local light  = ents[1]
            -- if light then                
            --     light.components.sanityaura.GetAura = function()
            --         return (TUNING.SANITYAURA_MED/4)*50
            --     end
            -- end

            -- local ents = TheSim:FindEntities(x,y,z,30,nil,{"player"},{"hound","pig"})
            -- for k, temp in pairs(ents) do
            --     local tx, ty, tz = temp.Transform:GetWorldPosition()
            --     local rot = temp.Transform:GetRotation()
            --     if temp:HasTag("hound") then
            --         local new = SpawnPrefab(math.random() < 0.5 and "gargoyle_hounddeath" or "gargoyle_houndatk")
            --         new.Transform:SetPosition(tx,ty,tz)
            --         new.Transform:SetRotation(rot)
            --         temp:Remove()
            --     elseif temp:HasTag("pig") then
            --         local new = SpawnPrefab(math.random() < 0.5 and "gargoyle_werepigdeath" or "gargoyle_werepigatk")
            --         new.Transform:SetPosition(tx,ty,tz)
            --         new.Transform:SetRotation(rot)
            --         temp:Remove()
            --     end
            --     SpawnPrefab("beefalo_transform_fx").Transform:SetPosition(tx,ty,tz)
            -- end
    ----------------------------------------------------------------------------------------------------------------
    ----------
        -- SpawnPrefab("loramia_spell_laser_custom_caster"):PushEvent("Set",{
        --     attacker = ThePlayer,
        --     pt = Vector3(x,0,z+3),
        --     onhitfn = function(target)
        --         print("onhit",target)
        --     end,
        --     workable_destroy_checker_fn = function(target)
        --         print("workable_can_destroy",target)
        --         return true
        --     end,
        --     trailfn = function(inst)
        --         inst.AnimState:SetAddColour(0, -1, 0, 0)
        --         inst.AnimState:SetMultColour(0, 1, 0, 1)
        --     end,
        --     scorchfn = function(inst)
        --         inst.AnimState:SetAddColour(0, -1, 0, 0)
        --         inst.AnimState:SetMultColour(0, 1, 0, 1)
        --     end,
        -- })
    ----------------------------------------------------------------------------------------------------------------
    --
        -- local inst = TheSim:FindFirstEntityWithTag("loramia_building_electromagnetic_tower_of_creation")
        -- print("++++",inst)
        -- -- inst.components.constructionsite:DropAllMaterials()
        -- for k, v in pairs(inst.components.constructionsite.materials) do
        --     -- print("+++",k,v)
        --     -- for k2, v2 in pairs(v) do
        --     --     print("+++",k2,v2)
        --     -- end

        --     -- v.amount = 0
        --     inst.components.constructionsite:RemoveMaterial(k,v.amount)
        -- end
        -- inst.components.constructionsite:DropAllMaterials()

        -- local scion = SpawnPrefab("rook_nightmare")
        -- scion.Transform:SetPosition(x,y,z)
        -- ThePlayer:PushEvent("makefriend")
        -- scion.components.follower:SetLeader(ThePlayer)
        for k, v in pairs(TUNING["loramia.Config"]) do
            print(k,v)
        end
    ----------------------------------------------------------------------------------------------------------------
    print("WARNING:PCALL END   +++++++++++++++++++++++++++++++++++++++++++++++++")
end)

if flg == false then
    print("Error : ",error_code)
end

-- dofile(resolvefilepath("test_fn/test.lua"))