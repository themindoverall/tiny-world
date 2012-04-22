v = cp.v

i = 0
class Game.Sensor
	constructor: (@game, @from, @to) ->
		@enabled = true
	sense: (body) ->
		if !@enabled
			@result = false
			return

		@fromwp = v.add(@from, body.p)
		@towp = v.add(@to, body.p)
		@result = false

		@result = @game.space.segmentQueryFirst(@fromwp, @towp, 0b10)
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

