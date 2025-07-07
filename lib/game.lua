require('lib/basics')

function command(cmd)
    verbose('game', 'Executing command /' .. cmd)
    yield('/' .. cmd)
end

function action(id, type)
    Actions.ExecuteAction(id, type)
end

function general_action(id)
    Actions.ExecuteGeneralAction(id)
end

-- TODO varargs (arg variable)
function callback(cmd)
    command('callback ' .. cmd)
end

function click(cmd)
    command('click ' .. cmd)
end

function target(target)
    verbose('game', 'Targeting ' .. target)
    repeat
        local entity = Entity.GetEntityByName(target)
        if entity ~= nil then
            entity:SetAsTarget()
        end
        wait()
    until Entity.Target.Name == target
end

function interact()
    Entity.Target:Interact()
end

function is_player_available()
    return Entity.Player ~= nil and Entity.Player.Available == true
end

function is_player_occupied()
    ConditionFlag = luanet.import_type('Dalamud.Game.ClientState.Conditions.ConditionFlag')
    return Svc.Condition[ConditionFlag.Occupied]
        or Svc.Condition[ConditionFlag.Occupied30]
        or Svc.Condition[ConditionFlag.Occupied33]
        or Svc.Condition[ConditionFlag.Occupied38]
        or Svc.Condition[ConditionFlag.Occupied39]
        or Svc.Condition[ConditionFlag.OccupiedInCutSceneEvent]
        or Svc.Condition[ConditionFlag.OccupiedInEvent]
        or Svc.Condition[ConditionFlag.OccupiedInQuestEvent]
        or Svc.Condition[ConditionFlag.OccupiedSummoningBell]
        or Svc.Condition[ConditionFlag.WatchingCutscene]
        or Svc.Condition[ConditionFlag.WatchingCutscene78]
        or Svc.Condition[ConditionFlag.BetweenAreas]
        or Svc.Condition[ConditionFlag.BetweenAreas51]
        or Svc.Condition[ConditionFlag.InThatPosition]
        or Svc.Condition[ConditionFlag.Crafting]
        or Svc.Condition[ConditionFlag.ExecutingCraftingAction]
        or Svc.Condition[ConditionFlag.PreparingToCraft]
        or Svc.Condition[ConditionFlag.InThatPosition]
        or Svc.Condition[ConditionFlag.Unconscious]
        or Svc.Condition[ConditionFlag.MeldingMateria]
        or Svc.Condition[ConditionFlag.Gathering]
        or Svc.Condition[ConditionFlag.OperatingSiegeMachine]
        or Svc.Condition[ConditionFlag.CarryingItem]
        or Svc.Condition[ConditionFlag.CarryingObject]
        or Svc.Condition[ConditionFlag.BeingMoved]
        or Svc.Condition[ConditionFlag.Mounted2]
        or Svc.Condition[ConditionFlag.Mounting]
        or Svc.Condition[ConditionFlag.Mounting71]
        or Svc.Condition[ConditionFlag.ParticipatingInCustomMatch]
        or Svc.Condition[ConditionFlag.PlayingLordOfVerminion]
        or Svc.Condition[ConditionFlag.ChocoboRacing]
        or Svc.Condition[ConditionFlag.PlayingMiniGame]
        or Svc.Condition[ConditionFlag.Performing]
        or Svc.Condition[ConditionFlag.PreparingToCraft]
        or Svc.Condition[ConditionFlag.Fishing]
        or Svc.Condition[ConditionFlag.Transformed]
        or Svc.Condition[ConditionFlag.UsingHousingFunctions]
        or Svc.ClientState.LocalPlayer.IsTargetable == false
end

function get_full_player_name()
    if Entity.Player == nil then
        return ''
    end
    return Entity.Player.Name .. '@' .. Excel.GetRow("World", Entity.Player.HomeWorld).Name
end

function is_addon_ready(addon)
    return Addons.GetAddon(addon).Ready
end

function wait_for_addon(addon)
    verbose('game', 'Waiting for addon ' .. addon)
    wait_for(function() return not is_addon_ready(addon) end)
end

function wait_for_addon_dismissed(addon)
    verbose('game', 'Waiting for addon ' .. addon .. ' to be dismissed')
    wait_for(function() return is_addon_ready(addon) end)
end

function wait_for_condition(condition, state, duration)
    state = state or true
    verbose('game', 'Waiting for condition ' .. tostring(condition) .. ' to be ' .. tostring(state))
    wait_for(function() return Svc.Condition[condition] == state end, duration)
    verbose('game', tostring(condition) .. ' should now be ' .. tostring(state) .. ' (is actually ' .. tostring(Svc.Condition[condition]) .. ')')
end

function wait_for_ready()
    verbose('game', 'Waiting for player ready')
    wait_for(
        function()
            if not is_player_available() then return true end
            if is_player_occupied() then return true end
            return false
        end
    )
    verbose('game', 'Player is now ready')
end

function on_title_screen()
    return is_addon_ready('_TitleLogo') or is_addon_ready('_CharaSelectTitle')
end

function is_talk_ready()
    return is_addon_ready('Talk')
end

function wait_for_talk()
    verbose('game', 'Waiting for talk dialog to be ready')
    wait_for(is_talk_ready)
end

function dismiss_talk()
    verbose('game', 'Dismissing talk dialog')
    repeat
        if is_talk_ready() then
            click('Talk Click')
        end
        wait()
    until not is_talk_ready()
    wait()
end

function wait_for_duty_start()
    verbose('game', 'Waiting for duty start')
    -- negate DutyState.IsDutyStarted because we wait for it to be true to break out of the wait
    wait_for(function () return not Svc.DutyState.IsDutyStarted end)
end

function select_menu(entry)
    wait_for_addon('SelectString')
    -- let the SelectString fully populate
    wait()
    verbose('game', 'Selecting entry ' .. entry .. ' on menu')
    click('SelectString Entries[' .. entry .. '].Select')
    wait_for_addon_dismissed('SelectString')
end

function select_yesno(entry)
    local entries = {
        [1] = 'Yes',
        [2] = 'No',
        [3] = 'Third'
    }

    wait_for_addon('SelectYesno')
    wait()
    verbose('game', 'Selecting ' .. entries[entry] .. ' from SelectYesno')
    click('SelectYesno ' .. entries[entry])
    wait_for_addon_dismissed('SelectYesno')
end
