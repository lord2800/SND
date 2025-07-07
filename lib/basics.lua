local echo_logs = false
local default_duration = 0.5

function enable_log_echo()
    echo_logs = true
end

function disable_log_echo()
    echo_logs = false
end

function set_default_duration(duration)
    default_duration = duration or default_duration
end

function log(system, msg, outputter)
    local output = '[' .. system .. '] ' .. msg
    if echo_logs then
        yield('/echo ' .. output)
    end

    outputter(output)
end

function debug(system, msg)
    log(system, msg, function (msg) Dalamud.LogDebug(msg) end)
end

function verbose(system, msg)
    log(system, msg, function (msg) Dalamud.LogVerbose(msg) end)
end

function wait(duration)
    yield('/wait ' .. (duration or default_duration))
end

function wait_for(fn, duration)
    while fn() do
        wait(duration)
    end
end
