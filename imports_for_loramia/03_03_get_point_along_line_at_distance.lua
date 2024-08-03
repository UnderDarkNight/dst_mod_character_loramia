



-- 归一化向量的辅助函数
local function _Vector3Normalized(v)
    -- 计算向量的长度
    local length = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

    -- 如果长度为0，则直接返回原向量
    if length == 0 then
        return v
    end

    -- 归一化向量
    return {
        x = v.x / length,
        y = v.y / length,
        z = v.z / length
    }
end

-- 计算沿着从 pt1 到 pt2 方向上距离 pt1 为 distance 的点
local function _GetPointAtDistance(pt1, pt2, distance)
    -- 计算方向向量
    local direction = {
        x = pt2.x - pt1.x,
        y = pt2.y - pt1.y,
        z = pt2.z - pt1.z
    }

    -- 归一化方向向量
    local normalized_direction = _Vector3Normalized(direction)

    -- 将方向向量乘以所需的固定距离
    local offset = {
        x = normalized_direction.x * distance,
        y = normalized_direction.y * distance,
        z = normalized_direction.z * distance
    }

    -- 将偏移量加到第一个点的位置上
    local ret_pt = {
        x = pt1.x + offset.x,
        y = pt1.y + offset.y,
        z = pt1.z + offset.z
    }

    return ret_pt
end
local function GetPointAtDistance(pt1,pt2,distance)
    local temp = _GetPointAtDistance(pt1,pt2,distance)
    return Vector3(temp.x,temp.y,temp.z)
end

TUNING.LORAMIA_FN = TUNING.LORAMIA_FN or {}

function TUNING.LORAMIA_FN:GetPointAlongLineAtDistance(pt1, pt2, distance)
    return GetPointAtDistance(pt1, pt2, distance)
end