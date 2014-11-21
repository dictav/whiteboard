todoItemTable = null
strokePathTable = null
editingNote = null
deletingNote = null

noteColor = "red"
noteWidth = "100px"
noteHeight = "100px"
lineColor = "rgba(0,0,0,0.5)"
lineWidth = 8
clickCount = 0
noteClickCount = 0
noteTimer  = null
noteEditing = false
drawing = false
strokePaths = []
strokePaths.last = ()->
  this[this.length-1]


timer = null

listenActions = ->
  canvas = $('#canvas')
  canvas.attr('width', canvas.width())
  canvas.attr('height', canvas.height())

  canvas.on 'click', (e)->
    if editingNote
      tarea = $('textarea', editingNote).first()
      editingNote.innerHTML = jQuery('<div>').text(tarea.val()).html()
      $(editingNote).width(tarea.width())
      $(editingNote).height(tarea.height())
      updateNote(editingNote)
      editingNote = null
      return

    if drawing
      insertNewPath(strokePaths)
      return

    clickCount++
    console.log 'click', clickCount

    if clickCount == 1
      timer = setTimeout( ()->
        clickCount = 0
        style =
          top:    e.pageY,
          left:   e.pageX,
          width:  noteWidth,
          height: noteHeight,
          backgroundColor: noteColor
        insertNewItem("create a new note", JSON.stringify(style))
      , 300)
    else
      clickCount = 0
      drawing = true
      strokePaths.length = 0
      strokePaths.push {x: e.pageX, y: e.pageY}
      clearTimeout timer
   .on 'dblclick', (e)->
    e.preventDefault()

  canvas.on 'mousemove', (e)->
    return unless drawing
    x = e.pageX
    y = e.pageY
    if (strokePaths.last().x - x)**2 + (strokePaths.last().y - y)**2 < 300
      return

    context = this.getContext("2d")
    console.log 'stroke'
    drawStroke(context, x, y)
    strokePaths.push {x: x, y: y}

  $(document).on 'keyup', (e)->
    return unless drawing

    path = null
    switch e.keyCode
      when 37 then path = {x:0, y:strokePaths.last().y}
      when 38 then path = {x:strokePaths.last().x, y:0}
      when 39 then path = {x:$(this).width(), y:strokePaths.last().y}
      when 40 then path = {x:strokePaths.last().x, y:$(this).height()}
      else
        return
    context = $('canvas')[0].getContext('2d')
    drawStroke(context, path.x, path.y)
    strokePaths.push path
    insertNewPath(strokePaths)


  $('#dialog_yes').click ->
    if deletingNote
      todoItemTable.update(
        id: deletingNote.id
        complete: true
      ).then( ->
        console.log 'completed'
        refreshTodoItems()
      , handleError)
    $('#dialog').hide()
  $('#dialog_no').click ->
    $('#dialog').hide()

  $('#color_panel').on('click', ->
    if this.className == 'inactive'
      this.className = "active"
    else
      this.className = 'inactive'
  )

  $('#color_panel div').on('click', ->
    parent = $('#color_panel').first()
    if parent.hasClass 'inactive'
      return
    tmp = document.createElement 'div'
    current = parent.children()[2]
    parent[0].replaceChild(tmp, this)
    parent[0].replaceChild(this, current)
    parent[0].replaceChild(current, tmp)
    noteColor = $(this).css('backgroundColor')
  )

drawStroke = (context, x, y)->
  context.strokeStyle = lineColor
  context.lineWidth = lineWidth
  context.beginPath()
  context.moveTo(strokePaths.last().x, strokePaths.last().y)
  context.lineTo(x, y)
  context.stroke()
  context.closePath()

init = ->
    client = new WindowsAzure.MobileServiceClient(
      'https://whiteboard.azure-mobile.net/',
      'ayQItbHiEURdZHPJXAyjjTrIRXWUog83')
    Note.table = client.getTable('todoitem')
    Stroke.table = client.getTable('strokepath')

createYoutbue = (id)->
  iframe = document.createElement 'iframe'
  iframe.className = 'youtube-player'
  iframe.type = "text/html"
  iframe.src ="http://www.youtube.com/embed/" + id + "?rel=0"
  $(iframe).attr("frameborder", "0")
  $(iframe).attr("autoplay", "1")
  iframe

imgreg = /^https?:\/\/(?:[a-z0-9\-_]+\.)+[a-z]{2,6}(?:\/[^\/#?]+)+\.(?:jpe?g|gif|png)$/
ytreg = /^https?:\/\/www.youtube.com\/watch\?v=(.+)/
createContent = (item)->
  if m = item.text.match ytreg
    createYoutbue(m[1])
  else if item.text.match(imgreg)
    img = document.createElement 'img'
    img.src = item.text
    img
  else
    document.createTextNode(item.text)

updateNote = (note)->
  style = extractStyle(note)
  todoItemTable.update(
    id: note.id,
    style: JSON.stringify(style)
    text: note.innerHTML
  ).then( ->
    refreshTodoItems()
  , handleError)

appendNote = (item)->
  div = document.createElement("div")
  div.className = "note"
  div.id = item.id
  style = JSON.parse(item.style)
  $(div).css(style)
  div.appendChild createContent(item)
  document.body.appendChild div

replaceTextArea = (note)->
  tarea = document.createElement('textarea')
  tarea.value = note.innerHTML
  $(tarea).width( $(note).width() )
  $(tarea).height( $(note).height() )
  note.innerHTML = ""
  note.appendChild tarea


handleError = (error) ->
  console.log "ERR",error

$(document).ready ->
  init()
  listenActions()
  Note.refresh()
  Strole.refresh()

