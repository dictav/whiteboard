class Stroke
  @table = null
  @insertNewStroke: (paths)->
    console.log 'paths', paths
    console.log 'insert path'
    drawing = false
    table.insert
      width: lineWidth,
      color: lineColor,
      data: JSON.stringify(data)
    .then ->
      console.log 'path was inserted'
    , handleError
  @refresh: ->
    condition = -> this.data != ""

    query = Note.table.where(condition).read().then (strokes)->
      context = $('canvas')[0].getContext('2d')
        for stroke in strokes 
          context.strokeStyle = stroke.color
          context.lineWidth = stroke.width
          paths = JSON.parse stroke.data
          fpath = paths.shift
          context.beginPath()
          context.moveTo(fpath.x, fpath.y)
          for path in paths
            context.lineTo(path.x, path.y)
            context.stroke()
          context.closePath()

  constructor: (@stroke)->
    @paths = @stroke.paths
    @paths.last = ->
      this[this.length-1]

    ctxt = $('canvas').getContext('2d')
    @build()

  build: ->

  draw: (context, x, y)->
    context.strokeStyle = lineColor
    context.lineWidth = lineWidth
    context.beginPath()
    context.moveTo(@paths.last().x, @aths.last().y)
    context.lineTo(x, y)
    context.stroke()
    context.closePath()

  update: (data)->
    data.id = @stroke.id
    Note.table.update(data)
      .then( (data)->
        console.log data
      , window.handleError)
