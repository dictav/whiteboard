todoItemTable = null
editingNote = null

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
beginX = 0
beginY = 0

timer = null

listenActions = ->
  canvas = $('#canvas')
  canvas.attr('width', canvas.width())
  canvas.attr('height', canvas.height())

  canvas.on 'click', (e)->
    if editingNote
      editingNote.innerHTML = $('textarea', editingNote)[0].value
      style = extractStyle(editingNote)
      console.log editingNote.innerHTML
      todoItemTable.update(
        id: editingNote.id,
        style: JSON.stringify(style),
        text: editingNote.innerHTML
      ).then( ->
        console.log 'updated'
      , handleError)
      editingNote = null
      return

    if drawing
      drawing = false
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
        insertNewItem("create a new note", JSON.stringify style)
      , 300)
    else
      clickCount = 0
      drawing = true
      beginX = e.pageX
      beginY = e.pageY
      clearTimeout timer
   .on 'dblclick', (e)->
    e.preventDefault()

  canvas.on 'mousemove', (e)->
    return unless drawing
    x = e.pageX
    y = e.pageY
    if (beginX - x)*(beginX - x) + (beginY - y)*(beginY - y) < 100
      return

    context = this.getContext("2d")
    context.strokeStyle = lineColor
    context.lineWidth = lineWidth
    context.beginPath()
    context.moveTo(beginX, beginY)
    context.lineTo(x, y)
    context.stroke()
    context.closePath()
    beginX = x
    beginY = y

  $(document).on 'keyup', (e)->
    return unless drawing

    switch e.keyCode
      when 37 then strokeStrike(0,beginY)
      when 38 then strokeStrike(beginX,0)
      when 39 then strokeStrike($(this).width(),beginY)
      when 40 then strokeStrike(beginX,$(this).height())
      else return
    drawing = false

strokeStrike = (x,y)->
  canvas = $('#canvas')[0]
  context = canvas.getContext("2d")
  context.strokeStyle = lineColor
  context.lineWidth = lineWidth
  context.beginPath()
  context.moveTo(beginX, beginY)
  context.lineTo(x, y)
  context.stroke()
  context.closePath()
init = ->
    client = new WindowsAzure.MobileServiceClient(
      'https://whiteboard.azure-mobile.net/',
      'ayQItbHiEURdZHPJXAyjjTrIRXWUog83')
    todoItemTable = client.getTable('todoitem')

refreshTodoItems = ->
  query = todoItemTable.where({complete: false}).read().then( (items)->
    $('div').remove()
    for item in items
      div = document.createElement("div")
      div.className = "note"
      div.innerHTML = item.text
      div.id = item.id
      style = JSON.parse(item.style)
      $(div).css(style)
      document.body.appendChild div

    $('.note').draggable(
      stop: (e)->
        style = extractStyle(this)
        todoItemTable.update(
          id: this.id,
          style: JSON.stringify(style)
        ).then( ->
          console.log 'updated'
        , handleError)
    ).on('click', ->
      $(this).css('z-index',999)
      if editingNote
        f = this == editingNote
        editingNote.innerHTML = $('textarea', editingNote)[0].value
        style = extractStyle(editingNote)
        console.log 'ore'
        todoItemTable.update(
          id: editingNote.id,
          style: JSON.stringify(style),
          text: editingNote.innerHTML
        ).then( ->
          console.log 'updated'
        , handleError)

        editingNote = null
        return if f

      setTimeout( ()=>
        clickCount = 0
        editingNote = this
        tarea = document.createElement('textarea')
        tarea.value = this.innerHTML
        $(tarea).width( $(this).width() )
        $(tarea).height( $(this).height() )
        this.innerHTML = ""
        this.appendChild tarea
        tarea.focus()
      , 500)
      )
  , handleError)

handleError = (error) ->
  console.log "ERR",error

insertNewItem = (text, style)->
  console.log 'insert'
  todoItemTable.insert({ text: text, style: style, complete: false })
    .then( refreshTodoItems, handleError)

extractStyle = (dom)->
  {
    backgroundColor: $(dom).css("backgroundColor"),
    height:          $(dom).css("height"),
    width:           $(dom).css("width"),
    left:            $(dom).css("left"),
    top:             $(dom).css("top")
  }

$(document).ready ->
  init()
  listenActions()
  refreshTodoItems()

