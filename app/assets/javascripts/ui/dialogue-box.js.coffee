#= require ./box
#= require ./fonts

Futures = require('futures')

class Game.UI.DialogueBox extends Game.UI.Box
  @ALIGN:
    LEFT: 0
    RIGHT: 1
    CENTER: 2
  constructor: (text) ->
    @border =
      width: 600
      height: 120
    @align = DialogueBox.ALIGN.LEFT
    @maxSize = [@border.width, @border.height]
    @text = text
    @showTime = 0
    @loaded = false
  loadContent: (content) ->
    this._loadStyles(content).when =>
      this.setText(@text)
      @loaded = true
  draw: (rect, ctx) ->
    if @loaded and @showTime > 0
      if @showTime < 0.5
        ctx.globalAlpha = @showTime / 0.5
      ctx.drawImage(@cached, rect.x, rect.y, @border.width, @border.height)
      ctx.globalAlpha = 1.0
  update: (elapsed) ->
    if @showTime > 0
      @showTime -= elapsed
  drawBox: (rect, ctx) ->
    x = rect.x
    y = rect.y
    #ctx.drawImage(@border, x, y)
    ox = Math.floor(x) + 10
    oy = Math.floor(y) + 5
    x = ox
    y = oy

    """
        if @align is DialogueBox.ALIGN.RIGHT or @align is DialogueBox.ALIGN.CENTER
          width = 0
          for i in [0..@text.length-1]
            c = @text.charCodeAt(i)
            width += @widthMap[c - @firstChar] + 1
          x -= if @align is DialogueBox.ALIGN.RIGHT then width * 0.5 else width
    """
    stack = ['default']
    for bit in @compiled
      if bit.style?
        stack.unshift(bit.style)
      else if bit.pop?
        stack.shift()
      else
        words = bit.split(' ')
        f = true
        for w in words
          if f
            f = false
            if w is ''
              continue
          else
            w = ' ' + w
          wwidth = @styles[stack[0]].widthForString(w)
          if x - ox + wwidth > rect.width - (10 * 2)
            x = ox
            y += 24
          for i in [0..w.length-1]
            c = w.charCodeAt(i)
            if c is 10
              x = ox
              y += 24
            if c isnt 10
              x += @styles[stack[0]].drawChar(ctx, c, x, y)

  say: (text, time) ->
    this.setText(text)
    @showTime = time + 0.5
  setText: (text) ->
    @text = text
    @compiled = this._compileText(text)
    @cached = document.createElement('CANVAS')
    @cached.setAttribute('width', @border.width)
    @cached.setAttribute('height', @border.height)
    ctx = @cached.getContext('2d')
    this.drawBox({x: 0, y: 0, width: @border.width, height: @border.height}, ctx)
  _loadStyles: (content) ->
    join = Futures.join()
    @styles = { }
    @styles.default = new Game.UI.Font()
    join.add(@styles.default.load(content, 'wyther32white.font.png', '#fff', 2))
    @styles.header = new Game.UI.Font()
    join.add(@styles.header.load(content, 'wyther32white.font.png', '#bbb', 2))
    @styles.em = new Game.UI.Font()
    join.add(@styles.em.load(content, 'wyther32white.font.png', '#fff', 2))
    @styles.place = new Game.UI.Font()
    join.add(@styles.place.load(content, 'wyther32white.font.png', '#94ff90', 2))
    @styles.item = new Game.UI.Font()
    join.add(@styles.item.load(content, 'wyther32white.font.png', '#81cffa', 2))
    @styles.person = new Game.UI.Font()
    join.add(@styles.person.load(content, 'wyther32white.font.png', '#bf88ff', 2))
    @styles.idea = new Game.UI.Font()
    join.add(@styles.idea.load(content, 'wyther32white.font.png', '#fff38b', 2))
    @styles.enemy = new Game.UI.Font()
    join.add(@styles.enemy.load(content, 'wyther32white.font.png', '#ee878c', 2))
    @styles.event = new Game.UI.Font()
    join.add(@styles.event.load(content, 'wyther32white.font.png', '#ffa957', 2))
    join

  _compileText: (text) ->
    result = []
    $tree = $.parseXML('<text>' + text + '</text>')
    parsify = (nodes) ->
      $.each(nodes, (idx, ele) ->
        if ele.tagName?
          $node = $(this)
          if ele.tagName is 's'
            result.push({style: $node.attr('class')})
            parsify(ele.childNodes)
            result.push({pop:true})
        else
          result.push(ele.data)
      )
      1
    parsify($tree.childNodes[0].childNodes)
    return result
