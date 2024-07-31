--------------------------------------------------------------------------------------------------------
--- 所有 prefab 的加载入口
--- 每个小类里的文件名单，统一用 __prefabs_list.lua  ，注意每个lua文件里的目录str不一样。
--- 
--------------------------------------------------------------------------------------------------------

local file_folders = {
    "00_others",            ---- 其他东西
    "01_character",         ---- 角色相关
    "02_items",             ---- 物品
    
    "05_spells",            ---- 技能物品    
    "06_buildings",         ---- 建筑物    
}


local function Load_lua_file_2_prefabs_table(tempAddr)
    ---- tempAddr  :      "prefabs/XXX/XXX.lua"
    local __temp = string.gsub(tempAddr,"//", "/")  -- 删除路径上的双斜线
    tempAddr = __temp
    
    local function self_load_file_to_prefabs_by_pcall(pcall_retFlag,...)
        local ret_prefabs_table = {}
        local arg = {...}
        if pcall_retFlag == true then
            for i, v in ipairs(arg) do
                if v then
                    table.insert(ret_prefabs_table,v)
                end
            end
        else
            print("Error : Load lua file error : ")
            print("Error:  "..tostring(tempAddr))
            for k, v in pairs(arg) do
                if v then
                    print("Error:  "..v)
                end
            end
        end
        return ret_prefabs_table
    end

    local crash_flag,lua_file = pcall(loadfile,tempAddr)   ---- load lua file
    if crash_flag == true then
        local temp_prefabs = self_load_file_to_prefabs_by_pcall(pcall(lua_file))
        return temp_prefabs
    else
        print("loadfile lua_file  Error ")
        print(lua_file)
        return {}
    end
end


local all_prefabs = {}

for i, temp_folder in ipairs(file_folders) do
    ---- step 1 : 拼接得到小类文件夹路径，用 require 加载这个lua 路径 得到内部列表。
    local full_subclass_addr = "prefabs/"..temp_folder.."/__prefabs_list"              
    local crash_flag,temp_prefabs_addr_list = pcall(require,full_subclass_addr)

    ---- step 2 : 加载没崩溃的时候，根据这个列表，载入目标lua里的所有内容。
    if crash_flag == true then  
                for k, prefab_lua_addr in pairs(temp_prefabs_addr_list) do
                            local temp_prefabs_table = Load_lua_file_2_prefabs_table(prefab_lua_addr)  ----- 得到了每个lua 文件的返回内容。
                            for ii, temp_prefab in ipairs(temp_prefabs_table) do
                                if temp_prefab then
                                    table.insert(all_prefabs,temp_prefab)
                                end
                            end
                end
    else
        print("Load prefabs Error : temp_prefabs_addr_list")      
        print(temp_prefabs_addr_list)
    end

end

return unpack(all_prefabs)     --- unpack for PrefabFiles ( in modmian.lua  ) 