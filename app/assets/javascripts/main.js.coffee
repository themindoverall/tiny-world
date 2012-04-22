#= require_tree ./lib
#= require_tree ./game

Futures = require('futures')

window.$ = jQuery

v = cp.v

class TinyGame
	constructor: (@canvas) ->
		@fps = 30

		@started = false

		@debug = $('canvas#debug').get(0)
		@debug_ctx = @debug.getContext('2d')

		@ctx = @canvas.getContext('2d')
		@ctx.translate 400, 250

		@content = new Game.ContentManager()

		@content.root = '/assets/'

		@space = new cp.Space();

		@space.iterations = 12
		@gravity = v(0, 28)
		@space.sleepTimeThreshold = 0.5
		
		@remainder = 0;
		@objects = []
		this.loadContent('level.json').when =>
			started = true
			for obj in @objects
				obj.start()
			this.run()	
			console.log("DOING THIS")
	update: (delta) ->
		elapsed = delta * 0.001
		for obj in @objects
			obj.update(elapsed)

		#@debugDraw.m_ctx.translate(400, 250)
		
		@remainder += elapsed
		while @remainder > 1/60
			@remainder -= 1/60
			@space.step(1/60)
	draw: ->
		@debug.width = @debug.width
		@drawDebug(@debug_ctx)
		#@debugDraw.m_ctx.translate(400, 250)
		#@world.DrawDebugData()
	point2canvas: (p) =>
		return v(400 + p.x * Game.PTM_RATIO, 250 + p.y * Game.PTM_RATIO)
	drawDebug: (ctx) =>
		@space.eachShape (shape) =>
			ctx.fillStyle = shape.style()
			shape.draw(ctx, Game.PTM_RATIO, @point2canvas)
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
				this.update(delta)
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
			this.draw()
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