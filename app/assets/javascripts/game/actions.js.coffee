after = (seconds, func)  ->
	setTimeout(func, seconds * 1000)
Game.Actions =
	action1:
		enter: (game, shape) ->
			game.get('platform1').activate()
		exit: (game, shape) ->
			game.dialog.say('<s class="header">Narrator\n</s>You do not belong here.', 2.0)
			after 2.5, ->
				game.dialog.say('<s class="header">Narrator\n</s>Well, I think that\'s true.', 2.0)
	action2:
		enter: ->
			this
