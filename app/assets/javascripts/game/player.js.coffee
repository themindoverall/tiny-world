#= require ./player_controller

b2Vec2 = Box2D.Common.Math.b2Vec2
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2Fixture = Box2D.Dynamics.b2Fixture
b2RevoluteJointDef = Box2D.Dynamics.Joints.b2RevoluteJointDef
b2RevoluteJoint = Box2D.Dynamics.Joints.b2RevoluteJoint
b2MassData = Box2D.Collision.Shapes.b2MassData
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape

class PlatformerState
	constructor: (@owner) ->
	enter: () ->
		this
	execute: (elapsed) ->
		null
	exit: () ->
		this
	setupSensors: () ->
		lx = @owner.body.GetLinearVelocity().x

		if lx > 0 or @owner.controller.movement > 0
			@owner.sensors["sr"].enabled = true
		else
			@owner.sensors["sr"].enabled = false

		if lx < 0 or @owner.controller.movement < 0
			@owner.sensors["sl"].enabled = true
		else
			@owner.sensors["sl"].enabled = false


class GroundState extends PlatformerState
	enter: () ->
		@owner.motor.EnableMotor(true)
		@owner.sensors["bl"].enabled = true
		@owner.sensors["br"].enabled = true
		@moving = false
	exit: () ->
		@owner.motor.EnableMotor(false)
		@owner.sensors["bl"].enabled = false
		@owner.sensors["br"].enabled = false
	execute: (elapsed) ->
		preventmoving = false
		nowmoving = false

		if @owner.controller.movement < 0
			preventmoving = @owner.sensors["sr"].result
			# owner.setFlipX(false)
		else if @owner.controller.movement > 0
			preventmoving = @owner.sensors["sl"].result
			# owner.setFlipX(true)

		if preventmoving
			if @owner.motor.GetMotorSpeed() != 0
				@owner.motor.SetMotorSpeed(0)

		else if Math.abs((@owner.controller.movement * 10.0) - @owner.motor.GetMotorSpeed()) > 0.1
			@owner.motor.SetMotorSpeed(-@owner.controller.movement * @owner.RUN_SPEED)
			nowmoving = true

		if nowmoving and !@moving
			this #animation
		else
			this #animation

		@moving = nowmoving

		if @owner.controller.jump == 'jp'
			@owner.body.SetLinearVelocity(new b2Vec2(@owner.body.GetLinearVelocity().x, 0))
			@owner.body.ApplyImpulse(new b2Vec2(0, -@owner.JUMP_SPEED), @owner.body.GetWorldCenter())
			return "jump"

		if !(@owner.sensors["bl"].result or @owner.sensors["br"].result)
			return "air"

		return null

class JumpState extends PlatformerState
	enter: () ->
		@jumpTimer = @owner.JUMP_BONUS
		# owner.anim('jump')
	execute: (elapsed) ->
		lv = @owner.body.GetLinearVelocity().x
		if @owner.controller.movement != 0
			pow = 0
			if (lv / @owner.controller.movement) < 0
				pow = @owner.AIR_AGILITY
			else if Math.abs(lv) < @owner.MAX_AIR_SPEED
				pow = @owner.AIR_SPEED

			@owner.body.ApplyForceToCenter(new b2Vec2(pow * @owner.controller.movement, 0))

			if @owner.controller.movement > 0
				# owner.setFlipX(false)
			else
				#owner.setFlipX(true)

		@jumpTimer -= elapsed
		if @jumpTimer > 0
			if @owner.controller.jump != 'up'
				@owner.body.ApplyForceToCenter(new b2Vec2(0, @owner.JUMP_SPEED))
			else
				@jumpTimer = 0

		if @owner.body.GetLinearVelocity().y < 0
			return 'air'

		sides = (if @owner.sensors['sr'].result then 1 else 0) -
						(if @owner.sensors['sl'].result then 1 else 0)

		if sides != 0 and @owner.controller.movement != 0 and @owner.controller.movement / sides > 0
			return 'wallride'

		return null

class AirState extends PlatformerState
	enter: () ->
		@owner.sensors['bl'].enabled = true
		@owner.sensors['br'].enabled = true
		# animate falling

	exit: () ->
		@owner.sensors['bl'].enabled = false
		@owner.sensors['br'].enabled = false

	execute: (elapsed) ->
		lv = @owner.body.GetLinearVelocity().x
		if @owner.controller.movement != 0
			pow = 0
			if (lv / @owner.controller.movement) < 0
				pow = @owner.AIR_AGILITY
			else if Math.abs(lv) < @owner.MAX_AIR_SPEED
				pow = @owner.AIR_SPEED

			@owner.body.ApplyForceToCenter(new b2Vec2(pow * @owner.controller.movement, 0))

			if @owner.controller.movement > 0
				#owner.setFlipX(false)
			else
				#owner.setFlipX(true)
		else if lv != 0
			lin = lv / Math.abs(lv)
			@owner.body.ApplyForceToCenter(new b2Vec2(lin * -@owner.AIR_DRAG, 0))

		if lv != 0 and Math.abs(lv) > @owner.MAX_AIR_SPEED
			@owner.body.SetLinearVelocity(new b2Vec2((lv / Math.abs(lv)) * @owner.MAX_AIR_SPEED, @owner.body.GetLinearVelocity().y))

		if @owner.body.GetLinearVelocity().y < -@owner.MAX_FALL_SPEED
			@owner.body.SetLinearVelocity(@owner.body.GetLinearVelocity().x, -@owner.MAX_FALL_SPEED)
		
		if @owner.sensors['bl'].result or @owner.sensors['br'].result
			return 'ground'

		sides = (if @owner.sensors['sr'].result then 1 else 0) -
						(if @owner.sensors['sl'].result then 1 else 0)

		if sides != 0 and @owner.controller.movement != 0 and @owner.controller.movement / sides > 0
			return 'wallride'	

		return null

class WallrideState extends PlatformerState
	setupSensors: () ->
		false
	enter: () ->
		@wallTimer = 0
		@owner.sensors['bl'].enabled = true
		@owner.sensors['br'].enabled = true

		if @owner.controller.movement < 0
			@owner.sensors['sl'].enabled = true
			@owner.sensors['sr'].enabled = false
			#owner.setFlipX(true)
			@side = -1
		else
			@owner.sensors['sl'].enabled = false
			@owner.sensors['sr'].enabled = true
			#owner.setFlipX(true)
			@side = 1

		# anim(wall)

		@owner.body.SetType(b2Body.b2_kinematicBody)

	exit: () ->
		@owner.sensors['sl'].enabled = false
		@owner.sensors['sr'].enabled = false
		@owner.body.SetType(b2Body.b2_dynamicBody)

	execute: (elapsed) ->
		@owner.body.SetLinearVelocity(new b2Vec2(0, @owner.WALL_SKID))

		console.log("movey ", @owner.controller.movement)

		if (@owner.controller.movement / @side) <= 0
			@wallTimer += elapsed
		else
			@wallTimer = 0

		if @owner.controller.jump == 'jp'
			return 'walljump'

		if @wallTimer > @owner.WALL_JUMP_WINDOW or (!@owner.sensors['sl'].result and !@owner.sensors['sr'].result)
			console.log("walltimer ", @wallTimer, "and", @owner.WALL_JUMP_WINDOW)
			return 'air'

		if @owner.sensors['bl'].result or @owner.sensors['br'].result
			return 'ground'

		return null

class WalljumpState extends PlatformerState
	enter: () ->
		if @owner.sensors['sl'].result
			@side = -1
			#owner.setFlipX(false)
		else
			@side = 1
			#owner.setFlipX(true)

		#animate(jump)

		@owner.body.SetLinearVelocity(new b2Vec2(0, 15))
		@owner.body.ApplyImpulse(new b2Vec2(@owner.JUMP_SPEED * @side * -0.5, -@owner.JUMP_SPEED), @owner.body.GetWorldCenter())
		@jumpTimer = @owner.JUMP_BONUS

	execute: (elapsed) ->
		@jumpTimer -= elapsed
		if @jumpTimer > 0
			if @owner.controller.jump != 'up'
				@owner.body.ApplyForceToCenter(new b2Vec2(0, -0.85 * @owner.JUMP_SPEED))
			else
				@jumpTimer = 0

		if @jumpTimer <= 0 and @owner.body.GetLinearVelocity().y > 0
			return 'air'

		sides = (if @owner.sensors['sr'].result then 1 else 0) -
						(if @owner.sensors['sl'].result then 1 else 0)

		if sides != 0 and @owner.controller.movement != 0 and @owner.controller.movement / sides > 0
			return 'wallride'

		return null

class Game.Player extends Game.GameObject
	JUMP_BONUS: 0.6
	RUN_SPEED: 18.0
	JUMP_SPEED: 55.0
	AIR_SPEED: 75.0
	AIR_DRAG: 46.0
	AIR_AGILITY: 105.0
	MAX_AIR_SPEED: 13.0
	MAX_FALL_SPEED: 20.0
	WALL_SKID: 5.0
	WALL_JUMP_WINDOW: 0.6
	initialize: (game, data) ->
		super(game, data)

		@currentState = null

		bodywidth = 12 / Game.PTM_RATIO
		bodyheight = 32 / Game.PTM_RATIO

		world = game.world

		fixDef = new b2FixtureDef
		fixDef.density = 1.0
		fixDef.friction = 10.0
		
		bodyDef = new b2BodyDef
		bodyDef.type = b2Body.b2_dynamicBody

		bodyDef.position.x = data.position[0] - 2.5
		bodyDef.position.y = -data.position[1]
		@body = world.CreateBody(bodyDef)
		@body.SetUserData(this)

		fixDef.shape = new b2CircleShape(1.0 / Game.PTM_RATIO + bodywidth / 2.0)

		@body.CreateFixture(fixDef)

		@body.ResetMassData()

		pivot = world.CreateBody(bodyDef)
		pivot.ResetMassData()

		mjd = new b2RevoluteJointDef
		mjd.Initialize(@body, pivot, pivot.GetPosition())
		mjd.motorSpeed = 0
		mjd.maxMotorTorque = 10000000
		mjd.enableMotor = true
		mjd.enableLimit = false
		@motor = world.CreateJoint(mjd)

		bodyDef.fixedRotation = true
		@head = world.CreateBody(bodyDef)
		fixDef.shape = new b2PolygonShape

		fixDef.shape.SetAsOrientedBox(bodywidth / 2.0, bodyheight / 2.0 - (bodywidth / 4.0),
				new b2Vec2(0, -bodyheight / 2.0 + (bodywidth / 4.0)), 0)
		@head.CreateFixture(fixDef)

		rjd2 = new b2RevoluteJointDef
		rjd2.Initialize(@body, @head, @body.GetWorldCenter())
		rjd2.collideConnected = false
		world.CreateJoint(rjd2)

		@sensors =
			bl: new Game.Sensor(@game, new b2Vec2(-bodywidth * 0.5, -0.1), new b2Vec2(-bodywidth * 0.5, bodyheight * 0.5))
			br: new Game.Sensor(@game, new b2Vec2(bodywidth * 0.5, -0.1), new b2Vec2(bodywidth * 0.5, bodyheight * 0.5))
			sl: new Game.Sensor(@game, new b2Vec2(-bodywidth * 0.3, -0.3), new b2Vec2(-bodywidth * 1.0, -0.3))
			sr: new Game.Sensor(@game, new b2Vec2(bodywidth * 0.3, -0.3), new b2Vec2(bodywidth * 1.0, -0.3))

		@states =
			ground: new GroundState(this)
			air: new AirState(this)
			jump: new JumpState(this)
			wallride: new WallrideState(this)
			walljump: new WalljumpState(this)

		this.setState('air')

		@controller = new Game.PlayerController(game)

		console.log "player is here!  i have body", @body 

		this
	update: (elapsed) ->
		if @currentState != null
			@currentState.setupSensors()
		
		sensorstate = ""
		for k, s of @sensors
			s.sense(@head)
			sensorstate += 'k: ' + k + ' v: ' + s.result + '<br />'
		$("pre#log").html(sensorstate)
		if @currentState != null
			this.setState(@currentState.execute(elapsed))

		@controller.update(elapsed)
	draw: (ctx) ->
		this
	setState: (statename) ->
		if statename == null or statename == @currentStateName
			return
		if @currentState != null
			@currentState.exit()
		@currentState = @states[statename]
		@currentStateName = statename
		@currentState.enter()