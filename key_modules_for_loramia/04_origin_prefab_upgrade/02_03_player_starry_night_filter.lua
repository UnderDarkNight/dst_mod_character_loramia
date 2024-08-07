-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[




]]--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local starry_night_filter = nil
local function CreateFilter(inst,flag)
    if flag == true then
        if starry_night_filter == nil then
            local front_root = ThePlayer.HUD.controls
            ---------------------------------------------------------------
            ---
            local main_scale = 0.8
            ---------------------------------------------------------------
            ---
                local root = front_root:AddChild(Widget())
                root:SetHAnchor(0) -- 设置原点x坐标位置，0、1、2分别对应屏幕中、左、右
                root:SetVAnchor(0) -- 设置原点y坐标位置，0、1、2分别对应屏幕中、上、下
                root:SetPosition(0,0)
                root:MoveToBack()
                root:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC) --- 缩放模式
                root:SetClickable(false)
            ---------------------------------------------------------------
            --- 
                local bg = root:AddChild(Image())
                bg:SetTexture("images/widgets/loramia_starry_night_filter.xml","loramia_starry_night_filter.tex")
                bg:SetScale(main_scale,main_scale,main_scale)
                bg:SetPosition(0,100)
                bg:SetTint(1,1,1,1)
            ---------------------------------------------------------------
            ---
                starry_night_filter = root
            ---------------------------------------------------------------
        end
    else
        if starry_night_filter then
            starry_night_filter:Kill()
            starry_night_filter = nil
        end
    end
end

AddPlayerPostInit(function(inst)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("loramia_event.starry_night_filter",function(inst,flag)
            if ThePlayer == inst and ThePlayer.HUD then
                CreateFilter(inst,flag)
            end
        end)
    end    

end)

