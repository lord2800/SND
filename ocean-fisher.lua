--[[
Requirements:
Import these lifestream commands:

* {"ExportedName":"Ocean Fishing","Alias":"oceanfish","Enabled":true,"Commands":[{"Kind":0,"Point":{"X":0.0,"Y":0.0,"Z":0.0},"Aetheryte":8,"World":0,"CenterPoint":{"X":0.0,"Y":0.0},"CircularExitPoint":{"X":0.0,"Y":0.0,"Z":0.0},"Clamp":null,"Precision":20.0,"Tolerance":1,"WalkToExit":true,"SkipTeleport":15.0,"DataID":0,"UseTA":false},{"Kind":4,"Point":{"X":0.0,"Y":0.0,"Z":0.0},"Aetheryte":43,"World":0,"CenterPoint":{"X":0.0,"Y":0.0},"CircularExitPoint":{"X":0.0,"Y":0.0,"Z":0.0},"Clamp":null,"Precision":20.0,"Tolerance":1,"WalkToExit":true,"SkipTeleport":15.0,"DataID":0,"UseTA":false},{"Kind":2,"Point":{"X":-409.5739,"Y":3.9999278,"Z":74.009766},"Aetheryte":0,"World":0,"CenterPoint":{"X":0.0,"Y":0.0},"CircularExitPoint":{"X":0.0,"Y":0.0,"Z":0.0},"Clamp":null,"Precision":20.0,"Tolerance":1,"WalkToExit":true,"SkipTeleport":15.0,"DataID":0,"UseTA":false}],"GUID":"00000000-0000-0000-0000-000000000000"}
* {"ExportedName":"Ocean Fishing Deck Edge","Alias":"boatdeck","Enabled":true,"Commands":[{"Kind":1,"Point":{"X":-7.5407605,"Y":6.749975,"Z":-6.032779},"Aetheryte":0,"World":0,"CenterPoint":{"X":0.0,"Y":0.0},"CircularExitPoint":{"X":0.0,"Y":0.0,"Z":0.0},"Clamp":null,"Precision":20.0,"Tolerance":1,"WalkToExit":true,"SkipTeleport":15.0,"DataID":0,"UseTA":false}],"GUID":"00000000-0000-0000-0000-000000000000"}

Required plugins:

* Lifestream
* AutoHook
* YesAlready
* AutoRetainer (for subs)

Required settings:
YesAlready -> Bothers -> Duties -> ContentsFinderConfirm checked
(for autoretainer being enabled)
AutoRetainer -> Multi Mode -> Common Settings -> Wait on login screen
AutoRetainer -> Multi Mode -> Common Settings -> Disable Multi Mode on Manual Login
AutoRetainer -> Multi Mode -> Common Settings -> Teleportation -> Enabled (and configure it how you want)
AutoHook -> configure preset(s) for ocean fishing, the community wiki has good enough presets so import those
Probably more, too lazy to figure out what

]]--

-- settings
-- what route to take (0 or 1)
local route_number = 0
-- what gearset number/name to use as your fisher gearset
local fisher_gearset = '33'
-- how much durability must remain before repairing, this doesn't work yet
local repair_amount = 25
-- this is how long to wait between actions by default, can be overridden by specific waits in code, adjust this according to your ping
local wait_duration = 0.5
-- enable autoretainer integration
local enable_autoretainer = true
-- only check sub timers, or check all timers, for autoretainer
local subs_only = true
-- only ocean fish on the specified character, if nil then use the current character when the script is started
local ocean_fisher = nil
-- home destination to wait at after fishing
local home_destination = 'fc'

-- data
local baits = {
    ragworm = { id = 29714, name = "Ragworm" },
    krill = { id = 29715, name = "Krill" },
    plumpworm = { id = 29716, name = "Plump Worm" },
}

local ocean_zones = {
  [1] = {id = 237, name = "Galadion Bay",      normal_bait = baits.krill,     daytime = baits.ragworm,   sunset = baits.plumpworm, nighttime = baits.krill},
  [2] = {id = 239, name = "Southern Merlthor", normal_bait = baits.krill,     daytime = baits.krill,     sunset = baits.ragworm,   nighttime = baits.plumpworm},
  [3] = {id = 243, name = "Northern Merlthor", normal_bait = baits.ragworm,   daytime = baits.plumpworm, sunset = baits.ragworm,   nighttime = baits.krill},
  [4] = {id = 241, name = "Rhotano Sea",       normal_bait = baits.plumpworm, daytime = baits.plumpworm, sunset = baits.ragworm,   nighttime = baits.krill},
  [5] = {id = 246, name = "The Ciedalaes",     normal_bait = baits.ragworm,   daytime = baits.krill,     sunset = baits.plumpworm, nighttime = baits.krill},
  [6] = {id = 248, name = "Bloodbrine Sea",    normal_bait = baits.krill,     daytime = baits.ragworm,   sunset = baits.plumpworm, nighttime = baits.krill},
  [7] = {id = 250, name = "Rothlyt Sound",     normal_bait = baits.plumpworm, daytime = baits.krill,     sunset = baits.krill,     nighttime = baits.krill},
  [8] = {id = 286, name = "Sirensong Sea",     normal_bait = baits.plumpworm, daytime = baits.krill,     sunset = baits.krill,     nighttime = baits.krill},
  [9] = {id = 288, name = "Kugane Coast",      normal_bait = baits.ragworm,   daytime = baits.krill,     sunset = baits.ragworm,   nighttime = baits.plumpworm},
  [10] = {id = 290, name = "Ruby Sea",         normal_bait = baits.krill,     daytime = baits.ragworm,   sunset = baits.plumpworm, nighttime = baits.krill},
  [11] = {id = 292, name = "Lower One River",  normal_bait = baits.krill,     daytime = baits.ragworm,   sunset = baits.krill,     nighttime = baits.krill},
}

local routes = {
  [1] = {[1] = 2, [2] = 1, [3] = 3},
  [2] = {[1] = 2, [2] = 1, [3] = 3},
  [3] = {[1] = 2, [2] = 1, [3] = 3},
  [4] = {[1] = 1, [2] = 2, [3] = 4},
  [5] = {[1] = 1, [2] = 2, [3] = 4},
  [6] = {[1] = 1, [2] = 2, [3] = 4},
  [7] = {[1] = 5, [2] = 3, [3] = 6},
  [8] = {[1] = 5, [2] = 3, [3] = 6},
  [9] = {[1] = 5, [2] = 3, [3] = 6},
  [10] = {[1] = 5, [2] = 4, [3] = 7},
  [11] = {[1] = 5, [2] = 4, [3] = 7},
  [12] = {[1] = 5, [2] = 4, [3] = 7},
  [13] = {[1] = 8, [2] = 9, [3] = 11},
  [14] = {[1] = 8, [2] = 9, [3] = 11},
  [15] = {[1] = 8, [2] = 9, [3] = 11},
  [16] = {[1] = 8, [2] = 9, [3] = 10},
  [17] = {[1] = 8, [2] = 9, [3] = 10},
  [18] = {[1] = 8, [2] = 9, [3] = 10},
}

local fisher_job = 18
-- TODO interact with ids instead (how?)
-- local fishing_npc = 1005421
local fishing_npc = 'Dryskthota'
local fishing_condition = 43
local dutybound_condition = 34
local watching_cutscene_condition = 35

-- functions

local function verbose(msg)
    LogVerbose('[OceanFisher] ' .. msg)
end

local function wait(duration)
    yield('/wait ' .. (duration or wait_duration))
end

local function wait_for_addon(addon)
    verbose('Waiting for addon ' .. addon)
    while not IsAddonReady(addon) do
        wait()
    end
end

local function wait_for_condition(condition, state, duration)
    verbose('Waiting for condition ' .. tostring(condition) .. ' to be ' .. tostring(state))
    repeat
        wait(duration)
    until GetCharacterCondition(condition) == state
end

local function dismiss_talk()
    repeat
        if (IsAddonReady("Talk") and IsAddonVisible("Talk")) then
            yield("/click Talk Click")
        end
        wait(0.1)
    until not (IsAddonReady("Talk") or IsAddonVisible("Talk"))
    wait()
end

local function wait_for_ready()
    verbose('Waiting for player ready')
    while not IsPlayerAvailable() do
        wait()
    end
    while IsPlayerOccupied() do
        wait()
    end
end

local function lifestream(command)
    verbose('Executing lifestream command ' .. command)
    LifestreamExecuteCommand(command)
    while LifestreamIsBusy() do
        wait()
    end
end

local function need_autoretainer(only_subs)
    if only_subs then
        return ARSubsWaitingToBeProcessed(true)
    else
        return ARAnyWaitingToBeProcessed(true)
    end
end

local function process_autoretainer(only_subs)
    verbose('Processing AutoRetainer')
    ARSetMultiModeEnabled(true)
    repeat
        verbose('Waiting for autoretainer...')
        wait(10)
    until not need_autoretainer(only_subs)
    verbose('Finished processing AutoRetainer')
    ARSetMultiModeEnabled(false)
    wait(10)
end

local function repair_all()
    verbose('Repairing')
    while not IsAddonReady("Repair") do
        yield("/generalaction repair")
        wait()
    end
    yield("/callback Repair true 0 1")
    while GetCharacterCondition(39) do
        wait()
    end
    wait()
    yield("/callback Repair true -1")
end

local function has_results()
    return IsAddonReady('IKDResult')
end

local function wait_for_results_dialog()
    while not has_results() do
        wait()
    end
end

local function close_results()
    wait_for_results_dialog()
    verbose('Closing results dialog')
    wait()
    yield('/callback IKDResult true 0')
    wait_for_ready()
end

local function get_correct_bait()
    -- lua indexes at 1, so add 1
    local current_route = routes[GetCurrentOceanFishingRoute() + 1]
    local current_zone = current_route[GetCurrentOceanFishingZone() + 1]
    if not OceanFishingIsSpectralActive() then
        return ocean_zones[current_zone].normal_bait
    end
    local fish_tod = GetCurrentOceanFishingTimeOfDay()
    if fish_tod == 1 then return ocean_zones[current_zone].daytime end
    if fish_tod == 2 then return ocean_zones[current_zone].sunset end
    if fish_tod == 3 then return ocean_zones[current_zone].nighttime end
    return "Versatile Lure"
end

local function is_on_boat()
    return IsInZone(900) or IsInZone(1163)
end

local function move_to_deck()
    lifestream('boatdeck')
end

local function wait_for_start()
    verbose('Waiting for duty start')
    while not DutyState.IsDutyStarted do
        wait()
    end
end

local function wait_until_not_fishing()
    wait_for_condition(fishing_condition, false)
end

local function ensure_correct_bait()
    local correct_bait = get_correct_bait()
    local current_bait = GetCurrentBait()

    while current_bait ~= correct_bait.id and GetCurrentOceanFishingZoneTimeLeft() > 35 do
        verbose('Current bait is ' .. current_bait .. ', correct bait is ' .. correct_bait.id .. ' (' .. correct_bait.name .. ')')
        wait_until_not_fishing()
        SetAutoHookState(false)
        verbose('Attempting to set bait to ' .. correct_bait.name)
        yield('/bait ' .. correct_bait.name)
        wait()
        current_bait = GetCurrentBait()
        verbose('Bait is now set to ' .. current_bait)
    end
    SetAutoHookState(true)
end

local function is_ocean_fishing_time()
    local now = os.date('!*t')
    -- using 13 minutes after the hour because 15 after is the cutoff time
    -- 13 minutes gives time for teleport/movement
    return now.hour % 2 == 0 and now.min < 13
end

local function queue_for_fishing(route)
    verbose('Queueing for ocean fishing on route ' .. route)
    -- TODO clean this all up with proper waiting wrapper functions
    yield('/target ' .. fishing_npc)
    wait()
    yield('/interact')
    wait_for_addon('Talk')
    dismiss_talk()
    wait_for_addon('SelectString')
    -- wait another moment for the select screen to fully load
    wait()
    yield('/click SelectString Entries[0].Select')
    wait()
    yield('/click SelectString Entries[' .. route .. '].Select')
    wait()
    yield('/callback SelectYesno true 0')
    wait()
end

local function is_ocean_fishing()
    return GetCharacterCondition(dutybound_condition) == true
end

local function ensure_casting()
    wait(2)
    local attempts = 0
    while not GetCharacterCondition(fishing_condition) and is_on_boat() and attempts < 3 do
        verbose('Attempting to cast')
        yield('/ac Cast')
        wait()
        attempts = attempts + 1
    end

    if attempts == 3 then
        verbose('Bailing on attempting to cast, ran out of attempts')
    end
end

local function wait_for_cutscene()
    wait_for_condition(watching_cutscene_condition, false, 1)
end

local function ocean_fish()
    SetAutoHookState(true)
    verbose('Waiting for duty to start')
    wait_for_start()

    verbose('Moving to the deck side of the boat')
    move_to_deck()

    while is_on_boat() do
        repeat
            -- at 35 seconds it's likely that you won't get more than 1 more cast, so just stop
            while GetCurrentOceanFishingZoneTimeLeft() > 35 and is_ocean_fishing() do
                ensure_correct_bait()
                ensure_casting()
                wait()
            end

            verbose('Less than 35 seconds remain, just waiting now')
            -- wait until the end of the zone timer plus some buffer
            wait(37)
            -- wait until the end of the zone transition cutscene
            wait_for_cutscene()
            -- wait until the next area is fully ready
            wait(5)
            -- if we hit the end of the voyage, just bail out
            if has_results() then
                verbose('Ending ocean fishing because we hit the end of the trip')
                close_results()
                break
            end
            -- wait for the second zone transition cutscene
            wait_for_cutscene()
            -- wait until you can cast again
            wait(5)
        until not is_ocean_fishing()
    end
end

-- local function open_desynth_window()
-- end

-- local function desynth_top_item()
-- end

-- local function desynth_item_count()
-- end

-- local function desynth_fish()
--     open_desynth_window()
--     wait_for_addon('SalvageItemSelector')
--     repeat
--         desynth_top_item()
--     until desynth_item_count() == 0
-- end

local function ensure_fisher(gearset)
    if GetClassJobId() ~= fisher_job then
        yield('/gearset change ' .. gearset)
    end
end

local function main(character, route, gearset, repair_threshold, autoretainer_enabled, do_subs, destination)
    verbose('Starting')
    if character == nil then
        character = GetCharacterName(true)
        verbose('Updating current character to ' .. character)
    end

    while true do
        if GetInventoryFreeSlotCount() < 3 then
            verbose('Inventory is almost full, stopping...')
            break
        end

        if is_ocean_fishing_time() then
            verbose('Time to ocean fish')
            ensure_fisher(gearset)
            lifestream('oceanfish')
            queue_for_fishing(route)
            ocean_fish()
            -- desynth_fish()
            lifestream(destination)
            verbose('Finished this round, waiting for the next one')
        end

        -- if NeedsRepair(repair_threshold) then
        --     repair_all()
        -- end

        if autoretainer_enabled and need_autoretainer(do_subs) then
            process_autoretainer(do_subs)
        end

        if GetCharacterName(true) ~= character then
            verbose('Not currently on ' .. character .. ', attempting to relog')
            ARSetMultiModeEnabled(false)
            wait()
            ARRelog(character)
        end

        wait(1)
    end

    verbose('Finished')
end

main(ocean_fisher, route_number, fisher_gearset, repair_amount, enable_autoretainer, subs_only, home_destination)
