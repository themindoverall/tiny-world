Futures = require('futures')

v = cp.v
v.zero = v(0,0)

class Game.Coin extends Game.GameObject
	initialize: (game, data) ->
		super(game, data)

		space = game.space

		@pos = v(data.position[0], -data.position[1])
		#@body.setPos(pos)

		@checkTime = 0.1
		@timer = Math.random() * @checkTime
		
		@shape = space.addShape(new cp.CircleShape(space.staticBody, 0.5, @pos))
		@shape.sensor = true
		@shape.group = 2
		@shape.layers = 0b1000
		@dead = false
	loadContent: (content) ->
		future = Futures.future()
		content.loadImage('coin.png').when (err, img) =>
			@image = img
			future.fulfill()
		future
	update: (elapsed) ->
		if @dead
			return

		@timer += elapsed
		if @timer > @checkTime
			space = @game.space
			space.shapeQuery @shape, (other, contacts) =>
				@dead = true
			if @dead
				console.log 'coin collected!'

			@timer = 0
	unload: () ->
		super()
		@game.space.removeShape(@shape)
	draw: (ctx) ->
		ctx.drawImage(@image, @pos.x * Game.PTM_RATIO - @image.width * 0.5, @pos.y * Game.PTM_RATIO - @image.height * 0.5)