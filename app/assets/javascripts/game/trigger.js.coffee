v = cp.v
v.zero = v(0,0)

class Game.Trigger extends Game.GameObject
	initialize: (game, data) ->
		super(game, data)

		space = game.space

		pos = data.position

		@checkTime = 0.2
		@timer = 0

		@occupants = []

		@shapes = []

		for face in data.faces
			verts = []
			for vidx in face
				dv = data.vertices[vidx]
				verts.push(pos[0] + dv[0])
				verts.push(-pos[1] + -dv[1])
			shape = space.addShape(new cp.PolyShape(space.staticBody, verts, v(0, 0)))
			shape.sensor = true
			shape.group = 2
			shape.layers = 0b1000
			@shapes.push(shape)
	update: (elapsed) ->
		@timer += elapsed
		if @timer > @checkTime
			space = @game.space
			newOccupants = []

			for s in @shapes
				space.shapeQuery s, (other, contacts) ->
					newOccupants.push(other) if newOccupants.indexOf(other) == -1

			# find leavers
			for occ in @occupants
				if newOccupants.indexOf(occ) == -1
					this.onLeave(occ)

			for occ in newOccupants
				if @occupants.indexOf(occ) == -1
					this.onEnter(occ)
				else
					this.onInside(occ)
			@occupants = newOccupants
			@timer = 0

	onEnter: (shape) ->
		console.log 'trigger.on enter', shape
		@game.dialog.setText("Welcome to my great domain.")
	onInside: (shape) ->
		console.log 'trigger.on inside'
		this
	onLeave: (shape) ->
		console.log 'trigger.on leave'
		@game.dialog.setText("You will enjoy it here... hahaha.")
