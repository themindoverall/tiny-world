Futures = require('futures')

v = cp.v
v.zero = v(0,0)

dist = (p1, p2) ->
	Math.sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y)) 

class Game.Platform extends Game.GameObject
	draw: (ctx) ->
		this

class Game.MovingPlatform extends Game.Platform
	initialize: (game, data) ->
		space = game.space
		
		pos = data.position

		@body = space.addBody(new cp.Body(Number.MAX_VALUE, Number.MAX_VALUE))

		@origin = v(pos[0], -pos[1])
		
		@body.setPos(v(pos[0], -pos[1]))
		@path = (v(p[0], -p[1]) for p in data.path)
		@speed = data.speed or 10
		@method = data.method or "pingpong"
		@dir = 1
		@cur = 1

		@imagename = data.image

		for face in data.faces
			verts = []
			for vidx in face
				dv = data.vertices[vidx]
				verts.push(dv[0])
				verts.push(-dv[1])
			shape = space.addShape(new cp.PolyShape(@body, verts, v(0, 0)))
			shape.setFriction(7)
			shape.layers = 0b110
			shape.group = 10
	loadContent: (content) ->
		future = Futures.future()
		content.loadImage(@imagename).when (err, img) =>
			@image = img
			future.fulfill()
		future
	update: (elapsed) ->
		curpath = v.add(@origin, @path[@cur])
		diff = v(curpath.x - @body.p.x, curpath.y - @body.p.y)
		mag = dist(@body.p, curpath)

		if mag > 0
			@body.vx = diff.x / mag
			@body.vy = diff.y / mag

		if mag < 1
			@cur += @dir

			if @cur < 0 or @cur >= @path.length
				if @method == 'pingpong'
					@dir *= -1
					@cur += @dir * 2
				else # 'loop'
					@cur = 0
	draw: (ctx) ->
		ctx.drawImage(@image, @body.p.x * Game.PTM_RATIO - @image.width * 0.5, @body.p.y * Game.PTM_RATIO - @image.height * 0.5)