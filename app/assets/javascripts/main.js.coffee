#= require player
#= require mesh
#= require spawn

class Game
	constructor: (@canvas) ->
		@ctx = @canvas.getContext('2d')
		@ctx.translate 190, -260
		that = this
		$.get '/assets/level.json', (data) =>
			bounds = data.bounds
			for y in [bounds[0]..bounds[2]]
				for x in [bounds[1]..bounds[3]]
					img = new Image()
					img.src = "/assets/level_#{x}x#{y}.png"
					img.p = {x: x, y: y}
					img.onload = ->
						that.ctx.drawImage(this, 512*this.p.x, 512*this.p.y)
						console.log 'placing at:', this.p
					console.log 'bounds:', x, y

$ ->
	canvas = document.getElementById('game')
	game = new Game(canvas)