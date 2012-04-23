Futures = require('futures')

class Game.Tilemap extends Game.GameObject
	initialize: (@game, level) ->
		@bounds = level.bounds
		@images = {}
		@width = 1 + @bounds[2] - @bounds[0]
		@height = 1 + @bounds[3] - @bounds[1]
	loadContent: (content) ->
		join = Futures.join()
		for y in [@bounds[1]..@bounds[3]]
			for x in [@bounds[0]..@bounds[2]]
				do (content, x, y) =>

					name = "level_#{x}x#{y}.png"
					future = Futures.future()
					content.loadImage(name).when (err, img) =>
						@images["" + x + ":" + y] = img
						console.log "my images are", @images
						future.fulfill()
					join.add(future)
		join

	draw: (ctx) ->
		for i, img of @images
			s = i.split(':')
			x = parseInt(s[0])
			y = parseInt(s[1])
			ctx.drawImage(img, 512*x, 512*-(y + 1))