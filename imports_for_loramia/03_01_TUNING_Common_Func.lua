--------------------------------------------------------------------------------------------
------ 常用函数放 TUNING 里
--------------------------------------------------------------------------------------------
----- RPC 命名空间
TUNING["loramia.RPC_NAMESPACE"] = "loramia_RPC"


--------------------------------------------------------------------------------------------

TUNING["loramia.fn"] = {}
TUNING["loramia.fn"].GetStringsTable = function(prefab_name)
    -------- 读取文本表
    -------- 如果没有当前语言的问题，调取中文的那个过去
    -------- 节省重复调用运算处理
    if TUNING["loramia.fn"].GetStringsTable_last_prefab_name == prefab_name then
        return TUNING["loramia.fn"].GetStringsTable_last_table or {}
    end


    local LANGUAGE = "ch"
    if type(TUNING["loramia.Language"]) == "function" then
        LANGUAGE = TUNING["loramia.Language"]()
    elseif type(TUNING["loramia.Language"]) == "string" then
        LANGUAGE = TUNING["loramia.Language"]
    end
    local ret_table = prefab_name and TUNING["loramia.Strings"][LANGUAGE] and TUNING["loramia.Strings"][LANGUAGE][tostring(prefab_name)] or nil
    if ret_table == nil and prefab_name ~= nil then
        ret_table = TUNING["loramia.Strings"]["ch"][tostring(prefab_name)]
    end

    ret_table = ret_table or {}
    TUNING["loramia.fn"].GetStringsTable_last_prefab_name = prefab_name
    TUNING["loramia.fn"].GetStringsTable_last_table = ret_table

    return ret_table
end


--------------------------------------------------------------------------------------------
TUNING.LORAMIA_FN = TUNING.LORAMIA_FN or {}
--------------------------------------------------------------------------------------------
--- 基础的文本
    function TUNING.LORAMIA_FN:GetStringsTable(prefab_name,index)
        local ret_table = TUNING["loramia.fn"].GetStringsTable(prefab_name) or {}
        if index then
            return ret_table[index] or nil
        else
            return ret_table
        end
    end
--------------------------------------------------------------------------------------------
--- 
--------------------------------------------------------------------------------------------