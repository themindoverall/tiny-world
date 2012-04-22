class Game.Sensor
	constructor: (@game, @from, @to) ->
		@enabled = true
	sense: (body) ->
		if !@enabled
			@result = false
			return

		@fromwp = body.GetWorldPoint(@from)
		@towp = body.GetWorldPoint(@to)
		@result = false

		@game.world.RayCast(this.collect, @fromwp, @towp)
	collect: (fixture, point, normal, fraction) =>
			@touch_point = point
			@result = true
			return 0
	debugDraw: (debDraw) ->
		if !@enabled
			return
		c = b2Color(1, 0, 0)
		if @result
			c = b2Color(0, 1, 0)
			debDraw.DrawPoint(@touch_point, 3.0)

		debDraw.DrawSegment(@fromwp, @towp)

