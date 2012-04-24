Game.Actions =
	action1:
		enter: (game, shape) ->
			game.get('platform1').activate()
		exit: (game, shape) ->
			game.dialog.setText('<s class="header">Narrator\n</s>Well, I think that\'s true.')
	action2:
		enter: ->
			this
