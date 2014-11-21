clickCount = 0
timer = null

canvasListner = ->
  canvas = $('#canvas')
  canvas.attr('width', canvas.width())
  canvas.attr('height', canvas.height())

  canvas.on 'click', (e)->
    if Note.editingNote
      Note.editingNote.setEditing(false)
      return

    if Stroke.drawingStroke
      Stroke.drawingStroke.save()
      return

    clickCount++
    console.log 'canvas click count', clickCount

    if clickCount == 1
      timer = setTimeout( ()->
        clickCount = 0
        style =
          top:    e.pageY,
          left:   e.pageX,
        Note.create "create a new note", style
      , 300)
    else
      clickCount = 0
      Stroke.drawingStroke = Stroke.create( {x: e.pageX, y: e.pageY} )
      clearTimeout timer
   .on 'dblclick', (e)->
    e.preventDefault()

  canvas.on 'mousemove', (e)->
    return unless Stroke.drawingStroke
    Stroke.drawingStroke.addPath({x:e.pageX, y:e.pageY})

  $(document).on 'keyup', (e)->
    console.log 'keyup', e.keyCode
    stroke = Stroke.drawingStroke
    return unless stroke

    path = null
    switch e.keyCode
      when 37 then path = {x:0, y:stroke.paths.last().y}
      when 38 then path = {x:stroke.paths.last().x, y:0}
      when 39 then path = {x:$(this).width(), y:stroke.paths.last().y}
      when 40 then path = {x:stroke.paths.last().x, y:$(this).height()}
      else
        return
    stroke.addPath path
    stroke.save()

listenActions = ->
  canvasListner()

  $('#dialog_yes').click ->
    if Note.completeNote
      Note.completeNote.complete()
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
    Note.default.backgroundColor = $(this).css('backgroundColor')
  )


init = ->
    client = new WindowsAzure.MobileServiceClient(
      'https://whiteboard.azure-mobile.net/',
      'ayQItbHiEURdZHPJXAyjjTrIRXWUog83')
    Note.table = client.getTable('todoitem')
    Stroke.table = client.getTable('strokepath')

handleError = (error) ->
  console.log "ERR",error

$(document).ready ->
  init()
  listenActions()
  Note.refresh()
  Note.deleteGomi()
  Stroke.refresh()

