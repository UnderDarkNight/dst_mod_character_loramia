--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[

    跨存档数据储存


]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---
    local function IsClientSide()
        if TheNet:IsDedicated() then
            return false
        end
        return true
    end

    --- 基础的文件读写函数
    local fileName = "loramia_data.text" -- 文件名缓存

    -- 文件句柄缓存
    local fileHandle = nil

    local function OpenFile(mode)
        if fileHandle == nil then
            fileHandle = io.open(fileName, mode)
        end
        return fileHandle
    end

    local function CloseFile()
        if fileHandle ~= nil then
            fileHandle:close()
            fileHandle = nil
        end
    end

    local function Read_All_Json_Data()
        local file = OpenFile("r")
        if file then
            local text = file:read('*a') -- 读取全部内容而不是单行
            CloseFile()
            return text and json.decode(text) or {}
        else
            print("Failed to open file for reading.")
            return {}
        end
    end

    local function Write_All_Json_Data(json_data)
        if IsClientSide() then
            local file = OpenFile("w")
            if file then
                local w_data = json.encode(json_data)
                file:write(w_data)
                CloseFile()
            else
                print("Failed to open file for writing.")
            end
        end
    end

    local function Get_Cross_Archived_Data_By_userid(userid)
        local crash_flag , all_data_table = pcall(Read_All_Json_Data)
        if crash_flag then
            local temp_json_data = all_data_table
            return temp_json_data[userid] or {}
        else
            print("error : Read_All_Json_Data fn crash")
            return {}
        end
    end

    local function Set_Cross_Archived_Data_By_userid(userid,_table)
        if not IsClientSide() then  --- 只在客户端这一侧执行数据写入
            return
        end

        local temp_json_data = Read_All_Json_Data() or {}
        -- temp_json_data[userid] = _table
        temp_json_data[userid] = temp_json_data[userid] or {}
        for index, value in pairs(_table) do
            temp_json_data[userid][index] = value
        end
        temp_json_data = deepcopy(temp_json_data)
        -- Write_All_Json_Data(temp_json_data)
        pcall(Write_All_Json_Data,temp_json_data)
    end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

TUNING.LORAMIA_FN = TUNING.LORAMIA_FN or {}

function TUNING.LORAMIA_FN:Get_Cross_Archived_Data_By_userid(userid)
    return Get_Cross_Archived_Data_By_userid(userid) or {}
end
function TUNING.LORAMIA_FN:Set_Cross_Archived_Data_By_userid(userid,_table) 
    Set_Cross_Archived_Data_By_userid(userid,_table) 
end
function TUNING.LORAMIA_FN:Set_ThePlayer_Cross_Archived_Data(index,value)
    if ThePlayer and ThePlayer.userid then
        local all_data = TUNING.LORAMIA_FN:Get_Cross_Archived_Data_By_userid(ThePlayer.userid) or {}
        all_data[index] = value
        TUNING.LORAMIA_FN:Set_Cross_Archived_Data_By_userid(ThePlayer.userid,all_data)
    end
end
function TUNING.LORAMIA_FN:Get_ThePlayer_Cross_Archived_Data(index)
    if ThePlayer and ThePlayer.userid then
        local all_data = TUNING.LORAMIA_FN:Get_Cross_Archived_Data_By_userid(ThePlayer.userid)
        return all_data[index] or {}
    end
    return {}
end
