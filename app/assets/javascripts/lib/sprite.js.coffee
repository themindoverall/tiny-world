class Game.Sprite
	constructor: (@image) ->
		@animations = {}
		@frames = []
		@imageFlipped = document.createElement('CANVAS')
		@imageFlipped.width = @image.width
		@imageFlipped.height = @image.height
		ctx = @imageFlipped.getContext('2d')
		ctx.save()
		ctx.scale(-1, 1)
		ctx.drawImage(@image, -64, 0)
		ctx.restore()
	autoframe: (w, h) ->
		framesX = @image.width / w
		framesY = @image.height / h
		for y in [0..framesY - 1]
			for x in [0..framesX - 1]
				@frames.push({x: x * w, y: y * h, w: w, h: h})
	setAnimations: (anims) ->
		@animations = anims
	addAnimation: (name, anim) ->
		@animations[name] = anim
	draw: (ctx, animname, time, x, y, flipX) ->
		anim = @animations[animname]
		time %= anim.duration
		animindex = Math.floor((time / anim.duration) * anim.sequence.length)
		frame = @frames[anim.sequence[animindex]]
		if flipX
			img = @imageFlipped
			fx = @image.width - frame.x - frame.w
			fy = frame.y
		else
			img = @image
			fx = frame.x
			fy = frame.y

		ctx.drawImage(img, fx, fy, frame.w, frame.h, x - frame.w * 0.5, y - frame.h * 0.5, frame.w, frame.h)