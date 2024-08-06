author = "幕夜之下"
-- from stringutil.lua


----------------------------------------------------------------------------
--- 版本号管理（暂定）：最后一位为内部开发版本号，或者修复小bug的时候进行增量。
---                   倒数第二位为对外发布的内容量版本号，有新内容的时候进行增量。
---                   第二位为大版本号，进行主题更新、大DLC发布的时候进行增量。
---                   第一位暂时预留。 
----------------------------------------------------------------------------
local the_version = "0.00.00.00000"


--------------------------------------------------------------------------------------------------------------------------------------------------------
-- 语言相关的基础API  ---- 参数表： loc.lua 里面的localizations 表，code 为 这里用的index
  local function IsChinese()
    if locale == nil then
      return true
    else
      return locale == "zh" or locate == "zht" or locate == "zhr" or false
    end
  end
  local function ChooseTranslationTable_Test(_table)
    if ChooseTranslationTable then
      return ChooseTranslationTable(_table)
    else
      return _table["zh"]
    end
  end
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- from stringutil.lua
  local function tostring(arg)
    if arg == true then
      return "true"
    elseif arg == false then
      return "false"
    elseif arg == nil then
      return "nil"
    end    
    return arg .. ""
  end
  local function ipairs(tbl)
    return function(tbl, index)
      index = index + 1
      local next = tbl[index]
      if next then
        return index, next
      end
    end, tbl, 0
  end
--------------------------------------------------------------------------------------------------------------------------------------------------------

  local function GetName()  
    local temp_table = {
        "Loramia",                               ----- 默认情况下(英文)
        ["zh"] = "洛拉米亚",                                 ----- 中文
    }
    return ChooseTranslationTable_Test(temp_table)
  end

  local function GetDesc()
    local temp_table = {
      [[

        Loramia

      ]],
      ["zh"] = [[

        洛拉米亚

      ]]
    }
    local ret = the_version .. "  \n\n"..ChooseTranslationTable_Test(temp_table)
    return ret
  end

name = GetName() or "Loramia"
description = GetDesc() or "Loramia"
version = the_version or 0.1 ------ MOD版本，上传的时候必须和已经在工坊的版本不一样
api_version = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"
forumthread = ""
dont_starve_compatible = true
dst_compatible = true
all_clients_require_mod = true
priority = 0  -- MOD加载优先级 影响某些功能的兼容性，比如官方Com 的 Hook


  ----------------------------------------------------------------------------------------------------------
  --- options
    -- local function Create_Number_Setting(start_num,stop_num,delta_num)
    --     local temp_options = {}
    --     local temp_index = 1
    --     delta_num = delta_num or 1
    --     for i = start_num, stop_num, delta_num do
    --         temp_options[temp_index] = {description = tostring(i), data = i}
    --         temp_index = temp_index + 1
    --     end
    --     return temp_options
    -- end
    local function Create_Number_Setting(start_num, stop_num, delta_num)
        local temp_options = {}
        local temp_index = 1
        delta_num = delta_num or 1
        local i = start_num
    
        -- 使用 while 循环代替 for 循环
        while i <= stop_num do
            temp_options[temp_index] = {description = tostring(i), data = i}
            temp_index = temp_index + 1
            i = i + delta_num
        end
    
        return temp_options
    end
    local options_number_0_to_100 = Create_Number_Setting(0,100)
    local options_number_1_to_100 = Create_Number_Setting(1,100)
    local options_number_1_to_20 = Create_Number_Setting(1,20)
----------------------------------------------------------------------------------------------------------
--- options percent
  local function Create_Percent_Setting(start_num, stop_num, delta_num)
    local temp_options = {}
    local temp_index = 1
    delta_num = delta_num or 0.01  -- 设置默认值
    local i = start_num
    local epsilon = 0.000001  -- 精度容差
    -- 使用 while 循环代替 for 循环
    while i < stop_num + epsilon do
        temp_options[temp_index] = {description = tostring(i * 100) .. "%", data = i}
        temp_index = temp_index + 1
        i = i + delta_num
    end
    return temp_options
  end
  local function Create_Percent_Setting_With_1000_Mult(start_num, stop_num, delta_num)
      local temp_options = Create_Number_Setting(start_num, stop_num, delta_num)
      for i, option in ipairs(temp_options) do
          option.description = (option.data/10) .. "%"
      end
      return temp_options
  end  
----------------------------------------------------------------------------------------------------------
--- 按键
  local keys_option = {
    {description = "KEY_A", data = "KEY_A"},
    {description = "KEY_B", data = "KEY_B"},
    {description = "KEY_C", data = "KEY_C"},
    {description = "KEY_D", data = "KEY_D"},
    {description = "KEY_E", data = "KEY_E"},
    {description = "KEY_F", data = "KEY_F"},
    {description = "KEY_G", data = "KEY_G"},
    {description = "KEY_H", data = "KEY_H"},
    {description = "KEY_I", data = "KEY_I"},
    {description = "KEY_J", data = "KEY_J"},
    {description = "KEY_K", data = "KEY_K"},
    {description = "KEY_L", data = "KEY_L"},
    {description = "KEY_M", data = "KEY_M"},
    {description = "KEY_N", data = "KEY_N"},
    {description = "KEY_O", data = "KEY_O"},
    {description = "KEY_P", data = "KEY_P"},
    {description = "KEY_Q", data = "KEY_Q"},
    {description = "KEY_R", data = "KEY_R"},
    {description = "KEY_S", data = "KEY_S"},
    {description = "KEY_T", data = "KEY_T"},
    {description = "KEY_U", data = "KEY_U"},
    {description = "KEY_V", data = "KEY_V"},
    {description = "KEY_W", data = "KEY_W"},
    {description = "KEY_X", data = "KEY_X"},
    {description = "KEY_Y", data = "KEY_Y"},
    {description = "KEY_Z", data = "KEY_Z"},
    {description = "KEY_F1", data = "KEY_F1"},
    {description = "KEY_F2", data = "KEY_F2"},
    {description = "KEY_F3", data = "KEY_F3"},
    {description = "KEY_F4", data = "KEY_F4"},
    {description = "KEY_F5", data = "KEY_F5"},
    {description = "KEY_F6", data = "KEY_F6"},
    {description = "KEY_F7", data = "KEY_F7"},
    {description = "KEY_F8", data = "KEY_F8"},
    {description = "KEY_F9", data = "KEY_F9"},
  
  }
----------------------------------------------------------------------------------------------------------
--- title
  -- local function GetTitle(name)
  --    local origin_length = "                                              "
  --    ---- 根据name的文本长度，替换空格前面的部分
  --    local length = string.len(name)
  --    local temp_length = origin_length:sub(1,length)
  --    return temp_length .. name .. origin_length:sub(length+1,origin_length:len())
  -- end
    local function GetTitle(name)
      -- 定义原始字符串的长度和填充字符
      local origin_length = 65  -- 原始字符串的总长度
      local padding_char = ' '  -- 用于填充的字符

      -- 获取 name 的长度
      local length = 0
      for _ in name:gmatch(".") do
          length = length + 1
      end

      -- 计算右边需要的空格数量
      local right_padding = origin_length - length

      -- 创建右侧的填充
      local right_padding_str = padding_char:rep(right_padding)

      -- 返回格式化后的字符串
      return name .. right_padding_str
  end
----------------------------------------------------------------------------------------------------------

configuration_options =
{
    {
        name = "LANGUAGE",
        label = "Language/语言",
        hover = "Set Language/设置语言",
        options =
        {
          {description = "Auto/自动", data = "auto"},
          {description = "English", data = "en"},
          {description = "中文", data = "ch"},
        },
        default = "auto",
    },
    ---------------------------------------------------------------------------
      {name = "AAAA",label = IsChinese() and GetTitle("角色") or GetTitle("Character") ,hover = "",options = {{description = "", data = 0}},default = 0,},
    ---------------------------------------------------------------------------
      {
        name = "RECHARGE_UP_BY_TILES",
        label = IsChinese() and "按地块充能" or "Recharge by Tiles",
        hover = IsChinese() and "按地块充能" or "Recharge by Tiles",
        options =  {
          {description = "1", data = 1},
          {description = "5", data = 5},
          {description = "10", data = 10},
          {description = "20", data = 20},
          {description = "30", data = 30},
          {description = "40", data = 40},
        },
        default = 30,
      },
      {
        name = "SPEED_BY_RECHARGE_VALUE",
        label = IsChinese() and "充能值速度加成" or "Speed by Recharge Value",
        hover = IsChinese() and "充能值速度加成" or "Speed by Recharge Value",
        options = Create_Percent_Setting_With_1000_Mult(0,500,10),
        default = 100,
      },
      {
        name = "HUNGER_BY_RECHARGE_VALUE",
        label = IsChinese() and "充能值耗电量加成" or "Hunger by Recharge Value",
        hover = IsChinese() and "充能值耗电量加成" or "Hunger by Recharge Value",
        options = Create_Percent_Setting_With_1000_Mult(0,500,10),
        default = 200,
      },
    ---------------------------------------------------------------------------
      {name = "AAAA",label = IsChinese() and GetTitle("激光炮") or GetTitle("Laser Cannon") ,hover = "",options = {{description = "", data = 0}},default = 0,},
    ---------------------------------------------------------------------------
      {
        name = "LASER_CANNON_HUNGER_VALUE_COST",
        label = IsChinese() and "电池消耗" or "Battery Value Cost",
        hover = IsChinese() and "电池消耗" or "Battery Value Cost",
        options = Create_Number_Setting(0,300,10),
        default = 150,
      },
      {
        name = "LASER_CANNON_RECHARGE_VALUE_COST",
        label = IsChinese() and "充能值消耗" or "Recharge Value Cost",
        hover = IsChinese() and "充能值消耗" or "Recharge Value Cost",
        options = Create_Number_Setting(1,20,1),
        default = 5,
      },
      {
        name = "LASER_CANNON_DAMAGE",
        label = IsChinese() and "伤害" or "Damage",
        hover = IsChinese() and "伤害" or "Damage",
        options = Create_Number_Setting(50,500,10),
        default = 200,
      },
    ---------------------------------------------------------------------------
      {name = "AAAA",label = IsChinese() and GetTitle("宇宙之翼") or GetTitle("Wing of the Universe") ,hover = "",options = {{description = "", data = 0}},default = 0,},
      {
        name = "WING_OF_THE_UNIVERSE_SPEED_MULT",
        label = IsChinese() and "速度加成" or "Speed Bonus",
        hover = IsChinese() and "速度加成" or "Speed Bonus",
        options = Create_Percent_Setting_With_1000_Mult(0,1000,100),
        default = 500,
      },
      {
        name = "WING_OF_THE_UNIVERSE_OCEAN_WALK",
        label = IsChinese() and "水上行走" or "Ocean Walk",
        hover = IsChinese() and "水上行走" or "Ocean Walk",
        options =  {
          {description = IsChinese() and "关" or "OFF", data = false},
          {description = IsChinese() and "开" or "ON", data = true},
        },
        default = true,
      },
    ---------------------------------------------------------------------------
      {name = "AAAA",label = IsChinese() and GetTitle("洛拉米亚的制服") or GetTitle("Loramia's Uniform") ,hover = "",options = {{description = "", data = 0}},default = 0,},
      {
        name = "LORAMIA_UNIFORM_DAMAGETAKEN_MULT",
        label = IsChinese() and "伤害减免" or "Damage Reduction",
        hover = IsChinese() and "伤害减免" or "Damage Reduction",
        options = Create_Percent_Setting_With_1000_Mult(10,950,10),
        default = 500,
      },
    ---------------------------------------------------------------------------
      {name = "AAAA",label = IsChinese() and GetTitle("神秘的创造物(帐篷)") or GetTitle("Mysterious Creation (tent)") ,hover = "",options = {{description = "", data = 0}},default = 0,},
      {
        name = "MYSTERIOUS_CREATION_COST_PERCENT",
        label = IsChinese() and "每秒消耗" or "Consumption per second",
        hover = IsChinese() and "每秒消耗" or "Consumption per second",
        options = Create_Percent_Setting_With_1000_Mult(1,50,1),
        default = 10,
      },
      {
        name = "MYSTERIOUS_CREATION_HUNGER_VALUE_UP",
        label = IsChinese() and "电池每秒恢复" or "Battery Recovery Per Second",
        hover = IsChinese() and "电池每秒恢复" or "Battery Recovery Per Second",
        options = Create_Number_Setting(30,120,10),
        default = 50,
      },
    ---------------------------------------------------------------------------
      {name = "AAAA",label = IsChinese() and GetTitle("钢铁犀牛") or GetTitle("Iron Rhino") ,hover = "",options = {{description = "", data = 0}},default = 0,},
      {
        name = "IRON_RHINO_MAX_HEALTH",
        label = IsChinese() and "生命值" or "Health",
        hover = IsChinese() and "生命值" or "Health",
        options = Create_Number_Setting(1000,20000,1000),
        default = 1000,
      },
      {
        name = "IRON_RHINO_DAMAGE",
        label = IsChinese() and "伤害" or "Damage",
        hover = IsChinese() and "伤害" or "Damage",
        options = Create_Number_Setting(10,500,10),
        default = 100,
      },
      {
        name = "IRON_RHINO_HEALTH_REGEN_PER_SECOND",
        label = IsChinese() and "生命每秒回复" or "Health Regeneration Per Second",
        hover = IsChinese() and "生命每秒回复" or "Health Regeneration Per Second",
        options = Create_Number_Setting(0.1,20,0.1),
        default = 1,
      },
      {
        name = "IRON_RHINO_CLOSE_2_PLAYER_HOTKEY",
        label = IsChinese() and "召回快捷键" or "Recall Hotkey",
        hover = IsChinese() and "召回快捷键" or "Recall Hotkey",
        options = keys_option,
        default = "KEY_F7",
      },

    ---------------------------------------------------------------------------
      {name = "AAAA",label = IsChinese() and GetTitle("其他") or GetTitle("Other") ,hover = "",options = {{description = "", data = 0}},default = 0,},
      {
        name = "DEBUGGING_MOD",
        label = "开发者模式",
        hover = "开发者模式" ,
        options =  {
          {description = "OFF", data = false},
          {description = "ON", data = true},
        },
        default = false,
      },

----------------------------------------------------------------------------------------------------------
-- ----- 角色相关的管理设置
--     {
--       name = "FFFFFFF",
--       label = IsChinese() and "角色相关设置" or "Character-related settings", --- 隔断测试
--       hover = "",
--       options = {{description = "", data = 0}},
--       default = 0,
--     },

--     {
--       name = "ALLOW_CHARACTERS",
--       label = IsChinese() and "加载角色" or "Load Characters",
--       hover = IsChinese() and "允许使用本MOD的角色" or "The characters in this mod are allowed to be used",
--       options =
--       {
--         {description = IsChinese() and "加载" or "ON", data = true},
--         {description = IsChinese() and "不加载" or "OFF", data = false},
--       },
--       default = true,
--     },
--     {
--       name = "SPELL_KEY_A",
--       label = IsChinese() and "角色主要技能" or "Primary Spell",
--       hover = IsChinese() and "角色主要技能" or "Primary Spell",
--       options = keys_option,
--       default = "KEY_F5",
--     },
--     {
--       name = "SPELL_KEY_B",
--       label = IsChinese() and "角色辅助技能" or "Auxiliary Spell",
--       hover = IsChinese() and "角色辅助技能" or "Auxiliary Spell",
--       options = keys_option,
--       default = "KEY_F6",
--     },
----------------------------------------------------------------------------------------------------------

  
}
