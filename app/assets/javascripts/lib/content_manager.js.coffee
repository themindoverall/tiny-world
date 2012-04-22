Futures = require('futures')

class Game.ContentManager
	constructor: ->
		@root = ''
	loadImage: (name) ->
		future = Futures.future()
		img = new Image()
		img.src = "#{@root}#{name}"
		img.onload = ->
			future.fulfill(null, this)
		future
	loadData: (name) ->
		console.log 'loading... ', name
		future = Futures.future()
		$.get "#{@root}#{name}", (data) ->
			future.fulfill(null, data)
		future
