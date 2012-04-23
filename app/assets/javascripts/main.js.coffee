#= require_tree ./lib
#= require_tree ./ui
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

		@ui = $('canvas#ui').get(0)
		@ui_ctx = @ui.getContext('2d')

		@dialog = new Game.UI.DialogueBox('<s class="header">SAGELY OWL\n</s>Who is our <s class="idea">champion</s> who will face down the <s class="enemy">Evil Lord Anthem</s>?')

		@content = new Game.ContentManager()

		@content.root = '/assets/'

		@dialog.loadContent(@content)

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

		removers = []
		for obj in @objects
			obj.update(elapsed)
			if obj.dead
				removers.push(obj)

		if removers.length
			console.log removers
		for obj in removers
			obj.unload()
			@objects.splice(@objects.indexOf(obj), 1)

		#@debugDraw.m_ctx.translate(400, 250)
		
		@remainder += elapsed
		while @remainder > 1/60
			@remainder -= 1/60
			@space.step(1/60)
	draw: ->
		@canvas.width = @canvas.width
		this.drawGame(@ctx)
		#@debug.width = @debug.width
		#this.drawDebug(@debug_ctx)
		@ui.width = @ui.width
		this.drawUI(@ui_ctx)
		#@debugDraw.m_ctx.translate(400, 250)
		#@world.DrawDebugData()
	offset: () ->
		x: -window.player.body.p.x * Game.PTM_RATIO + @canvas.width * 0.5
		y: -window.player.body.p.y * Game.PTM_RATIO + @canvas.height * 0.5
	drawGame: (ctx) ->
		offset = this.offset()
		@ctx.translate offset.x, offset.y

		for obj in @objects
			obj.draw(ctx)
	point2canvas: (p) =>
		offset = this.offset()
		return v(offset.x + p.x * Game.PTM_RATIO, offset.y + p.y * Game.PTM_RATIO)
	drawDebug: (ctx) =>
		@space.eachShape (shape) =>
			ctx.fillStyle = shape.style()
			shape.draw(ctx, Game.PTM_RATIO, @point2canvas)
	drawUI: (ctx) ->
		@dialog.draw({x: 10, y: 10, width: 320, height: 100}, ctx)
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
		obj.loadContent(@content).when ->
			if @started
				obj.start()

	loadContent: (name) ->
		future = Futures.future()
		@content.loadData(name).when (err, data) =>
			tm = new Game.Tilemap()
			tm.initialize(this, data)
			@objects.push(tm)

			for name, obj of data.objects
				clazz = Game[obj.dataType]
				if clazz?
					o = new clazz()
					o.initialize(this, obj)
					@objects.push(o)
			console.log('objects are ', @objects)
			join = Futures.join()
			for obj in @objects
				join.add obj.loadContent(@content)
			join.when ->
				future.fulfill()
		future

jQuery ->
	canvas = document.getElementById('game')
	game = new TinyGame(canvas)