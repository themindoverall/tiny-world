Game.Events = {}

Game.Events.eventDispatcher = (c) ->
	c::emit = (event, data) ->
		if not @_event_listeners
			@_event_listeners = {}
		if @_event_listeners[event]
			for listener in @_event_listeners[event]
				listener(data)
	c::on = (event, callback) ->
		if not @_event_listeners
			@_event_listeners = {}
		if not @_event_listeners[event]
			@_event_listeners[event] = []
		@_event_listeners[event].push(callback)

