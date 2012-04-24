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
		super(game, data)

		space = game.space
		
		pos = data.position

		@body = space.addBody(new cp.Body(Number.MAX_VALUE, Number.MAX_VALUE))

		@origin = v(pos[0], -pos[1])
		
		@body.setPos(v(pos[0], -pos[1]))
		@path = (v(p[0], -p[1]) for p in data.path)
		@speed = data.speed or 1
		@method = data.method or "pingpong"
		@dir = 1
		@cur = 1
		@active = false

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
		unless @active
			return
		curpath = v.add(@origin, @path[@cur])
		diff = v(curpath.x - @body.p.x, curpath.y - @body.p.y)
		mag = dist(@body.p, curpath)

		if mag > 0
			@body.vx = @speed * diff.x / mag
			@body.vy = @speed * diff.y / mag
		if mag < 1
			oldcur = @cur
			olddir = @dir
			@cur += @dir

			if @cur < 0 or @cur >= @path.length
				if @method == 'pingpong'
					@dir *= -1
					@cur += @dir * 2
				else # 'loop'
					@cur = 0
			this.fixTouchingBodies(oldcur, olddir)
	fixTouchingBodies: (oldcur, olddir) ->
		old = oldcur - olddir
		if old < 0 or old >= @path.length
			if @method == 'pingpong'
				old += olddir * 2
			else
				old = @path.length - 1

		prev = @cur - @dir
		if prev < 0 or prev >= @path.length
			if @method == 'pingpong'
				prev += @dir * 2
			else
				prev = @path.length - 1

		prevpath = v.add(@origin, @path[old])
		curpath  = v.add(@origin, @path[prev])
		nextpath = v.add(@origin, @path[@cur])
		prevdiff = v(curpath.x - prevpath.x, curpath.y - prevpath.y)
		nextdiff = v(nextpath.x - curpath.x, nextpath.y - curpath.y)

		norm = (vec) ->
			mag = Math.sqrt(vec.x * vec.x + vec.y * vec.y)
			v(vec.x / mag, vec.y / mag)

		prevdiff = norm(prevdiff)
		nextdiff = norm(nextdiff)

		vecchange = v(@speed * (nextdiff.x - prevdiff.x), @speed * (nextdiff.y - prevdiff.y))
		space = @game.space
		mybody = @body
		gotem = []
		@body.vx = nextdiff.x * @speed
		@body.vy = nextdiff.y * @speed
		for s in mybody.shapeList
			space.shapeQuery s, (other, contacts) ->
				if other.body != mybody and gotem.indexOf(other.body) == -1
					other.body.vx = vecchange.x
					other.body.vy = vecchange.y if vecchange.y > 0
					gotem.push(other.body)

		# pick all the bodies touching this platform
		# subtract the old velocity from their velocities
		# add the new velocity to their velocity
	activate: () ->
		@active = true
		@body.activate()
	draw: (ctx) ->
		ctx.drawImage(@image, @body.p.x * Game.PTM_RATIO - @image.width * 0.5, @body.p.y * Game.PTM_RATIO - @image.height * 0.5)