local EVENT_TYPES = {}
EVENT_TYPES.ALL_PLAYERS = 1
EVENT_TYPES.PLAYER = 2
EVENT_TYPES.MULTIEVENT = 3
EVENT_TYPES.PLAYER_MULTIEVENT = 4

local bufferTable = {}

function ProcessBufferTable()

    while true do
        -- if bufferTable is empty then do nothing
        if #bufferTable ~= 0 then

            local currentEventData = bufferTable[1]

            -- if current event data is nill then remove it from buffer and go to next event while still in the loop
            if currentEventData == nil then
                table.remove(bufferTable, 1)
                goto CONTINUEWHILETRUELOOP
            end

            if currentEventData.eventType == EVENT_TYPES.ALL_PLAYERS then

                Events.BroadcastToAllPlayers(currentEventData.eventName, table.unpack(currentEventData.eventArgumentTable))
                table.remove(bufferTable, 1)

            elseif currentEventData.eventType == EVENT_TYPES.PLAYER then

                Events.BroadcastToPlayer(currentEventData.targetPlayer, currentEventData.eventName, table.unpack(currentEventData.eventArgumentTable))

                table.remove(bufferTable, 1)

            elseif currentEventData.eventType == EVENT_TYPES.MULTIEVENT then

                Events.BroadcastToAllPlayers("NetworkFrameworkMultiEvent", currentEventData.eventName, currentEventData.multiEventPartNumber, currentEventData.multiEventCount, table.unpack(currentEventData.eventPartArguments))

                table.remove(bufferTable, 1)

            elseif currentEventData.eventType == EVENT_TYPES.PLAYER_MULTIEVENT then
                Events.BroadcastToPlayer(currentEventData.targetPlayer, "NetworkFrameworkMultiEvent", currentEventData.eventName, currentEventData.multiEventPartNumber, currentEventData.multiEventCount, table.unpack(currentEventData.eventPartArguments))

                table.remove(bufferTable, 1)
            end
        end

        ::CONTINUEWHILETRUELOOP::
        Task.Wait(0.1)
    end
end

Task.Spawn(ProcessBufferTable)

function OnNetworkFrameworkEvent(eventName, ...)
    local argumentTable = {...}

    local eventData = {}

    eventData.eventType = EVENT_TYPES.ALL_PLAYERS
    eventData.eventName = eventName
    eventData.eventArgumentTable = argumentTable

    table.insert(bufferTable, eventData)

end

Events.Connect("NetworkFramework", OnNetworkFrameworkEvent)


function OnNetworkFrameworkMultiEvent(eventName, argumentTable)

    local eventType = EVENT_TYPES.MULTIEVENT

    -- get multiEventCount
    local multiEventCount = 0

    for i, j in ipairs(argumentTable) do
        multiEventCount = multiEventCount + 1
    end


    -- first insert the information event with the eventName and multiEventCount
    local eventPartData = {
        eventType = eventType,
        eventName = eventName,
        multiEventCount = multiEventCount,
        multiEventPartNumber = 0,
        eventPartArguments = {},
    }
    table.insert(bufferTable, eventPartData)


    for i, arguments in ipairs(argumentTable) do

        local multiEventPartNumber = i
        local eventPartArguments = arguments

        local eventPartData = {
            eventType = eventType,
            eventName = false,
            multiEventCount = false,
            multiEventPartNumber = multiEventPartNumber,
            eventPartArguments = eventPartArguments,

        }

        table.insert(bufferTable, eventPartData)
    end
end

Events.Connect("NetworkFrameworkMultiEvent", OnNetworkFrameworkMultiEvent)


function OnNetworkFrameworkEventToPlayer(targetPlayer, eventName, ...)
    local argumentTable = {...}

    local eventData = {}

    eventData.eventType = EVENT_TYPES.PLAYER
    eventData.eventName = eventName
    eventData.eventArgumentTable = argumentTable

    eventData.targetPlayer = targetPlayer

end

Events.Connect("NetworkFrameworkToPlayer", OnNetworkFrameworkEventToPlayer)


function OnNetworkFrameworkMultiEventToPlayer(targetPlayer, eventName, argumentTable)

    local eventType = EVENT_TYPES.MULTIEVENT

    -- get multiEventCount
    local multiEventCount = 0

    for i, j in ipairs(argumentTable) do
        multiEventCount = multiEventCount + 1
    end


    -- first insert the metadata event with the eventName and multiEventCount
    local eventPartData = {
        targetPlayer = targetPlayer,
        eventType = eventType,
        eventName = eventName,
        multiEventCount = multiEventCount,
        multiEventPartNumber = 0,
        eventPartArguments = {},
    }
    table.insert(bufferTable, eventPartData)


    for i, arguments in ipairs(argumentTable) do

        local multiEventPartNumber = i
        local eventPartArguments = arguments

        local eventPartData = {
            targetPlayer = targetPlayer,
            eventType = eventType,
            eventName = false,
            multiEventCount = false,
            multiEventPartNumber = multiEventPartNumber,
            eventPartArguments = eventPartArguments,

        }

        table.insert(bufferTable, eventPartData)
    end
end

Events.Connect("NetworkFrameworkMultiEventToPlayer", OnNetworkFrameworkMultiEventToPlayer)