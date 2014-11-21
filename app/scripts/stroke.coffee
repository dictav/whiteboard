class window.Stroke
  @table = null
  @allStrokes = []
  @drawingStroke = null
  @default =
    width: 8
    color: "rgba(0,0,0,0.5)"


  @create: (path)->
    data =
      width: Stroke.default.width
      color: Stroke.default.color
      data: JSON.stringify [path]
    stroke = new Stroke(data)
    Stroke.allStrokes.push stroke
    console.log 'create stroke', stroke
    stroke

  @refresh: ->
    @allStrokes = []
    canvas = $('canvas')[0]
    c = canvas.getContext('2d')
    c.save()
    c.setTransform(1, 0, 0, 1, 0, 0)
    c.clearRect(0, 0, canvas.width, canvas.height)
    c.restore()

    condition = -> this.data != ""
    query = Stroke.table.where(condition).read().then (strokes)->
      console.log 'strokes',strokes
      Stroke.allStrokes.push(new Stroke(stroke)) for stroke in strokes

  constructor: (@stroke)->
    @paths = JSON.parse @stroke.data
    @paths.last = ->
      this[this.length-1]
    @context = $('canvas')[0].getContext('2d')
    @context.strokeStyle = @stroke.color
    @context.lineWidth = @stroke.width
    @build()

  build: ->
    @context.beginPath()
    for path,i in @paths
      if i == 0
        @context.moveTo(path.x, path.y)
      else
        @context.lineTo(path.x, path.y)
    @context.stroke()
    @context.closePath()

  addPath: (path)->
    x = path.x
    y = path.y
    if (@paths.last().x - x)**2 + (@paths.last().y - y)**2 < 300
      return
    @context.beginPath()
    @context.moveTo(@paths.last().x, @paths.last().y)
    @context.lineTo(x, y)
    @context.stroke()
    @context.closePath()
    @paths.push path

  save: ->
    Stroke.drawingStroke = null
    @insert()

  insert: ->
    data =
      width: @stroke.width,
      color: @stroke.color,
      data: JSON.stringify(@paths)
    console.log 'insert stroke', data
    Stroke.table.insert(data)
      .then (stroke)=>
        @stroke.id = stroke.id
        console.log 'inserted stroke', stroke
      , handleError

  update: (data)->
    data.id = @stroke.id
    Stroke.table.update(data)
      .then (data)->
        console.log 'update stroke', data
      , window.handleError

  delete: ->
    console.log 'delete stroke'
    Stroke.table.del({id: @stroke.id})
      .then ->
        console.log 'deleted stroke'
      , window.handleError

