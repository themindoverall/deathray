#= require ./box
#= require ./fonts

class Game.UI.DialogueBox extends Game.UI.Box
  @ALIGN:
    LEFT: 0
    RIGHT: 1
    CENTER: 2
  constructor: (text) ->
    @border = jaws.assets.get('dialogborder.png')
    @align = DialogueBox.ALIGN.LEFT
    @maxSize = [@border.width, @border.height]
    this._loadStyles()
    this.setText(text)
  draw: (rect, ctx) ->
    x = rect.x
    y = rect.y
    ctx.drawImage(@border, x, y)
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
            y += 20
          for i in [0..w.length-1]
            c = w.charCodeAt(i)
            if c is 10
              x = ox
              y += 20
            if c isnt 10
              x += @styles[stack[0]].drawChar(ctx, c, x, y)

  setText: (text) ->
    @text = text
    @compiled = this._compileText(text)
  _loadStyles: () ->
    @styles =
      default: new Game.UI.Font('fonts/museoslab500.font.png', '#fff', 1)
      header: new Game.UI.Font('fonts/museoslab700.font.png', '#ddd', 2)
      em: new Game.UI.Font('fonts/museoslab900.font.png', '#fff', 2)
      place: new Game.UI.Font('fonts/museoslab700.font.png', '#0f0', 2)
      item: new Game.UI.Font('fonts/museoslab700.font.png', '#f00', 2)
      person: new Game.UI.Font('fonts/museoslab700.font.png', '#f0f', 2)
  _compileText: (text) ->
    result = []
    # read each char
    # on \, skip next character
    # on [ read a change onto the stack
    # on [/s] pop it off the stack
    return [{style: 'header'}, 'ELLIE GOULDING\n', {pop:true}, 'Why don\'t you be the writer and ', {style: 'em'}, 'decide', {pop: true}, ' the words I say?  Cuz I\'d rather ',{style: 'em'},'pretend',{pop:true},' I\'ll still be there in the end.']
