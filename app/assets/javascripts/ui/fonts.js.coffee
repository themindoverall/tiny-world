if window?
  window.Game ||= {}
  Game = window.Game
  Game.UI = {} unless Game.UI

Futures = require('futures')

class Game.UI.Font
  load: (content, @name, @color, @spacing) ->
    future = Futures.future()
    content.loadImage(@name).when (err, image) =>
      @image = image

      @firstChar = 32

      this._loadMetrics(@image)

      if @color isnt '#fff'
        canvas = document.createElement('canvas')
        canvas.width = @image.width
        canvas.height = @image.height
        ctx = canvas.getContext('2d')
        ctx.drawImage(@image, 0, 0)
        ctx.globalCompositeOperation = 'source-in'
        ctx.fillStyle = @color
        ctx.fillRect(0, 0, @image.width, @image.height)
        @image = canvas
      future.fulfill()
    future

  widthForString: (s) ->
    width = 0
    for i in [0..s.length-1]
      width += @widthMap[s.charCodeAt(i) - @firstChar] - 4 + @spacing
    return width

  drawChar: (ctx, c, targetX, targetY) ->
    c -= @firstChar
    if c < 0 || c >= @indices.length
      return 0
    
    scale = 1 #ig.system.scale

    charX = @indices[c]
    charY = 0;
    charWidth = @widthMap[c]
    charHeight = (@height-1)
    
    ctx.drawImage( 
      @image,
      charX, charY,
      charWidth, charHeight,
      targetX, targetY,
      charWidth, charHeight
    )
    
    return @widthMap[c] - 4 + @spacing

  _loadMetrics: (image) ->
    @widthMap = []
    @indices = []
    @height = image.height - 1
    
    canvas = document.createElement('canvas')
    canvas.width = image.width
    canvas.height = image.height
    ctx = canvas.getContext('2d')
    ctx.drawImage( image, 0, 0 )
    px = ctx.getImageData(0, image.height-1, image.width, 1)

    currentChar = 0
    currentWidth = 0
    for x in [0..image.width-1]
      index = x * 4 + 3
      if px.data[index] != 0
        currentWidth++
      else if px.data[index] == 0 && currentWidth isnt 0
        @widthMap.push(currentWidth)
        @indices.push(x - currentWidth)
        currentChar++
        currentWidth = 0

    @widthMap.push(currentWidth)
    @indices.push(x - currentWidth)
