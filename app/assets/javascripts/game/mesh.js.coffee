v = cp.v

class Game.Mesh extends Game.GameObject
	initialize: (game, data) ->
		super(game, data)

		space = game.space
		
		for face in data.faces
			verts = []
			for vidx in face
				dv = data.vertices[vidx]
				verts.push(dv[0])
				verts.push(-dv[1])
			shape = space.addShape(new cp.PolyShape(space.staticBody, verts, v(0, 0)))
			shape.setFriction(7)
			shape.layers = 0b11

		###fixDef = new b2FixtureDef
		fixDef.density = 1.0
		fixDef.friction = 0.5
		fixDef.restitution = 0.2
		bodyDef = new b2BodyDef
		bodyDef.type = b2Body.b2_staticBody
		bodyDef.position.x = data.position[0]
		bodyDef.position.y = data.position[1]
		fixDef.shape = new b2PolygonShape

		#bodyDef.position.Set(-3, -5)
		@body = world.CreateBody(bodyDef)
		fixDef.shape.SetAsBox(2.5, 1)
		@body.CreateFixture(fixDef)

		for face in data.faces
			verts = []
			for v in face.reverse()
				dv = data.vertices[v]
				verts.push(new b2Vec2(dv[0], -dv[1]))
			fixDef.shape.SetAsArray(verts, 0)
			@body.CreateFixture(fixDef)
		@body.ResetMassData();###

		console.log("body is ", @body)

	draw: (ctx) ->
		this