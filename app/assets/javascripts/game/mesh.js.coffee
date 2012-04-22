b2Vec2 = Box2D.Common.Math.b2Vec2
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2Fixture = Box2D.Dynamics.b2Fixture
b2MassData = Box2D.Collision.Shapes.b2MassData
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape

class Game.Mesh extends Game.GameObject
	initialize: (game, data) ->
		super(game, data)

		world = game.world
		console.log('is world null', game)

		fixDef = new b2FixtureDef
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
		@body.ResetMassData();

		console.log("body is ", @body)

	draw: (ctx) ->
		this