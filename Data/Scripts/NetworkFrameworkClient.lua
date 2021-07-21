local multiEventBuffer = {}
local currentMultiEventCount
local currentMultiEventName


function OnNetworkFrameworkMultiEvent(eventName, multiEventPartNumber, multiEventCount, ...)

    local eventPartArguments = {...}

    -- if it is the metadata part
    if multiEventPartNumber == 0 then

        currentMultiEventName = eventName
        currentMultiEventCount = multiEventCount

    -- if it is the first part
    elseif multiEventPartNumber == 1 then
        -- store it inside the buffer
        multiEventBuffer[1] = eventPartArguments

    -- if it one of the middle parts
    elseif multiEventPartNumber < currentMultiEventCount then
        multiEventBuffer[multiEventPartNumber] = eventPartArguments

    -- if it is the last part
    elseif multiEventPartNumber == currentMultiEventCount then
        multiEventBuffer[multiEventPartNumber] = eventPartArguments

        Events.Broadcast(currentMultiEventName, table.unpack(multiEventBuffer))

        multiEventBuffer = {}
        currentMultiEventName = nil
        currentMultiEventCount = nil

    end
end

Events.Connect("NetworkFrameworkMultiEvent", OnNetworkFrameworkMultiEvent)