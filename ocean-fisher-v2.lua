--[=====[
[[SND Metadata]]
author: lord2800
version: 0.0.1
description: >-
  Requirements:

  Import these lifestream commands:

  * {"ExportedName":"Ocean Fishing","Alias":"oceanfish","Enabled":true,"Commands":[{"Kind":0,"Point":{"X":0.0,"Y":0.0,"Z":0.0},"Aetheryte":8,"World":0,"CenterPoint":{"X":0.0,"Y":0.0},"CircularExitPoint":{"X":0.0,"Y":0.0,"Z":0.0},"Clamp":null,"Precision":20.0,"Tolerance":1,"WalkToExit":true,"SkipTeleport":15.0,"DataID":0,"UseTA":false},{"Kind":4,"Point":{"X":0.0,"Y":0.0,"Z":0.0},"Aetheryte":43,"World":0,"CenterPoint":{"X":0.0,"Y":0.0},"CircularExitPoint":{"X":0.0,"Y":0.0,"Z":0.0},"Clamp":null,"Precision":20.0,"Tolerance":1,"WalkToExit":true,"SkipTeleport":15.0,"DataID":0,"UseTA":false},{"Kind":2,"Point":{"X":-409.5739,"Y":3.9999278,"Z":74.009766},"Aetheryte":0,"World":0,"CenterPoint":{"X":0.0,"Y":0.0},"CircularExitPoint":{"X":0.0,"Y":0.0,"Z":0.0},"Clamp":null,"Precision":20.0,"Tolerance":1,"WalkToExit":true,"SkipTeleport":15.0,"DataID":0,"UseTA":false}],"GUID":"00000000-0000-0000-0000-000000000000"}

  * {"ExportedName":"Ocean Fishing Deck Edge","Alias":"boatdeck","Enabled":true,"Commands":[{"Kind":1,"Point":{"X":-7.5407605,"Y":6.749975,"Z":-6.032779},"Aetheryte":0,"World":0,"CenterPoint":{"X":0.0,"Y":0.0},"CircularExitPoint":{"X":0.0,"Y":0.0,"Z":0.0},"Clamp":null,"Precision":20.0,"Tolerance":1,"WalkToExit":true,"SkipTeleport":15.0,"DataID":0,"UseTA":false}],"GUID":"00000000-0000-0000-0000-000000000000"}

  Required settings:

  (for autoretainer being enabled)

  AutoRetainer -> Multi Mode -> Common Settings -> Wait on login screen

  AutoRetainer -> Multi Mode -> Common Settings -> Disable Multi Mode on Manual Login

  AutoRetainer -> Multi Mode -> Common Settings -> Teleportation -> Enabled (and configure it how you want)

  AutoHook -> configure preset(s) for ocean fishing, the community wiki has good enough presets so import those

  Probably more, too lazy to figure out what
plugin_dependencies:
- Lifestream
- AutoHook
- YesAlready
- AutoRetainer
configs:
  routeNumber:
    default: 0
    type: int
    min: 0
    max: 1
    required: true
    description: Which route to run (0 or 1)
  fisherGearset:
    default: ''
    type: string
    required: true
    description: The name or number of the gearset for your fisher job
  autohookPreset:
    default: '[FishingRaid] Normal'
    type: string
    required: true
    description: The autohook preset to use
  repairThreshold:
    default: 25
    type: int
    min: 1
    max: 99
    required: true
    description: The durability threshold before attempting to repair
  enableAutoretainer:
    default: false
    type: bool
    required: false
    description: Enable AutoRetainer integration
  subsOnly:
    default: false
    type: bool
    required: false
    description: Check only submersibles (true) or retainers and submersibles (false)
  homeDestination:
    default: 'home'
    type: string
    required: true
    description: Which lifestream destination to return to after fishing
  fishingNpcName:
    default: 'Dryskthota'
    type: string
    required: true
    description: The name of the fishing NPC (don't change unless you know what you're doing)

[[End Metadata]]
--]=====]

-- TODO interact with ids instead (how?)
-- local fishing_npc = 1005421
local fishing_npc = Config.GetString('fishingNpcName')

-- data
local baits = {
    ragworm = { id = 29714, name = "Ragworm" },
    krill = { id = 29715, name = "Krill" },
    plumpworm = { id = 29716, name = "Plump Worm" },
    versatile_lure = { id = 29717, name = "Versatile Lure" },
}

local ocean_zones = {
    [1] = { id = 237, name = "Galadion Bay", normal_bait = baits.krill, daytime = baits.ragworm, sunset = baits.plumpworm, nighttime = baits.krill },
    [2] = { id = 239, name = "Southern Merlthor", normal_bait = baits.krill, daytime = baits.krill, sunset = baits.ragworm, nighttime = baits.plumpworm },
    [3] = { id = 243, name = "Northern Merlthor", normal_bait = baits.ragworm, daytime = baits.plumpworm, sunset = baits.ragworm, nighttime = baits.krill },
    [4] = { id = 241, name = "Rhotano Sea", normal_bait = baits.plumpworm, daytime = baits.plumpworm, sunset = baits.ragworm, nighttime = baits.krill },
    [5] = { id = 246, name = "The Ciedalaes", normal_bait = baits.ragworm, daytime = baits.krill, sunset = baits.plumpworm, nighttime = baits.krill },
    [6] = { id = 248, name = "Bloodbrine Sea", normal_bait = baits.krill, daytime = baits.ragworm, sunset = baits.plumpworm, nighttime = baits.krill },
    [7] = { id = 250, name = "Rothlyt Sound", normal_bait = baits.plumpworm, daytime = baits.krill, sunset = baits.krill, nighttime = baits.krill },
    [8] = { id = 286, name = "Sirensong Sea", normal_bait = baits.plumpworm, daytime = baits.krill, sunset = baits.krill, nighttime = baits.krill },
    [9] = { id = 288, name = "Kugane Coast", normal_bait = baits.ragworm, daytime = baits.krill, sunset = baits.ragworm, nighttime = baits.plumpworm },
    [10] = { id = 290, name = "Ruby Sea", normal_bait = baits.krill, daytime = baits.ragworm, sunset = baits.plumpworm, nighttime = baits.krill },
    [11] = { id = 292, name = "Lower One River", normal_bait = baits.krill, daytime = baits.ragworm, sunset = baits.krill, nighttime = baits.krill },
}

local routes = {
    [1] = { [1] = 2, [2] = 1, [3] = 3 },
    [2] = { [1] = 2, [2] = 1, [3] = 3 },
    [3] = { [1] = 2, [2] = 1, [3] = 3 },
    [4] = { [1] = 1, [2] = 2, [3] = 4 },
    [5] = { [1] = 1, [2] = 2, [3] = 4 },
    [6] = { [1] = 1, [2] = 2, [3] = 4 },
    [7] = { [1] = 5, [2] = 3, [3] = 6 },
    [8] = { [1] = 5, [2] = 3, [3] = 6 },
    [9] = { [1] = 5, [2] = 3, [3] = 6 },
    [10] = { [1] = 5, [2] = 4, [3] = 7 },
    [11] = { [1] = 5, [2] = 4, [3] = 7 },
    [12] = { [1] = 5, [2] = 4, [3] = 7 },
    [13] = { [1] = 8, [2] = 9, [3] = 11 },
    [14] = { [1] = 8, [2] = 9, [3] = 11 },
    [15] = { [1] = 8, [2] = 9, [3] = 11 },
    [16] = { [1] = 8, [2] = 9, [3] = 10 },
    [17] = { [1] = 8, [2] = 9, [3] = 10 },
    [18] = { [1] = 8, [2] = 9, [3] = 10 },
}

local ocean_fisher = nil
local fisher_job = 18
local wait_duration = 0.5

local FISHING_CONDITION = 43
local OCCUPIED39_CONDITION = 39

local CAST_ACTION = 289
local REPAIR_ACTION = 6

require('lib/main')

set_default_duration(wait_duration)

local function is_ocean_fishing_time()
    local now = os.date('!*t')
    -- using 13 minutes after the hour because 15 after is the cutoff time
    -- 13 minutes gives time for teleport/movement
    return now.hour % 2 == 0 and now.min < 13
end

local function ensure_fisher(gearset)
    if Player.Job.Id ~= fisher_job then
        -- TODO iterate gearsets and find the highest ilvl gearset assigned to fisher
        command('gearset change ' .. gearset)
    end
end

local function queue_for_fishing(route)
    debug('OceanFisher', 'Queueing for ocean fishing on route ' .. route)
    target(fishing_npc)
    interact()
    dismiss_talk()
    select_menu(0)
    select_menu(route)
    select_yesno(1)
    wait()
    debug('OceanFisher', 'Queued for ocean fishing on route ' .. route)
end

local function move_to_deck()
    lifestream('boatdeck')
end

local function is_on_boat()
    return Svc.ClientState.TerritoryType == 900 or Svc.ClientState.TerritoryType == 1163
end

local function get_correct_bait()
    -- lua indexes at 1, so add 1
    local current_route = routes[InstancedContent.OceanFishing.CurrentRoute + 1]
    local current_zone = current_route[InstancedContent.OceanFishing.CurrentZone + 1]
    local ocean_zone = ocean_zones[current_zone]
    if not InstancedContent.OceanFishing.SpectralCurrentActive then
        return ocean_zone.normal_bait
    end
    local fish_tod = InstancedContent.OceanFishing.TimeOfDay
    if fish_tod == 1 then return ocean_zone.daytime end
    if fish_tod == 2 then return ocean_zone.sunset end
    if fish_tod == 3 then return ocean_zone.nighttime end
    return baits.versatile_lure
end

local function wait_until_not_fishing()
    debug('OceanFisher', 'Waiting to not be currently fishing')
    wait_for_condition(FISHING_CONDITION, false)
    debug('OceanFisher', 'No longer fishing')
end

local function set_bait(bait)
    command('bait ' .. bait.name)
end

local function cast()
    action(CAST_ACTION, ActionType.Action)
end

local function ensure_correct_bait()
    local correct_bait = get_correct_bait()
    local current_bait = Player.FishingBait
    local disabled_autohook = false

    while current_bait ~= correct_bait.id and InstancedContent.OceanFishing.TimeLeft > 35 do
        debug('OceanFisher', 'Current bait is ' .. current_bait .. ', correct bait is ' .. correct_bait.id .. ' (' .. correct_bait.name .. ')')
        wait_until_not_fishing()
        disable_autohook()
        disabled_autohook = true
        debug('OceanFisher', 'Attempting to set bait to ' .. correct_bait.name)
        set_bait(correct_bait)
        wait()
        current_bait = Player.FishingBait
        debug('OceanFisher', 'Bait is now set to ' .. current_bait)
    end
    if disabled_autohook then
        enable_autohook()
    end
end

local function ensure_casting()
    if Svc.Condition[FISHING_CONDITION] then
        return
    end

    wait(2)
    local attempts = 0
    while not Svc.Condition[FISHING_CONDITION] and attempts < 3 do
        debug('OceanFisher', 'Attempting to cast')
        cast()
        wait()
        attempts = attempts + 1
    end

    if attempts == 3 then
        debug('OceanFisher', 'Bailing on attempting to cast, ran out of attempts')
    end

    debug('OceanFisher', 'Successfully cast')
end

local function has_results()
    return is_addon_ready('IKDResult')
end

local function wait_for_results_dialog()
    wait_for(function () return not has_results() end)
end

local function close_results()
    wait_for_results_dialog()
    debug('OceanFisher', 'Closing results dialog')
    -- TODO update for varargs
    callback('IKDResult true 0')
    debug('OceanFisher', 'Closed results dialog')
end

local function ocean_fish(preset)
    debug('OceanFisher', 'Enabling autohook')
    enable_autohook()
    debug('OceanFisher', 'Setting autohook preset to ' .. preset)
    set_autohook_preset(preset)
    debug('OceanFisher', 'Waiting for duty to start')
    wait_for_duty_start()

    debug('OceanFisher', 'Moving to the deck side of the boat')
    move_to_deck()

    while is_on_boat() do
        local status = InstancedContent.OceanFishing.Status
        if status == OceanFishingStatus.Fishing then
            if InstancedContent.OceanFishing.TimeLeft > 35 then
                ensure_correct_bait()
                ensure_casting()
            end
        elseif status == OceanFishingStatus.Finished or status == nil then
            wait_for_results_dialog()
            wait(3)
            close_results()
            wait()
            debug('OceanFisher', 'Finished fishing')
            return
        end

        wait()
    end
end

local function need_to_relog(character)
    verbose('OceanFisher', 'Checking if we need to relog, we are currently ' .. get_full_player_name() .. ' and we should be ' .. character)
    return get_full_player_name() ~= character
end

local function repair_all(items)
    -- TODO check all of the items to see what dark matter they require and then check that we have at least that many
    debug('OceanFisher', 'Repairing your gear')
    general_action(REPAIR_ACTION)
    wait_for_addon('Repair')
    debug('OceanFisher', 'Repair dialog opened')
    click('Repair RepairAll')
    select_yesno(1)
    debug('OceanFisher', 'Starting repair')
    wait_for_condition(OCCUPIED39_CONDITION, false)
    debug('OceanFisher', 'Repairing')
    wait_for_condition(OCCUPIED39_CONDITION)
    debug('OceanFisher', 'Repair finished')
    callback('Repair true -1')
    wait_for_addon_dismissed('Repair')
    debug('OceanFisher', 'Repair dialog closed')
end

local function main(character, route, gearset, preset, repair_threshold, autoretainer_enabled, do_subs, destination)
    debug('OceanFisher', 'Starting')

    debug('OceanFisher', 'Configuring YesAlready correctly to ensure automatic duty finder queues')
    local ya_toggled = false
    if is_yesalready_enabled() then
        enable_yesalready()
        verbose('OceanFisher', 'Enabled YesAlready')
        ya_toggled = true
    end
    local bother_toggled = false
    if is_yesalready_feature_enabled('ContentsFinderConfirm') then
        enable_yesalready_feature('ContentsFinderConfirm')
        verbose('OceanFisher', 'Enabled ContentsFinderConfirm')
        bother_toggled = true
    end

    if character == nil then
        character = get_full_player_name()
        debug('OceanFisher', 'Updating current character to ' .. character)
    end

    while true do
        if Inventory.GetFreeInventorySlots() < 3 then
            debug('OceanFisher', 'Inventory is almost full, stopping...')
            break
        end

        if is_ocean_fishing_time() then
            debug('OceanFisher', 'Time to ocean fish')
            ensure_fisher(gearset)
            lifestream('oceanfish')
            queue_for_fishing(route)
            ocean_fish(preset)
            wait(3)
            lifestream(destination)
            debug('OceanFisher', 'Finished this round, waiting for the next one')
        end

        verbose('OceanFisher', 'Checking to see if we need to repair')
        local items = Inventory.GetItemsInNeedOfRepairs(repair_threshold)
        if items.Count ~= nil and items.Count > 0 then
            verbose('OceanFisher', 'There are ' .. tostring(items.Count) .. ' items to repair')
            repair_all(items)
        end

        if autoretainer_enabled and need_autoretainer(do_subs) then
            process_autoretainer(do_subs)
        end

        if need_to_relog(character) then
            relog_autoretainer(character)
        end

        wait(1)
    end

    if bother_toggled then
        disable_yesalready_feature('ContentsFinderConfirm')
    end

    if ya_toggled then
        disable_yesalready()
    end

    debug('OceanFisher', 'Finished')
end

main(
    ocean_fisher,
    Config.GetInt('routeNumber'),
    Config.GetString('fisherGearset'),
    Config.GetString('autohookPreset'),
    Config.GetInt('repairThreshold'),
    Config.GetBool('enableAutoretainer'),
    Config.GetBool('subsOnly'),
    Config.GetString('homeDestination')
)
