#= require ./player

class Game.Spawn extends Game.GameObject
	draw: (ctx) ->
		this

class Game.PlayerSpawn extends Game.Spawn
	initialize: (game, data) ->
		super(game, data)
		@pos = data.position
	start: () ->
		player = new Game.Player()
		@game.add(player, {position: @pos})
	draw: (ctx) ->
		this