# application coffeescript goes here

class Thing
  constructor: ({ el, @x, @y }) ->
    @el = $ el
    @width = @el.width()
    @height = @el.height()

  tick: ->
    @update()

  update: ->
    @el.css
      top: @y
      left: @x


class Guy extends Thing
  constructor: ->
    super
    @x_acc = 0
    @y_acc = 0

  tick: (@objects) ->
    @blocked = no
    for object in objects
      continue if object.y < @y
      continue if object.y > @y + @y_acc
      continue if object.x > @x + @width / 2
      continue if object.x + object.width < @x - @width / 2
      @y = object.y
      @blocked = yes
    @x += @x_acc
    if @blocked
      @y_acc = 0
    else
      @y += @y_acc
    super
    @y_acc++

  canJump: -> @blocked

  jump: ->
    @y_acc = -20 if @canJump()


class Platform extends Thing
  constructor: (args) ->
    if args.el
      super args
    else
      args.el = $ '<div class="platform">'
      args.el.appendTo 'body'
      super args



class Enemy extends Guy
  constructor: (args) ->
    args.el = $ '<div class="enemy">'
    args.el.appendTo 'body'
    for supporting_element in ['head', 'body', 'legs front', 'legs back']
      args.el.append "<div class='#{supporting_element}'>"
    super args

  tick: ->
    super
    @jump()


class Hero extends Guy
  constructor: ->
    super
    @max_x_acc = 20
    new BindKeyEvents @



  update: ->
    super
    if @x_acc isnt 0 or @y_acc isnt 0
      @el.addClass 'walking'
    else
      @el.removeClass 'walking'
    if @x_acc < 0
      @el.addClass 'left'
    else if @x_acc > 0
      @el.removeClass 'left'


class SquareHipster
  constructor: ->
    @num_platforms = 5
    @objects = []
    @hero = new Hero el: '#hero', x: 170, y: 100
    @enemy = new Enemy x: 200, y: 10
    @enemy.x_acc = 1

    for column in [1..@num_platforms]
      @generate_platform(column)

    @add_platform new Platform el: '.platform.ground', x: 0, y: innerHeight - 50
    @add_platform (new Platform {x: 100, y: 567})
    @tick()

  add_platform: (platform) ->
    @objects.push platform

  generate_platform: (column) ->
    column_width = 200
    floor = innerHeight
    x = (column * column_width) + Math.floor(Math.random() * column_width)
    y = floor - Math.floor(Math.random() * 400)
    coords = {x: x, y: y}
    @add_platform (new Platform coords)

  tick: =>
    @hero.tick @objects 
    @enemy.tick @objects
    for object in @objects
      object.tick()
    requestAnimationFrame @tick

class BindKeyEvents
  constructor: (@hero) ->
    Mousetrap.bind 'left', () =>
      @hero.x_acc = -5
    Mousetrap.bind 'right', () =>
      @hero.x_acc = 5
    Mousetrap.bind ['left', 'right'], () =>
      @hero.x_acc = 0
    , 'keyup'
    Mousetrap.bind 'space', () =>
      @hero.jump()


new SquareHipster

