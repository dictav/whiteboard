noteColor = "red"
lineColor = "rgba(0,0,0,0.5)"
clicks = 0
timer  = null
drawing = false
beginX = 0
beginY = 0

listenActions = ->
  canvas = $('#canvas')
  canvas.attr('width', canvas.width())
  canvas.attr('height', canvas.height())
  canvas.on('click', (e)->
    if drawing
      drawing = false
      return
    console.log 'click', clicks
    clicks++

    if clicks == 1
      timer = setTimeout( ()->
        clicks = 0
        style =
          top: e.pageY,
          left: e.pageX,
          width: "100px",
          height: "100px",
          backgroundColor: noteColor
        insertNewItem("create a new note", JSON.stringify style)
      , 300)
    else
      clicks = 0
      drawing = true
      beginX = e.pageX
      beginY = e.pageY
      clearTimeout timer
  ).on('dblclick', (e)->
    e.preventDefault()
  )

  canvas.on('mousemove', (e)->
    return unless drawing
    context = this.getContext("2d")
    x = e.pageX
    y = e.pageY
    context.strokeStyle = lineColor
    context.lineWidth = 10
    context.beginPath()
    context.moveTo(beginX, beginY)
    context.lineTo(x, y)
    context.stroke()
    context.closePath()
    beginX = x
    beginY = y
  )
