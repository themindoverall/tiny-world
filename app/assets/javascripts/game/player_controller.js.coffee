class Game.PlayerController
	constructor: (@game) ->
		this
		@movement = 0
		@jump = 'up'

		@keys =
			37: 'up' #left
			38: 'up' #up
			39: 'up' #right
			40: 'up' #down
			88: 'up' #x
			90: 'up' #z


		$(document).keydown(@onkeydown).keyup(@onkeyup)
	update: (elapsed) ->
		@jump = @keys[90]

		for k, v of @keys
			if v == 'jp'
				@keys[k] = 'dn'

		@movement = (if @keys[39] != 'up' then 1.0 else 0) - (if @keys[37] != 'up' then 1.0 else 0)
	onkeydown: (e) =>
		if e.keyCode of @keys
			if @keys[e.keyCode] == 'up'
				@keys[e.keyCode] = 'jp'
	onkeyup: (e) =>
		if e.keyCode of @keys
			@keys[e.keyCode] = 'up'
