require('lib/basics')
require('lib/game')

function lifestream(cmd)
    verbose('ipc', 'Executing lifestream command ' .. cmd)
    IPC.Lifestream.ExecuteCommand(cmd)
    wait_for(function () return IPC.Lifestream.IsBusy() end)
end

function deliveroo()
    verbose('ipc', 'Running deliveroo')
    yield('/deliveroo e')
    wait_for(function () return IPC.Deliveroo.IsTurnInRunning() end)
end

function run_duty(territory, loops, bare)
    loops = loops or 1
    bare = bare or true
    if not IPC.AutoDuty.ContentHasPath(territory) then return false end
    if not IPC.AutoDuty.IsStopped() then return false end
    IPC.AutoDuty.Run(territory, loops, bare)
    wait_for(function () IPC.AutoDuty.IsStopped() end)
    return true
end

function is_waiting_autoretainer(cid, only_subs)
    local data = IPC.AutoRetainer.GetOfflineCharacterData(cid)
    return data and data.Enabled and (data.SubsAwaitingProcessing or (not only_subs and data.AnyAwaitingProcessing))
end

function need_autoretainer(subs_only)
    subs_only = subs_only or false

    verbose('ipc', 'Checking for ' .. (subs_only and 'subs' or 'everything') .. ' on all characters')

    for cid in luanet.each(IPC.AutoRetainer.GetRegisteredCharacters()) do
        verbose('ipc', 'Checking cid ' .. cid);
        if is_waiting_autoretainer(cid, subs_only) then
            verbose('ipc', 'Cid ' .. cid .. ' needs autoretainer')
            return true
        end
    end

    verbose('ipc', 'No characters need autoretainer')
    return false
end

function process_autoretainer(subs_only, wait_duration)
    subs_only = subs_only or false
    wait_duration = wait_duration or 10

    verbose('ipc', 'Processing AutoRetainer')
    IPC.AutoRetainer.SetMultiModeEnabled(true)
    wait_for(function() return IPC.AutoRetainer.IsBusy() or need_autoretainer(subs_only) end, wait_duration)
    verbose('ipc', 'Finished processing AutoRetainer')
    IPC.AutoRetainer.SetMultiModeEnabled(false)
    wait(wait_duration)
end

function relog_autoretainer(character, max_attempts)
    if (is_player_available() and get_full_player_name() ~= character) or not is_player_available() then
        verbose('ipc', 'Relogging to ' .. character)
        local attempts = 0
        max_attempts = max_attempts or 5
        repeat
            verbose('ipc', 'Attempting to relog to ' .. character)
            IPC.AutoRetainer.SetMultiModeEnabled(true)
            wait()
            IPC.AutoRetainer.Relog(character)
            wait_for(function () return IPC.AutoRetainer.IsBusy() end)
            if get_full_player_name() == character then
                break
            end
            attempts = attempts + 1
        until attempts == max_attempts
        IPC.AutoRetainer.SetMultiModeEnabled(false)
    end
end

function enable_autohook()
    verbose('ipc', 'Enabling AutoHook')
    IPC.AutoHook.SetPluginState(true)
    verbose('ipc', 'AutoHook enabled')
end

function disable_autohook()
    verbose('ipc', 'Disabling AutoHook')
    IPC.AutoHook.SetPluginState(false)
    verbose('ipc', 'AutoHook disabled')
end

function set_autohook_preset(preset)
    verbose('ipc', 'Setting AutoHook preset to ' .. preset)
    IPC.AutoHook.SetPreset(preset)
    verbose('ipc', 'AutoHook preset set to ' .. preset)
end

function is_yesalready_enabled()
    return IPC.YesAlready.IsPluginEnabled()
end

function pause_yesalready(duration)
    IPC.YesAlready.PausePlugin(duration)
end

function enable_yesalready()
    IPC.YesAlready.SetPluginEnabled(true)
end

function disable_yesalready()
    IPC.YesAlready.SetPluginEnabled(false)
end

function pause_yesalready_feature(name, duration)
    IPC.YesAlready.PauseBother(name, duration)
end

function is_yesalready_feature_enabled(name)
    return IPC.YesAlready.IsBotherEnabled(name)
end

function enable_yesalready_feature(name)
    IPC.YesAlready.SetBotherEnabled(name, true)
end

function disable_yesalready_feature(name)
    IPC.YesAlready.SetBotherEnabled(name, false)
end
