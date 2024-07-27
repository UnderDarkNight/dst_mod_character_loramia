------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    角色基础初始化

]]--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



local function Language_check()
    local language = "en"
    if type(TUNING["loramia.Language"]) == "function" then
        language = TUNING["loramia.Language"]()
    elseif type(TUNING["loramia.Language"]) == "string" then
        language = TUNING["loramia.Language"]
    end
    return language
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 角色立绘大图
    GLOBAL.PREFAB_SKINS["loramia"] = {
        "loramia_none",
    }
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 角色选择时候都文本
    if Language_check() == "ch" then
        -- The character select screen lines  --人物选人界面的描述
        STRINGS.CHARACTER_TITLES["loramia"] = "洛拉米亚"
        STRINGS.CHARACTER_NAMES["loramia"] = "洛拉米亚"
        STRINGS.CHARACTER_DESCRIPTIONS["loramia"] = "AAAAAA"
        STRINGS.CHARACTER_QUOTES["loramia"] = "XXXXXXXX"

        -- Custom speech strings  ----人物语言文件  可以进去自定义
        -- STRINGS.CHARACTERS[string.upper("loramia")] = require "speech_loramia"

        -- The character's name as appears in-game  --人物在游戏里面的名字
        STRINGS.NAMES[string.upper("loramia")] = "洛拉米亚"
        STRINGS.SKIN_NAMES["loramia_none"] = "洛拉米亚"  --检查界面显示的名字

        --生存几率
        STRINGS.CHARACTER_SURVIVABILITY["loramia"] = "特别容易"
    else
        -- The character select screen lines  --人物选人界面的描述
        STRINGS.CHARACTER_TITLES["loramia"] = "Loramia"
        STRINGS.CHARACTER_NAMES["loramia"] = "Loramia"
        STRINGS.CHARACTER_DESCRIPTIONS["loramia"] = "AAAAAA"
        STRINGS.CHARACTER_QUOTES["loramia"] = "XXXXXXXX"

        -- Custom speech strings  ----人物语言文件  可以进去自定义
        -- STRINGS.CHARACTERS[string.upper("loramia")] = require "speech_loramia"

        -- The character's name as appears in-game  --人物在游戏里面的名字
        STRINGS.NAMES[string.upper("loramia")] = "Loramia"
        STRINGS.SKIN_NAMES["loramia_none"] = "Loramia"  --检查界面显示的名字

        --生存几率
        STRINGS.CHARACTER_SURVIVABILITY["loramia"] = "easy"

    end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
------增加人物到mod人物列表的里面 性别为女性（ MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL）
    AddModCharacter("loramia", "FEMALE")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----选人界面人物三维显示
    TUNING[string.upper("loramia").."_HEALTH"] = 150
    TUNING[string.upper("loramia").."_HUNGER"] = 300
    TUNING[string.upper("loramia").."_SANITY"] = 150
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----选人界面初始物品显示，物品相关的prefab
    TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT[string.upper("loramia")] = {"log"}
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
