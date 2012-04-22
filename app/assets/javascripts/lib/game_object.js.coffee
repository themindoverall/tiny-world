Futures = require('futures')

class Game.GameObject
	loadContent: (contentManager) ->
		future = Futures.future()
		future.fulfill()
		future
	initialize: (@game, @data) ->
		this
	draw: (ctx) ->
		this
	start: () ->
		this
	update: (elapsed) ->
		this