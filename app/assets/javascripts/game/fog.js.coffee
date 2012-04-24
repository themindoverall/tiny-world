v = cp.v

class Game.Fog extends Game.GameObject
	initialize: (game, data) ->
		super(game, data)

		@layer = 10

		space = game.space

		pos = data.position

		@checkTime = 0.2
		@timer = 0
		@occupants = []
		@shapes = []
		@alpha = 1.0
		@targetAlpha = 1.0
		for face in data.faces
			verts = []
			for vidx in face
				dv = data.vertices[vidx]
				verts.push(pos[0] + dv[0])
				verts.push(-pos[1] + -dv[1])
			shape = space.addShape(new cp.PolyShape(space.staticBody, verts, v(0, 0)))
			shape.sensor = true
			shape.layers = 0b0
			shape.group = 10
			@shapes.push shape
	update: (elapsed) ->
		@timer += elapsed
		diff = Math.abs(@targetAlpha - @alpha)
		if diff > 0.1
			@alpha += elapsed * 1.0 * ((@targetAlpha - @alpha) / diff)
		else
			@alpha = @targetAlpha
		if @timer > @checkTime
			space = @game.space
			newOccupants = []

			for s in @shapes
				s.layers |= 0b10000
				space.shapeQuery s, (other, contacts) ->
					newOccupants.push(other) if newOccupants.indexOf(other) == -1
				s.layers &= ~0b10000

			# find leavers
			for occ in @occupants
				if newOccupants.indexOf(occ) == -1
					@targetAlpha = 1.0

			for occ in newOccupants
				if @occupants.indexOf(occ) == -1
					@targetAlpha = 0.0
			@occupants = newOccupants
			@timer = 0
	draw: (ctx) ->
		if @alpha <= 0
			return
		ctx.strokeStyle = 'rgba(255,255,255,0)'
		ctx.fillStyle = '#000'
		ctx.globalAlpha =	@alpha 
		for shape in @shapes
			shape.draw(ctx, Game.PTM_RATIO, (p) -> v.mult(p, Game.PTM_RATIO))
		ctx.globalAlpha = 1.0