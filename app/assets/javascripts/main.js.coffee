#= require_tree ./lib
#= require_tree ./game

Futures = require('futures')

window.$ = jQuery

b2World = Box2D.Dynamics.b2World
b2Vec2 = Box2D.Common.Math.b2Vec2
b2DebugDraw = Box2D.Dynamics.b2DebugDraw


#b2World.m_continuous_physics = false
Box2D.Dynamics.b2Body.prototype.ApplyForceToCenter = (force) ->
	this.ApplyForce(force, this.GetWorldCenter())

class TinyGame
	constructor: (@canvas) ->
		@fps = 60

		@debugDraw = new b2DebugDraw

		@debug = $("canvas#debug").get(0)
		@debugDraw.SetSprite(@debug.getContext("2d"))
		@debugDraw.SetDrawScale(16.0)
		@debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
		@debugDraw.SetFillAlpha(0.5);

		@started = false

		@ctx = @canvas.getContext('2d')
		@ctx.translate 400, 250

		@content = new Game.ContentManager()

		@content.root = '/assets/'

		@world = new b2World(new b2Vec2(0, 15), true)

		@world.SetDebugDraw(@debugDraw)

		@objects = []
		this.loadContent('level.json').when =>
			started = true
			for obj in @objects
				obj.start()
			this.run()	
			console.log("DOING THIS")
	update: ->
		for obj in @objects
			obj.update(1/60)

		#@debugDraw.m_ctx.translate(400, 250)
		
		@world.Step(1.0 / 60, 10, 10)
		@world.ClearForces()
	draw: ->
		@debug.width = @debug.width
		@debugDraw.m_ctx.translate(400, 250)
		@world.DrawDebugData()
	run: ->
		loops = 0
		skipTicks = 1000 / @fps
		maxFrameSkip = 10
		nextGameTick = (new Date).getTime()
		lastTime = (new Date).getTime()
		lastFrameTime = (new Date).getTime()
		frames = 1
		mainloop = () =>
			now = (new Date).getTime()
			while (now > nextGameTick)
				delta = now - lastTime
				@update(delta)
				nextGameTick += skipTicks
				loops++
				lastTime = now
				now = (new Date).getTime()
        
			elapsed = ((new Date).getTime() - lastFrameTime) / 1000
			if elapsed > 0.5
				@realfps = frames / elapsed
				frames = 0
				lastFrameTime = (new Date).getTime()

			frames++
			@draw()
		recursiveAnim = () ->
			mainloop()
			window.requestAnimFrame(recursiveAnim, @canvas)
		recursiveAnim()
	add: (obj, data) ->
		obj.initialize(this, data)
		@objects.push(obj)
		obj.loadContent().when ->
			if @started
				obj.start()

	loadContent: (name) ->
		future = Futures.future()
		@content.loadData(name).when (err, data) =>
			bounds = data.bounds
			h = bounds[3] - bounds[1]
			for y in [bounds[1]..bounds[3]]
				for x in [bounds[0]..bounds[2]]
					do (x, y) =>
						name = "level_#{x}x#{y}.png"

						@content.loadImage(name).when (err, img) =>
							@ctx.drawImage(img, 512*x, 512*-(y + 1))

			for name, obj of data.objects
				clazz = Game[obj.dataType]
				if clazz?
					o = new clazz()
					o.initialize(this, obj)
					@objects.push(o)
			console.log('objects are ', @objects)
			join = Futures.join()
			for obj in @objects
				join.add obj.loadContent()
			join.when ->
				future.fulfill()
		future

jQuery ->
	canvas = document.getElementById('game')
	game = new TinyGame(canvas)