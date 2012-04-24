Futures = require('futures')

class Game.GameObject
	loadContent: (contentManager) ->
		future = Futures.future()
		future.fulfill()
		future
	initialize: (@game, @data) ->
		if @data.name
			@game.register(@data.name, this)
			@name = @data.name
		this
	unload: () ->
		@game.unregister(@name) if @name
	draw: (ctx) ->
		this
	start: () ->
		this
	update: (elapsed) ->
		this