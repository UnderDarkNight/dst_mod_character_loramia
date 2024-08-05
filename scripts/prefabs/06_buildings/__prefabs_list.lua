----------------------------------------------------
--- 本文件单纯返还路径
----------------------------------------------------

-- local function sum(a, b)
--     return a + b
-- end

-- local info = debug.getinfo(sum)

-- for k,v in pairs(info) do
--         print(k,':', info[k])
-- end

--------------------------------------------------------------------------
local addr_test = debug.getinfo(1).source           ---- 找到绝对路径

local temp_str_index = string.find(addr_test, "scripts/prefabs/")
local temp_addr = string.sub(addr_test,temp_str_index,-1)
-- print("fake error 6666666666666:",temp_addr)    ---- 找到本文件所处的相对路径

local temp_str_index2 = string.find(temp_addr,"/__prefabs_list.lua")

local Prefabs_addr_base = string.sub(temp_addr,1,temp_str_index2) .. "/"    --- 得到最终文件夹路径

---------------------------------------------------------------------------
-- local Prefabs_addr_base = "scripts/prefabs/01_loramia_items/"               --- 文件夹路径
local prefabs_name_list = {


    "01_sharpstrike_creation",                              --- 锋锐的创造物  发电机
    "01_sharpstrike_creation_light",                        --- 锋锐的创造物  灯光inst
    "02_swiftstrike_creation",                              --- 迅袭的创造物  陷阱
    "03_analytic_creation",                                 --- 解析的创造物
    "04_mysterious_creation",                               --- 神秘的创造物  帐篷
    "05_guardian_creation",                                 --- 守御的创造物  炮台
    "06_primordial_creation",                               --- 创世的创造物  月台


}

---------------------------------------------------------------------------
---- 正在测试的物品
if TUNING.UNDERWORLD_HANA_DEBUGGING_MODE == true then
    local debugging_name_list = {



    }
    for k, temp in pairs(debugging_name_list) do
        table.insert(prefabs_name_list,temp)
    end
end
---------------------------------------------------------------------------












local ret_addrs = {}
for i, v in ipairs(prefabs_name_list) do
    table.insert(ret_addrs,Prefabs_addr_base..v..".lua")
end
return ret_addrs