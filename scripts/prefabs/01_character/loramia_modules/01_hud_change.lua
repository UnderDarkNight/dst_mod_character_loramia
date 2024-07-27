--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    ThePlayer.HUD.controls.status.heart:Show()

]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- HUD 修改相关组件
    local Widget = require "widgets/widget"
    local Image = require "widgets/image" -- 引入image控件
    local UIAnim = require "widgets/uianim"


    local Screen = require "widgets/screen"
    local AnimButton = require "widgets/animbutton"
    local ImageButton = require "widgets/imagebutton"
    local Menu = require "widgets/menu"
    local Text = require "widgets/text"
    local TEMPLATES = require "widgets/redux/templates"
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----- 血量修改
    -- local function hook_health_bage(HealthBadge)
    --     local over_index = { "topperanim","circleframe2","backing","anim","circleframe"}
        
    --     for k, index in pairs(over_index) do
    --         HealthBadge[index]:GetAnimState():OverrideSymbol("bg","moonlightcoda_hud_status_meter","bg")
    --         HealthBadge[index]:GetAnimState():OverrideSymbol("frame_circle","moonlightcoda_hud_status_meter","frame_circle")
    --         HealthBadge[index]:GetAnimState():OverrideSymbol("level","moonlightcoda_hud_status_meter","level")
    --     end

    --     HealthBadge.effigyanim:GetAnimState():OverrideSymbol("icon","moonlightcoda_hud_status_health","icon")
    --     HealthBadge.circleframe:GetAnimState():OverrideSymbol("icon","moonlightcoda_hud_status_health","icon")

    --     HealthBadge.anim:GetAnimState():SetMultColour(1,1,1,1)

    --     --------- 修改成可动动画
    --         HealthBadge.circleframe:Hide()
    --         HealthBadge.special_icon = HealthBadge:AddChild(UIAnim())
    --         HealthBadge.special_icon:GetAnimState():SetBank("moonlightcoda_hud_health")
    --         HealthBadge.special_icon:GetAnimState():SetBuild("moonlightcoda_hud_health")
    --         HealthBadge.special_icon:GetAnimState():PlayAnimation("icon_fx",true)
    --         local icon_scale = 1
    --         HealthBadge.special_icon:SetScale(icon_scale,icon_scale,icon_scale)

    --         HealthBadge.special_icon:MoveToFront()
    --         HealthBadge.sanityarrow:MoveToFront()

    --     --------- 添加后台特效

    --         HealthBadge.special_back_fx = HealthBadge:AddChild(UIAnim())
    --         HealthBadge.special_back_fx:GetAnimState():SetBank("moonlightcoda_hud_health")
    --         HealthBadge.special_back_fx:GetAnimState():SetBuild("moonlightcoda_hud_health")
    --         HealthBadge.special_back_fx:GetAnimState():PlayAnimation("fx",true)
    --         HealthBadge.special_back_fx:SetScale(0.5,0.5,0.5)
    --         HealthBadge.special_back_fx:GetAnimState():SetDeltaTimeMultiplier(0.7)
    --         HealthBadge.special_back_fx:MoveToBack()

    -- end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----- San 修改
    -- local function hook_sanity_bage(SanityBadge)
    --     local function display_switch()
    --         local LUNACY_TINT = { 191 / 255, 232 / 255, 240 / 255, 1 }
    --         SanityBadge.backing:GetAnimState():OverrideSymbol("bg", "status_sanity", "lunacy_bg")
    --         SanityBadge.anim:GetAnimState():SetMultColour(unpack(LUNACY_TINT))
    --         SanityBadge.circleframe:GetAnimState():OverrideSymbol("icon", "status_sanity", "lunacy_icon")
    --     end

    --     display_switch()

    --     local old_DoTransition = SanityBadge.DoTransition
    --     SanityBadge.DoTransition = function(self, ...)
    --         old_DoTransition(self, ...)
    --         display_switch()
    --     end

    -- end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Hunger 修改
    local function hook_hunger_badge(HungerBadge)
        local circleframe = HungerBadge.circleframe
        circleframe:Show()
        circleframe:GetAnimState():OverrideSymbol("frame_circle","loramia_status_meter","frame_circle")
        circleframe:GetAnimState():Hide("icon")
        local icon = circleframe:AddChild(UIAnim())
        icon:GetAnimState():SetBank("loramia_status_meter")
        icon:GetAnimState():SetBuild("loramia_status_meter")
        icon:GetAnimState():PlayAnimation("icon_1")
        local icon_sacle = 0.6
        icon:SetScale(icon_sacle,icon_sacle,icon_sacle)
        icon:SetPosition(0,-2,0)

        local function update_anim_by_percent(percent)
            if percent <= 0.25 then
                icon:GetAnimState():PlayAnimation("icon_4")
                HungerBadge.anim:GetAnimState():SetMultColour( 255 / 255, 0 / 255, 0 / 255, 1)
            elseif percent <= 0.5 then
                icon:GetAnimState():PlayAnimation("icon_3")
                HungerBadge.anim:GetAnimState():SetMultColour( 255 / 255, 204 / 255, 51 / 255, 1)
            elseif percent <= 0.75 then
                icon:GetAnimState():PlayAnimation("icon_2")
                HungerBadge.anim:GetAnimState():SetMultColour( 255 / 255, 204 / 255, 51 / 255, 1)
            else
                icon:GetAnimState():PlayAnimation("icon_1")
                HungerBadge.anim:GetAnimState():SetMultColour( 0 / 255, 255 / 255, 255 / 255, 1)
            end
        end

        update_anim_by_percent(ThePlayer.replica.hunger:GetPercent())

        icon.inst:ListenForEvent("hungerdelta",function(_,data)
            data = data or {}
            local percent = data.newpercent or 1
            -- print("hunger percent",percent)
            update_anim_by_percent(percent)
        end,ThePlayer)
        circleframe.icon = icon
    end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return function(inst)
    inst:DoTaskInTime(0,function()
        if ThePlayer and inst == ThePlayer and ThePlayer.HUD then
            pcall(function()
                -- hook_health_bage(ThePlayer.HUD.controls.status.heart)
                -- hook_sanity_bage(ThePlayer.HUD.controls.status.brain)
                hook_hunger_badge(ThePlayer.HUD.controls.status.stomach)
            end)
        end
    end)

end