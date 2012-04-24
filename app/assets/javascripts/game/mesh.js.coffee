v = cp.v

class Game.Mesh extends Game.GameObject
	initialize: (game, data) ->
		super(game, data)

		space = game.space

		pos = data.position

		for face in data.faces
			verts = []
			for vidx in face
				dv = data.vertices[vidx]
				verts.push(pos[0] + dv[0])
				verts.push(-pos[1] + -dv[1])
			shape = space.addShape(new cp.PolyShape(space.staticBody, verts, v(0, 0)))
			shape.setFriction(7)
			shape.layers = 0b11
			shape.group = 10
		console.log("body is ", @body)

	draw: (ctx) ->
		this