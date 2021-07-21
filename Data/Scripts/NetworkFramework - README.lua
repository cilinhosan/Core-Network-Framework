--[[ 

This is the Network Framework. A networking framework for Core, that is built on top of the standard Events namespace system.

The main features of this framework are:
- A Queue system that ensures that no matter how many networked events you send per second they are guaranteed to be delivered, without
the need for the developer to worry about the rate limits of Core networked events.

- A Multi Event system, that allows you to send events that surpass the limits of the standard Events system of 128 bytes of data per
networked event.

How to use:

To use the Network Framework, drag the template into the hierarchy in the default context.

Queue System:

    To start using the Queue system, all you have to do is replace your current calls to the standard Events namespace with their 
    Network Framework equivalents:

    Standard Events: Events.BroadcastToAllPlayers(eventName, ...)

                     function OnEvent(...)
                     Events.Connect(eventName, OnEvent)

    Network Framework: Events.Broadcast("NetworkFramework", eventName, ...)

                       function OnEvent(...)
                       Events.Connect(eventName, OnEvent)

    Standard Events: Events.BroadcastToPlayer(player, eventName, ... )
                    
                     function OnEvent(...)
                     Events.Connect(eventName, OnEvent)

    Network Framework: Events.Broadcast("NetworkFrameworkToPlayer", player, eventName, ...)

                       function OnEvent(...)
                       Events.Connect(eventName, OnEvent)

    Using the Queue system will ensure that instead of giving an error if you surpass the Events rate limits, your event is instead
    put into a Queue that will be gradually broadcast to the target clients while respecting the networked Events rate limits.

    You still have to respect Core's networked event data size limit of 128 bytes. If you want to send events with bigger size than that,
    you will have to use the Multi Event feature of this framework.

Multi Event System:

    The Multi Event system is what allows you to send events of size larger than 128 bytes, it accomplishes that by disassembling
    large events into multiple smaller events so that each of the smaller parts fit into the 128 bytes limit, and it also ensures that
    those events are still treated as one event once all parts reach the target clients. 
    
    In order to use the Multi Event system, you will have to adapt your code to fit its requirements, here are the equivalents:

    Standard Events: Events.BroadcastToAllPlayers(eventName, ... )

                     function OnEvent(...)
                     Events:Connect(eventName, OnEvent)

    Network Framework: Events.Broadcast("NetworkFrameworkMultiEvent", eventName, argumentTable)

                       function OnEvent(argumentTable)
                       Events:Connect(eventName, OnEvent)

    Standard Events: Events.BroadcastToPlayer(player, eventName, ... )

                     function OnEvent(...)
                     Events:Connect(eventName, OnEvent)

    Network Framework: Events.Broadcast("NetworkFrameworkMultiEventToPlayer", player, eventName, argumentTable)

                       function OnEvent(argumentTable)
                       Events:Connect(eventName, OnEvent)

    Here, argumentTable is the table where you will put your larger event divided into smaller parts. For example, if you want to pass
    "One", "Two" and "Three" as a Multi Event divided into 3 smaller parts, you will have to pass them as an argumentTable, where each index
    of the argumentTable stores a table that in turn stores the arguments of each smaller event, following these rules, the argumentTable
    would be:

    local argumentTable = {}
    argumentTable[1] = {"One"}
    argumentTable[2] = {"Two"}
    argumentTable[3] = {"Three"}
    
    You can pass as many arguments as you want into each of the smaller parts, as long as each of them don't surpass the size limit of a
    single event. All types of arguments supported by the standard Events system are also supported.
    
    You are responsible for dividing your larger events into smaller parts and fitting them in the right place in the argumentTable.

    On the client, you will receive the argumentTable as if it were a single event broadcast to the client by the server. You are
    responsible for reassembling your event from the contents inside the argumentTable.

    This works by queueing each of the smaller parts into the client until all parts of the event are received by the client, after that
    the argumentTable is locally broadcast as if it were a single event received by the server. The higher the amount of parts your
    Multi Event has, the longer it will take for it to be completely delivered to the clients. Each part of the Multi Event is a single
    event, and takes about 0.1 seconds to be sent from the server. Internally, an additional metadata event is sent by the Multi Event, 
    which contains information about the Multi Event itself, such as the eventName, this means that if your Multi Event has n parts,
    n+1 events will be sent from the server, taking about n+1/10 seconds in total to be sent from the server. You don't need to do anything
    about the initial metadata event, as it is internally used by the framework itself.

--]]