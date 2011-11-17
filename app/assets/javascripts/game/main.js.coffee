#=require ./ui/dialogue-box

DIRECTIONS =
  none: 0
  up: 1
  down: 2
  left: 4
  right: 8
  up_left: 5
  up_right: 9
  down_left: 6
  down_right: 10


window.Example = ->
  player = undefined
  blocks = undefined
  fps = undefined
  width = 32
  height = 32
  tile_map = undefined
  viewport = undefined
  md = undefined
  initialmouse = undefined
  lastmouse = undefined
  dialog = undefined

  @setup = ->
    fps = document.getElementById("fps")
    blocks = new jaws.SpriteList()
    i = 0

    while i < width
      i2 = 0

      while i2 < height
        blocks.push new Sprite(
          image: "grass.png"
          x: i * 32
          y: i2 * 32
        )
        i2++
      i++
    viewport = new jaws.Viewport(
      max_x: width * 32
      max_y: height * 32
    )
    tile_map = new jaws.TileMap(
      size: [ width, height ]
      cell_size: [ 32, 32 ]
    )
    tile_map.push blocks
    player = new jaws.Sprite(
      x: 10
      y: 10
      anchor: "bottom_center"
    )
    anim = new jaws.Animation(
      sprite_sheet: "char.png"
      frame_size: [ 32, 32 ]
      frame_duration: 200
      orientation: 'right'
    )

    cut = (anim, frames) ->
      new jaws.Animation(
        frame_duration: anim.frame_duration
        loop: anim.loop
        bounce: anim.bounce
        on_end: anim.on_end
        frame_direction: anim.frame_direction
        frames: (anim.frames[i] for i in frames)
      )
    
    player.standing = {}
    player.standing[DIRECTIONS.up] = cut(anim, [37])
    player.standing[DIRECTIONS.down] = cut(anim, [1])
    player.standing[DIRECTIONS.left] = cut(anim, [13])
    player.standing[DIRECTIONS.right] = cut(anim, [25])
    player.standing[DIRECTIONS.up_left] = cut(anim, [31])
    player.standing[DIRECTIONS.down_left] = cut(anim, [19])
    player.standing[DIRECTIONS.up_right] = cut(anim, [43])
    player.standing[DIRECTIONS.down_right] = cut(anim, [7])
    player.walking = {}
    player.walking[DIRECTIONS.up] = cut(anim, [36,37,38,37])
    player.walking[DIRECTIONS.down] = cut(anim, [0,1,2,1])
    player.walking[DIRECTIONS.left] = cut(anim, [12,13,14,13])
    player.walking[DIRECTIONS.right] = cut(anim, [24,25,26,25])
    player.walking[DIRECTIONS.up_left] = cut(anim, [30,31,32,31])
    player.walking[DIRECTIONS.down_left] = cut(anim, [18,19,20,19])
    player.walking[DIRECTIONS.up_right] = cut(anim, [42,43,44,43])
    player.walking[DIRECTIONS.down_right] = cut(anim, [6,7,8,7])
    player.setImage player.standing[DIRECTIONS.down].next()
    jaws.preventDefaultKeys [ "w", "s", "a", "d", "space" ]

    dialog = new Game.UI.DialogueBox('<s class="header">SAGELY OWL\n</s>Who is our <s class="idea">champion</s> who will face down the <s class="enemy">Evil Lord Anthem</s>? <i src="icons/a.png">(A)</i>')
    
    getMousePos = (e) =>
      mx = e.pageX - jaws.canvas.offsetLeft
      my = e.pageY - jaws.canvas.offsetTop

      return {mx: mx, my: my, moved: false, hide: false}

    md = false
    $(jaws.canvas).mousedown((e) =>
      m = getMousePos(e)
      lastmouse = m
      initialmouse = m
      md = true
    )

    $(jaws.canvas).mousemove((e) =>
      m = getMousePos(e)
      if md
        diffx = m.mx - initialmouse.mx
        diffy = m.my - initialmouse.my
        if Math.sqrt(diffx * diffx + diffy * diffy) > 5
          m.moved = true
        viewport.move(m.mx - lastmouse.mx)
        viewport.move(m.my - lastmouse.my)
      lastmouse = m
    )

    $(jaws.canvas).mouseup((e) =>
      if not lastmouse.moved
        console.log('touched box ')
      md = false
    )

    $(jaws.canvas).mouseleave((e) =>
      lastmouse.hide = true
    )

  @update = ->
    elapsed = jaws.game_loop.tick_duration * 0.001
    speed = 50

    target = {x: 0, y: 0}
    dir = DIRECTIONS.down
    if lastmouse?
      target = {
        x: lastmouse.mx - jaws.width * 0.5,
        y: lastmouse.my - jaws.height * 0.5
      }
      tmag = Math.sqrt(target.x * target.x + target.y * target.y)
      if tmag > (jaws.height * 0.5 - 16)
        target.x = Math.round((target.x / tmag) * (jaws.height * 0.5 - 16))
        target.y = Math.round((target.y / tmag) * (jaws.height * 0.5 - 16))
      angle = Math.floor(0.5 + (1 + Math.atan2(target.y, target.x) / (Math.PI)) * 4)
      dir = switch angle
        when 0, 8
          DIRECTIONS.left
        when 1
          DIRECTIONS.up_left
        when 2
          DIRECTIONS.up
        when 3
          DIRECTIONS.up_right
        when 4
          DIRECTIONS.right
        when 5
          DIRECTIONS.down_right
        when 6
          DIRECTIONS.down
        when 7
          DIRECTIONS.down_left

    walking = false
    if jaws.pressed("a")
      player.move -speed * elapsed, 0
      walking = true
    if jaws.pressed("d")
      player.move speed * elapsed, 0
      walking = true
    if jaws.pressed("w")
      player.move 0, -speed * elapsed
      walking = true
    if jaws.pressed("s")
      player.move 0, speed * elapsed
      walking = true

    if walking
      player.setImage player.walking[dir].next()
    else
      player.setImage player.standing[dir].next()
    viewport.centerAround {x: Math.round(player.x + target.x), y: Math.round(player.y + target.y)}
    fps.innerHTML = jaws.game_loop.fps + ". player: " + player.x.toFixed(1) + "/" + player.y.toFixed(1)

  @draw = ->
    jaws.clear()
    viewport.drawTileMap tile_map
    kx = player.x
    ky = player.y
    player.x = Math.round(kx)
    player.y = Math.round(ky)
    viewport.draw player
    player.x = kx
    player.y = ky
    jaws.context.drawImage(jaws.assets.get('overlay.png'), 0, 0)
    dialog.draw({x: jaws.width * 0.5 - 160, y:jaws.height - 100 - 10, width: 320, height: 100}, jaws.context)

  this

