b2Vec2 = Box2D.Common.Math.b2Vec2
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2Fixture = Box2D.Dynamics.b2Fixture
b2MassData = Box2D.Collision.Shapes.b2MassData
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape

class Game.Player extends Game.GameObject
	initialize: (game, data) ->
		super(game, data)

		world = game.world

		fixDef = new b2FixtureDef
		fixDef.density = 1.0
		fixDef.friction = 0.5
		fixDef.restitution = 0.2
		
		bodyDef = new b2BodyDef
		bodyDef.type = b2Body.b2_dynamicBody

		fixDef.shape = new b2CircleShape(1.0)
		
		bodyDef.position.x = data.position[0] - 2.5
		bodyDef.position.y = -data.position[1]
		@body = world.CreateBody(bodyDef)
		@body.CreateFixture(fixDef)
		console.log "player is here!  i have body", @body 

		this
	update: (elapsed) ->
		this
	draw: (ctx) ->
		this