author = "幕夜之下"
-- from stringutil.lua


----------------------------------------------------------------------------
--- 版本号管理（暂定）：最后一位为内部开发版本号，或者修复小bug的时候进行增量。
---                   倒数第二位为对外发布的内容量版本号，有新内容的时候进行增量。
---                   第二位为大版本号，进行主题更新、大DLC发布的时候进行增量。
---                   第一位暂时预留。 
----------------------------------------------------------------------------
local the_version = "0.00.00.00000"



name = "洛拉米亚"
description = [[

  洛拉米亚
  
]]

version = the_version ------ MOD版本，上传的时候必须和已经在工坊的版本不一样

api_version = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"
forumthread = ""
dont_starve_compatible = true
dst_compatible = true
all_clients_require_mod = true

priority = 0  -- MOD加载优先级 影响某些功能的兼容性，比如官方Com 的 Hook


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

    -- {
    --     name = "LEVEL_RETENTION",
    --     label = "换角色等级保留 Level retention",
    --     hover = "Saving character levels when changing characters",
    --     options =  {
    --       {description = "OFF", data = false},
    --       {description = "ON", data = true},
    --     },
    --     default = true,
    -- },
    {
      name = "FFFFFFF",
      label = "", --- 隔断测试
      hover = "",
      options = {{description = "", data = 0}},
      default = 0,
    },

    ---------------------------------------------------------------------------


    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------

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
