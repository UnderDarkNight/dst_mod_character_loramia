
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
        ThePlayer.components.loramia_com_recharge:DoDelta(-1)
    ----------------------------------------------------------------------------------------------------------------
    print("WARNING:PCALL END   +++++++++++++++++++++++++++++++++++++++++++++++++")
end)

if flg == false then
    print("Error : ",error_code)
end

-- dofile(resolvefilepath("test_fn/test.lua"))