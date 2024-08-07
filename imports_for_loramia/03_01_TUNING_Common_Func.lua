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
--- 通用物品给予
    function TUNING.LORAMIA_FN:GiveItemByName(target, name, num, item_fn)
        -- 参数检查
        if type(name) ~= "string" or type(num) ~= "number" or num <= 0 or not PrefabExists(name) then
            return
        end
    
        -- 查找目标身上的容器组件（库存或通用容器）
        local container = target.components.inventory or target.components.container
        if not container then
            return
        end
    
        -- 如果只需要一个物品
        if num == 1 then
            local item = SpawnPrefab(name)
            if item_fn and type(item_fn) == "function" then
                item_fn(item)
            end
            container:GiveItem(item)
        else
            -- 如果需要多个物品
            local stackableItem = SpawnPrefab(name)
            if not stackableItem then
                return
            end
    
            local stackComponent = stackableItem.components.stackable
            if not stackComponent then
                -- 非可堆叠物品
                for i = 1, num do
                    local item = SpawnPrefab(name)
                    if item_fn and type(item_fn) == "function" then
                        item_fn(item)
                    end
                    container:GiveItem(item or SpawnPrefab("log"))
                end
            else
                -- 可堆叠物品
                local maxStackSize = stackComponent.maxsize
                local fullStacks = math.floor(num / maxStackSize)  -- 完整堆叠的数量
                local remainder = num % maxStackSize                 -- 剩余的数量
    
                if fullStacks > 0 then
                    -- 创建完整的堆叠物品
                    for i = 1, fullStacks do
                        local item = SpawnPrefab(name)
                        item.components.stackable.stacksize = maxStackSize
                        if item_fn and type(item_fn) == "function" then
                            item_fn(item)
                        end
                        container:GiveItem(item)
                    end
                end
    
                -- 创建剩余部分的堆叠物品
                if remainder > 0 then
                    local item = SpawnPrefab(name)
                    item.components.stackable.stacksize = remainder
                    if item_fn and type(item_fn) == "function" then
                        item_fn(item)
                    end
                    container:GiveItem(item)
                end
            end
    
            -- 清理临时创建的物品
            stackableItem:Remove()
        end
    end
--------------------------------------------------------------------------------------------
--- 获取一圈坐标
    function TUNING.LORAMIA_FN:GetSurroundPoints(CMD_TABLE)
        -- local CMD_TABLE = {
        --     target = inst or Vector3(),
        --     range = 8,
        --     num = 8
        -- }
        if CMD_TABLE == nil then
            return
        end
        if CMD_TABLE.pt then
            CMD_TABLE.target = CMD_TABLE.pt
        end
        local theMid = nil
        if CMD_TABLE.target == nil then
            theMid = Vector3( self.inst.Transform:GetWorldPosition() )
        elseif CMD_TABLE.target.x then
            theMid = CMD_TABLE.target
        elseif CMD_TABLE.target.prefab then
            theMid = Vector3( CMD_TABLE.target.Transform:GetWorldPosition() )
        else
            return
        end
        -- --------------------------------------------------------------------------------------------------------------------
        -- -- 8 points
        -- local retPoints = {}
        -- for i = 1, 8, 1 do
        --     local tempDeg = (PI/4)*(i-1)
        --     local tempPoint = theMidPoint + Vector3( Range*math.cos(tempDeg) ,  0  ,  Range*math.sin(tempDeg)    )
        --     table.insert(retPoints,tempPoint)
        -- end
        -- --------------------------------------------------------------------------------------------------------------------
        local num = CMD_TABLE.num or 8
        local range = CMD_TABLE.range or 8
        local retPoints = {}
        for i = 1, num, 1 do
            local tempDeg = (2*PI/num)*(i-1)
            local tempPoint = theMid + Vector3( range*math.cos(tempDeg) ,  0  ,  range*math.sin(tempDeg)    )
            table.insert(retPoints,tempPoint)
        end

        return retPoints


    end
--------------------------------------------------------------------------------------------
-- 热键
    local keys_by_index  = {
        KEY_A = 97,
        KEY_B = 98,
        KEY_C = 99,
        KEY_D = 100,
        KEY_E = 101,
        KEY_F = 102,
        KEY_G = 103,
        KEY_H = 104,
        KEY_I = 105,
        KEY_J = 106,
        KEY_K = 107,
        KEY_L = 108,
        KEY_M = 109,
        KEY_N = 110,
        KEY_O = 111,
        KEY_P = 112,
        KEY_Q = 113,
        KEY_R = 114,
        KEY_S = 115,
        KEY_T = 116,
        KEY_U = 117,
        KEY_V = 118,
        KEY_W = 119,
        KEY_X = 120,
        KEY_Y = 121,
        KEY_Z = 122,
        KEY_F1 = 282,
        KEY_F2 = 283,
        KEY_F3 = 284,
        KEY_F4 = 285,
        KEY_F5 = 286,
        KEY_F6 = 287,
        KEY_F7 = 288,
        KEY_F8 = 289,
        KEY_F9 = 290,
        KEY_F10 = 291,
        KEY_F11 = 292,
        KEY_F12 = 293,
    }
    local function check_is_text_inputting()    
        -- 代码来自  TheFrontEnd:OnTextInput
        local screen = TheFrontEnd and TheFrontEnd:GetActiveScreen()
        if screen ~= nil then
            if TheFrontEnd.forceProcessText and TheFrontEnd.textProcessorWidget ~= nil then
                return true
            else
                return false
            end
        end
        return false
    end
    function TUNING.LORAMIA_FN:IsKeyPressed(str_index,key)
        if check_is_text_inputting() then
            return false
        end
        if key == keys_by_index[str_index] then
            return true
        end
        return false
    end
--------------------------------------------------------------------------------------------