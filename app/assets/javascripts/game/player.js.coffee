#= require ./player_controller
#= require ./player_anim

Futures = require('futures')

v = cp.v
v.zero = v(0,0)

class PlatformerState
	constructor: (@owner) ->
	enter: () ->
		this
	execute: (elapsed) ->
		null
	exit: () ->
		this
	setupSensors: () ->
		lx = @owner.body.vx

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
		#@owner.motor.EnableMotor(true)
		@owner.sensors["bl"].enabled = true
		@owner.sensors["br"].enabled = true
		@moving = false

		@owner.setAnim('stand')
	exit: () ->
		#@owner.motor.EnableMotor(false)
		@owner.sensors["bl"].enabled = false
		@owner.sensors["br"].enabled = false
	execute: (elapsed) ->
		preventmoving = false
		nowmoving = false

		if @owner.controller.movement < 0
			preventmoving = @owner.sensors["sl"].result
			@owner.flipX = true
		else if @owner.controller.movement > 0
			preventmoving = @owner.sensors["sr"].result
			@owner.flipX = false

		if preventmoving
			if @owner.motor.rate != 0
				@owner.motor.rate = 0

		else if Math.abs((@owner.controller.movement * 10.0) - @owner.motor.rate) > 0.1
			@owner.motor.rate = @owner.controller.movement * @owner.RUN_SPEED
			nowmoving = true

		if nowmoving and !@moving
			@owner.setAnim('walk')
		else if !nowmoving and @moving
			@owner.setAnim('stand')

		@moving = nowmoving

		if @owner.controller.jump == 'jp'
			@owner.body.vy = 0
			@owner.body.applyImpulse(v(0, -@owner.JUMP_SPEED), @owner.center)
			return "jump"

		if !(@owner.sensors["bl"].result or @owner.sensors["br"].result)
			return "air"

		return null

class JumpState extends PlatformerState
	enter: () ->
		@jumpTimer = @owner.JUMP_BONUS
		@owner.setAnim('jump')
	exit: () ->
		@owner.bshape.layers |= 0b100
	execute: (elapsed) ->
		if @owner.body.vy > 0
			@owner.bshape.layers |= 0b100
		else
			@owner.bshape.layers &= ~0b100

		lv = @owner.body.vx
		if @owner.controller.movement != 0
			pow = 0
			if (lv / @owner.controller.movement) < 0
				pow = @owner.AIR_AGILITY
			else if Math.abs(lv) < @owner.MAX_AIR_SPEED
				pow = @owner.AIR_SPEED

			@owner.body.applyForce(v(pow * @owner.controller.movement, 0), @owner.center)

			if @owner.controller.movement > 0
				@owner.flipX = false
			else
				@owner.flipX = true

		@jumpTimer -= elapsed
		
		if @jumpTimer > 0
			if @owner.controller.jump != 'up'
				@owner.body.applyForce(v(0, -@owner.JUMP_SPEED), @owner.center)
			else
				@jumpTimer = 0

		if @owner.body.vy > 0
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
		@owner.setAnim('fall')

	exit: () ->
		@owner.sensors['bl'].enabled = false
		@owner.sensors['br'].enabled = false

		@owner.bshape.layers |= 0b100

	execute: (elapsed) ->
		if @owner.body.vy > 0
			@owner.bshape.layers |= 0b100
		else
			@owner.bshape.layers &= ~0b100

		lv = @owner.body.vx
		if @owner.controller.movement != 0
			pow = 0
			if (lv / @owner.controller.movement) < 0
				pow = @owner.AIR_AGILITY
			else if Math.abs(lv) < @owner.MAX_AIR_SPEED
				pow = @owner.AIR_SPEED

			@owner.body.applyForce(v(pow * @owner.controller.movement, 0), @owner.center)

			if @owner.controller.movement > 0
				@owner.flipX = false
			else
				@owner.flipX = true
		else if lv != 0
			lin = lv / Math.abs(lv)
			@owner.body.applyForce(v(lv * -@owner.AIR_DRAG, 0), @owner.center)

		if lv != 0 and Math.abs(lv) > @owner.MAX_AIR_SPEED
			@owner.body.vx = (lv / Math.abs(lv)) * @owner.MAX_AIR_SPEED

		if @owner.body.vy > @owner.MAX_FALL_SPEED
			@owner.body.vy = @owner.MAX_FALL_SPEED
		
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
			@owner.flipX = true
			@side = -1
		else
			@owner.sensors['sl'].enabled = false
			@owner.sensors['sr'].enabled = true
			@owner.flipX = false
			@side = 1

		@owner.setAnim('wallride')

		@owner.ignoreGravity = true

	exit: () ->
		@owner.sensors['sl'].enabled = false
		@owner.sensors['sr'].enabled = false
		@owner.ignoreGravity = false

	execute: (elapsed) ->
		@owner.body.vy = @owner.WALL_SKID

		if (@owner.controller.movement / @side) <= 0
			@wallTimer += elapsed
		else
			@wallTimer = 0

		if @owner.controller.jump == 'jp'
			return 'walljump'

		if @wallTimer > @owner.WALL_JUMP_WINDOW or (!@owner.sensors['sl'].result and !@owner.sensors['sr'].result)
			return 'air'

		if @owner.sensors['bl'].result or @owner.sensors['br'].result
			return 'ground'

		return null

class WalljumpState extends PlatformerState
	setupSensors: () ->
		lx = @owner.body.vx

		if lx > 0 and @owner.controller.movement > 0
			@owner.sensors["sr"].enabled = true
		else
			@owner.sensors["sr"].enabled = false

		if lx < 0 and @owner.controller.movement < 0
			@owner.sensors["sl"].enabled = true
		else
			@owner.sensors["sl"].enabled = false
	enter: () ->
		if @owner.sensors['sl'].result
			@side = -1
			@owner.flipX = false
		else
			@side = 1
			@owner.flipX = true

		@owner.setAnim('jump')

		@owner.body.vx = 0
		@owner.body.vy = -1

		@owner.body.applyImpulse(v(@owner.JUMP_SPEED * @side * -0.5, -@owner.JUMP_SPEED), @owner.center)
		@jumpTimer = @owner.JUMP_BONUS
	exit: () ->
		@owner.bshape.layers |= 0b100
	execute: (elapsed) ->
		if @owner.body.vy > 0
			@owner.bshape.layers |= 0b100
		else
			@owner.bshape.layers &= ~0b100

		@jumpTimer -= elapsed
		if @jumpTimer > 0
			if @owner.controller.jump != 'up'
				@owner.body.applyForce(v(0, 0.85 * -@owner.JUMP_SPEED), @owner.center)
			else
				@jumpTimer = 0

		if @jumpTimer <= 0 and @owner.body.vy > 0
			return 'air'

		sides = (if @owner.sensors['sr'].result then 1 else 0) -
						(if @owner.sensors['sl'].result then 1 else 0)

		if sides != 0 and @owner.controller.movement != 0 and @owner.controller.movement / sides > 0
			return 'wallride'

		return null

class Game.Player extends Game.GameObject
	JUMP_BONUS: 0.6
	RUN_SPEED: 18.0
	JUMP_SPEED: 72.0
	AIR_SPEED: 100.0
	AIR_DRAG: 12.0
	AIR_AGILITY: 80.0
	MAX_AIR_SPEED: 10.0
	MAX_FALL_SPEED: 20.0
	WALL_SKID: 5.0
	WALL_JUMP_WINDOW: 0.6
	initialize: (game, data) ->
		super(game, data)

		game.player = this

		@currentState = null

		bodywidth = 12 / Game.PTM_RATIO
		bodyheight = 32 / Game.PTM_RATIO

		space = game.space

		@ignoreGravity = false

		@body = space.addBody(new cp.Body(5, cp.momentForCircle(5, 0, bodywidth * 0.5, v(0, 0))))
		console.log 'player at ', data.position
		pos = v(data.position[0], -data.position[1])
		@body.setPos(pos)
		
		@graviticForce = v(game.gravity.x * @body.m, game.gravity.y * @body.m)

		console.log('player body is ', @body)

		@bshape = space.addShape(new cp.CircleShape(@body, bodywidth * 0.5, v(0, 0)))
		@bshape.setFriction(7)
		@bshape.group = 1
		@bshape.layers = 0b11001

		# pivot = space.addBody(new cp.Body(0.0000001, Number.MAX_VALUE))

		#pivot.setPos(v.add(pos, v(0, bodywidth)))

		@motor = space.addConstraint(new cp.SimpleMotor(@body, space.staticBody, 0))

		@motor.maxForce = 10000

		#@head = space.addBody(new cp.Body(0.01, Number.MAX_VALUE))
		#@head.setPos(v(pos.x, pos.y))

		###shape = space.addShape(new cp.BoxShape2(@head, {
			l: -bodywidth * 0.5
			r: bodywidth * 0.5
			t: 0
			b: -(bodyheight - (bodywidth * 0.25))
		}))
		shape.group = 1

		space.addConstraint(new cp.PinJoint(@body, @head, v(0, 0), v(0, 0)))
		###
		@sensors =
			bl: new Game.Sensor(@game, v(-bodywidth * 0.3, -0.1), v(-bodywidth * 0.3, bodyheight * 0.75))
			br: new Game.Sensor(@game, v(bodywidth * 0.3, -0.1), v(bodywidth * 0.3, bodyheight * 0.75))
			sl: new Game.Sensor(@game, v(-bodywidth * 0.3, -0.3), v(-bodywidth * 1.0, -0.3))
			sr: new Game.Sensor(@game, v(bodywidth * 0.3, -0.3), v(bodywidth * 1.0, -0.3))

		@states =
			ground: new GroundState(this)
			air: new AirState(this)
			jump: new JumpState(this)
			wallride: new WallrideState(this)
			walljump: new WalljumpState(this)

		this.setState('air')

		@controller = new Game.PlayerController(game)

		@anim = 'fall'
		@animTime = 0
		@flipX = false

		@statetimer = 0
		@statetimermax = 0.3

		console.log "player is here!  i have body", @body
	loadContent: (content) ->
		future = Futures.future()
		content.loadImage('viking.png').when (err, img) =>
			@image = img
			@sprite = new Game.Sprite(@image)
			@sprite.autoframe(16, 16)
			@sprite.setAnimations(Game.PlayerAnims)
			future.fulfill()
		future
	update: (elapsed) ->
		@body.resetForces()
		@center = @body.local2World(v.zero)
		unless @ignoreGravity
			@body.applyForce(@graviticForce, @center)

		if @currentState != null
			@currentState.setupSensors()
		
		@statetimer += elapsed

		sensorstate = "State: #{@currentStateName}<br />"
		sensorstate += "Jump: #{@anim}, #{@animTime}<br />"
		sensorstate += "V: #{@body.vx}, #{@body.vy}<br />"
		for k, s of @sensors
			s.sense(@body)
			sensorstate += 'k: ' + k + ' v: ' + s.result + '<br />'

		if @statetimer > @statetimermax
			$("pre#log").html(sensorstate)
			@statetimer = 0
		if @currentState != null
			this.setState(@currentState.execute(elapsed))

		@controller.update(elapsed)
		@animTime += elapsed
	draw: (ctx) ->
		if @image
			@sprite.draw(
				ctx,
				@anim,
				@animTime,
				@body.p.x * Game.PTM_RATIO - 3,
				@body.p.y * Game.PTM_RATIO - 3,
				@flipX,
				false
			)
	setState: (statename) ->
		if statename == null or statename == @currentStateName
			return
		if @currentState != null
			@currentState.exit()
		@currentState = @states[statename]
		@currentStateName = statename
		@currentState.enter()
	setAnim: (anim) ->
		@anim = anim
		@animTime = 0