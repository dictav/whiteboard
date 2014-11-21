class window.Note
  @table = null
  @editingNote = null
  @completeNote = null
  @allNotes = []
  @imgreg = /^https?:\/\/(?:[a-z0-9\-_]+\.)+[a-z]{2,6}(?:\/[^\/#?]+)+\.(?:jpe?g|gif|png)$/
  @ytreg = /^https?:\/\/www.youtube.com\/watch\?v=(.+)/
  @default =
    width: "100px"
    height: "100px"
    backgroundColor: "red"

  # class methods
  @deleteGomi: ->
    Note.table.where({text: "create a new note"}).read()
      .then (items)->
        console.log 'delete',items.length, 'items'
        for item in items
          Note.table.del {id: item.id}
        console.log 'delete done'
      , handleError

  @refresh: ->
    note.remove() for note in @allNotes
    window.Note.allNotes = []
    query = Note.table.where({complete: false}).read()
      .then( (items)->
        for item in items
          note = new Note(item)
          window.Note.allNotes.push(note)
          document.body.appendChild note.view
      , window.handleError)

  @create: (text,style)->
    for k,v of @default
      style[k] ||= v
    data =
      text: text
      style: JSON.stringify style
      complete: false
    note = new Note(data)
    @allNotes.push note
    note.insert()
    note

  # instance methods
  constructor:(@item) ->
    @clickCount = 0
    @timer = null
    v = $(@build())

  insert: ->
    Note.table.insert(@item)
      .then( (data)->
        console.log 'inserted note', data
      , window.handleError)

  update: (data)->
    data.id = @item.id
    Note.table.update(data)
      .then( (data)->
        console.log 'updated note', data
      , window.handleError)
  complete: ->
      Note.table.update(
        id: @item.id
        complete: true
      ).then  =>
        console.log 'completed'
        $(@view).remove()
      , handleError
  
  setEditing: (tof)=>
    if tof
      Note.editingNote = this
      @replaceTextArea()
    else
      @item.text = $('textarea', @view).first().val()
      @update(text: @item.text)
      Note.editingNote = null
      @rebuild()

  rebuild: ->
    $(@view).remove()
    @build()

  build: ->
    div = document.createElement("div")
    div.className = "note"
    div.id = @item.id
    style = JSON.parse(@item.style)
    $(div).css(style)
    createContent(div, @item.text)
    document.body.appendChild div
    @view = div
    $(@view)
      .on 'click', @clickHandler
      .on 'dblclick', (e)-> e.preventDefault()
      .draggable
        stop: (e,ui)=>
          $(@view).addClass 'noclick'
          @item.style = JSON.stringify(extractStyle(@view))
          @update
            style: @item.style
    @view

  remove: ->
    $(this).remove()

  clickHandler: (e)=>
    if $(@view).hasClass 'noclick'
      $(@view).removeClass 'noclick'
      return

    $(this).css('z-index',999)
    if Note.editingNote
      flag =  Note.editingNote == this
      Note.editingNote.setEditing(false)
      @clickCount = 0
      return if flag

    @clickCount++
    if @clickCount == 1
      @timer = setTimeout( ()=>
        @clickCount = 0
        @setEditing(true)
      , 500)
    else
      @clickCount = 0
      clearTimeout(@timer)
      Note.completeNote = this
      $('#dialog').show()


  replaceTextArea: ->
    tarea = document.createElement('textarea')
    tarea.value = @item.text
    $(tarea).width( $(@view).width() )
    $(tarea).height( $(@view).height() )
    @view.innerHTML = ""
    @view.appendChild tarea
    tarea.select()

  extractStyle = (dom)->
    {
      backgroundColor: $(dom).css("backgroundColor"),
      height:          $(dom).height(),
      width:           $(dom).width(),
      left:            $(dom).css("left"),
      top:             $(dom).css("top")
    }

  createContent = (div, src)->
    content = if m = src.match Note.ytreg
                createYoutbue(m[1])
              else if src.match(Note.imgreg)
                img = document.createElement 'img'
                img.src = src
                img
              else
                document.createTextNode(src)
    div.appendChild content


  createYoutbue = (id)->
    iframe = document.createElement 'iframe'
    iframe.className = 'youtube-player'
    iframe.type = "text/html"
    iframe.src ="http://www.youtube.com/embed/" + id + "?rel=0"
    $(iframe).attr("frameborder", "0")
    $(iframe).attr("autoplay", "1")
    iframe

