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
---  通用物品给予
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