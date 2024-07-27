
if not TUNING.LORAMIA_DEBUGGING_MODE then
    return
end
local temp_DebugSpawn = rawget(_G,"DebugSpawn")
local function new_debug_fn(str,...)
    print("DebugSpawn: ",str)
    return temp_DebugSpawn(str,...)
end
rawset(_G,"D",new_debug_fn)
rawset(_G,"d",new_debug_fn)