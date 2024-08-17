--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[



]]--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 通用CD计时器
    local cd_timer = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- hook
    local function Hook_Player_SoundEmitter(inst)

        if type(inst.SoundEmitter) == "userdata" then            ----- 只能转变一次，重复的操作 会导致  __index 函数错误
            --------------------------------------------------------------------------------------------------------------------------------
                inst.__SoundEmitter_userdata_loramia = inst.SoundEmitter      ----- 转移复制原有 userdata
                inst.SoundEmitter = {inst = inst , name = "SoundEmitter"}   ----- name 是必须的，用于 从 _G  里 得到目标, 玩家 inst 也是从这里进入
                ------ 逻辑上复现棱镜模组的代码：

                setmetatable( inst.SoundEmitter , {
                    __index = function(_table,fn_name)
                                if _table and _table.inst and _table.name then

                                        if _G[_table.name][fn_name] then    ---- 从_G全局里得到原函数？？这句并不好理解。   ---- lua 会往_G 里自动挂载所有要运行的 userdata ？？
                                            local _table_name = _table.name
                                            local fn = function(temp_table,...)
                                                return _G[_table_name][fn_name](temp_table.inst.__SoundEmitter_userdata_loramia,...)
                                            end
                                            rawset(_table,fn_name,fn)
                                            return fn
                                        end

                                end
                    end,
                })
            --------------------------------------------------------------------------------------------------------------------------------
        else
            print("warning : ThePlayer.SoundEmitter is already a table ")    
        end

        ------- 成功把  inst.SoundEmitter 从  userdata 变成 table
        --------------------- 挂载函数
        if inst.SoundEmitter.inst ~= inst then
            inst.SoundEmitter.inst = inst
        end
        ---------------------
        -- theSoundEmitter_fn_Upgrade(inst.SoundEmitter)
        print("loramia hook player SoundEmitter finish")
    end
    local sound_addr_and_fns = {
        ["nil"] = function(inst,origin_addr)
            
        end,
        -------------------------------------------------------------------------------------------
        --- 激光炮的预发射
            ["lw_homura/rpg/pre_3d"] = function(inst,origin_addr)
                inst.SoundEmitter:KillSound("laser_cannon_pre_attack")
                inst.SoundEmitter:KillSound("loramia_onhitother")
                inst.SoundEmitter:PlaySound("loramia_sound/loramia_sound/laser_cannon_pre_attack","laser_cannon_pre_attack")
                if cd_timer["laser_cannon_pre_attack"] then
                    cd_timer["laser_cannon_pre_attack"]:Cancel()
                end
                cd_timer["laser_cannon_pre_attack"] = inst:DoTaskInTime(3,function()
                    cd_timer["laser_cannon_pre_attack"] = nil
                end)
            end,
        -------------------------------------------------------------------------------------------
        --- 说话声音
            ["dontstarve/characters/wendy/talk_LP"] = {
                "loramia_sound/loramia_sound/talk_1",
                "loramia_sound/loramia_sound/talk_2",
            },
        -------------------------------------------------------------------------------------------
        --- 被攻击声音
            ["dontstarve/characters/wendy/hurt"] = function()
                return "loramia_sound/loramia_sound/hit_"..math.random(1,5)
            end,
        -------------------------------------------------------------------------------------------
        --- 死亡声音
            ["dontstarve/characters/wendy/death_voice"] = {
                "loramia_sound/loramia_sound/death_1",
                "loramia_sound/loramia_sound/death_2",
            },
        -------------------------------------------------------------------------------------------
        --- 复活声音
            ["dontstarve/ghost/player_revive"] = "loramia_sound/loramia_sound/respawnfromghost",
        -------------------------------------------------------------------------------------------
        --- 饥饿声音
            ["dontstarve/wilson/hungry"] = function(inst)
                if cd_timer["hunger"] == nil then
                    cd_timer["hunger"] = inst:DoTaskInTime(15,function()
                        cd_timer["hunger"] = nil
                    end)
                    inst.SoundEmitter:PlaySound("loramia_sound/loramia_sound/low_hunger")
                end
            end,
        -------------------------------------------------------------------------------------------
    }
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 把  inst.SoundEmitter 从  userdata 变成 table并且HOOK进去拦截修改声音
    local function Origin_SoundEmitter_Trans_2_table(inst)
        if type(inst.SoundEmitter) ~= "table" then
            Hook_Player_SoundEmitter(inst)
        end
        if type(inst.SoundEmitter) ~= "table" then
            print("error : sound emitter is not a table")
            return
        end
        local old_PlaySound = inst.SoundEmitter.PlaySound
        inst.SoundEmitter.PlaySound = function(self,sound_addr,...)
            -- print("+++ sound ",sound_addr)
            local fn_or_addr = sound_addr_and_fns[sound_addr]
            if type(fn_or_addr) == "function" then
                sound_addr = fn_or_addr(inst,sound_addr,...) or sound_addr
            elseif type(fn_or_addr) == "table" then
                sound_addr = fn_or_addr[math.random(#fn_or_addr)] or sound_addr
            elseif type(fn_or_addr) == "string" then
                sound_addr = fn_or_addr
            end
            if sound_addr == "nil" then
                return
            end
            old_PlaySound(self,sound_addr,...)
        end


    end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- EVENT AND SOUND
    local sg_state_fns = { -- 根据sg修改声音
        ----------------------------------------------------
        --- idle 动作，低Sanity的时候触发
            ["idle"] = function(inst)
                inst:DoTaskInTime(0,function()
                        if inst.AnimState:IsCurrentAnimation("idle_sanity_pre") and cd_timer["low_sanity"] == nil then
                            inst.SoundEmitter:PlaySound("loramia_sound/loramia_sound/low_sanity")
                            cd_timer["low_sanity"] = inst:DoTaskInTime(15,function()
                                cd_timer["low_sanity"] = nil
                            end)
                        end
                end)
            end,
        ----------------------------------------------------
    }
    local function sound_event_setup(inst)
        ---------------------------------------------------------------
        ---- sg 进出 触发
            inst:ListenForEvent("newstate",function(inst,_table)
                local current_state = _table and _table.statename
                if current_state and sg_state_fns[current_state] then
                    sg_state_fns[current_state](inst)
                end
            end)
        ---------------------------------------------------------------
        --- 击杀目标
            inst:ListenForEvent("killed",function()
                if cd_timer["killed"] == nil and cd_timer["laser_cannon_pre_attack"] == nil then
                    inst.SoundEmitter:KillSound("loramia_onhitother")
                    inst.SoundEmitter:PlaySound("loramia_sound/loramia_sound/player_kill_others","loramia_onhitother")
                    cd_timer["killed"] = inst:DoTaskInTime(15,function()
                        cd_timer["killed"] = nil
                    end)
                end
            end)
        ---------------------------------------------------------------
        --- 攻击目标
            local onhitother_num = 1
            inst:ListenForEvent("onhitother",function()
                if cd_timer["onhitother"] == nil and cd_timer["laser_cannon_pre_attack"] == nil then
                    onhitother_num = onhitother_num + 1
                    if onhitother_num > 2 then
                        onhitother_num = 1
                    end
                    inst.SoundEmitter:PlaySound("loramia_sound/loramia_sound/for_attack_"..onhitother_num,"loramia_onhitother")
                    cd_timer["onhitother"] = inst:DoTaskInTime(15,function()
                        cd_timer["onhitother"] = nil
                    end)
                end
            end)
        ---------------------------------------------------------------
        --- 犀牛召回
            inst:ListenForEvent("loramia_event.recall_rhino_by_hotkey",function()
                if cd_timer["rhion_recall"] == nil then
                    inst.SoundEmitter:PlaySound("loramia_sound/loramia_sound/recall_iron_rhino")
                    cd_timer["rhion_recall"] = inst:DoTaskInTime(30,function()
                        cd_timer["rhion_recall"] = nil
                    end)
                end
            end)
        ---------------------------------------------------------------
        --- 充能值:每+10 通知一次，满的时候也通知一次。
            inst:ListenForEvent("loramia_com_recharge_update",function(inst,_table)
                local old = _table.old
                local new = _table.new
                local max = _table.max
                if old == new or old > new then
                    return
                end
                --- CD
                if cd_timer["loramia_com_recharge_update"] then
                    return
                end
                cd_timer["loramia_com_recharge_update"] = inst:DoTaskInTime(30,function()
                    cd_timer["loramia_com_recharge_update"] = nil
                end)
                --- 10的倍数
                if new % 10 == 0 and new ~= max then
                    inst.SoundEmitter:PlaySound("loramia_sound/loramia_sound/recharge_value_delta_10","loramia_com_recharge_update")
                elseif new == max then
                    inst.SoundEmitter:PlaySound("loramia_sound/loramia_sound/recharge_value_full","loramia_com_recharge_update")
                end

            end)
        ---------------------------------------------------------------
        --- 宇宙之翼
            inst:ListenForEvent("loramia_event.wings_of_universe_onequip",function()
                if cd_timer["wings_of_universe_onequip"] == nil then
                    inst.SoundEmitter:PlaySound("loramia_sound/loramia_sound/wings_of_universe_onequip")
                    cd_timer["wings_of_universe_onequip"] = inst:DoTaskInTime(30,function()
                        cd_timer["wings_of_universe_onequip"] = nil
                    end)
                end
            end)
        ---------------------------------------------------------------

    end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return function(inst)
    if not TUNING["loramia.Config"].LORAMIA_CUSTOM_SOUNDS then
        return
    end
    if not TheWorld.ismastersim then
        return
    end
    inst:DoTaskInTime(0,Origin_SoundEmitter_Trans_2_table)
    -- inst:DoTaskInTime(0,sound_event_setup)
    sound_event_setup(inst)
end