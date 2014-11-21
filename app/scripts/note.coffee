class window.Note
  @table = null
  @editingNote = null
  @deletingNote = null
  @allNotes = []
  @imgreg = /^https?:\/\/(?:[a-z0-9\-_]+\.)+[a-z]{2,6}(?:\/[^\/#?]+)+\.(?:jpe?g|gif|png)$/
  @ytreg = /^https?:\/\/www.youtube.com\/watch\?v=(.+)/
  @refresh: ->
    note.remove() for note in @allNotes
    window.Note.allNotes = []
    query = Note.table.where({complete: false}).read()
      .then( (items)->
        for item in items
          note = new window.Note(item)
          window.Note.allNotes.push(note)
          document.body.appendChild note.view
      , window.handleError)

  @insertNewNote: (data)->
    console.log 'insert'
    data.complete = false
    Note.table.insert(data).then( @refresh, window.handleError)

  constructor:(@item) ->
    @clickCount = 0
    @timer = null
    v = $(@build())

  update: (data)->
    data.id = @item.id
    Note.table.update(data)
      .then( (data)->
        console.log data
      , window.handleError)
  
  setEditing: (tof)->
    if tof
      @editingNote = this
      replaceTextArea()
    else
      text = $('textarea', this).first().val()
      update(text: text)
      @editingNote = null

  rebuild: ->
    $(@view).remote()
    @build()

  # private

  build: ->
    div = document.createElement("div")
    div.className = "note"
    div.id = @item.id
    style = JSON.parse(@item.style)
    $(div).css(style)
    $(div).attr("data-src", @item.text)
    createContent(div)
    document.body.appendChild div
    @view = div
    $(@view).on 'click', @clickHandler
      .on 'dblclick', (e)-> e.preventDefault
      .draggable
        stop: (e)->
          style = extractStyle(@view)
          update
            style: JSON.stringify(style)
    console.log @view
    @view

  remove: ->
    $(this).remove()

  clickHandler: (e)->
    $(this).css('z-index',999)
    if @editingNote
      @editingNote.setEditing(false)
      @clickCount = 0
      return if this == @editingNote

    @clickCount++
    if @clickCount == 1
      @timer = setTimeout( ()=>
        @clickCount = 0
        setEditing(true)
      , 500)
    else
      @clickCount = 0
      clearTimeout(@timer)
      @deletingNote = this
      $('#dialog').show()


  extractStyle = (dom)->
    {
      backgroundColor: $(dom).css("backgroundColor"),
      height:          $(dom).height(),
      width:           $(dom).width(),
      left:            $(dom).css("left"),
      top:             $(dom).css("top")
    }

  replaceTextArea: ->
    tarea = document.createElement('textarea')
    tarea.value = this.innerHTML
    $(tarea).width( $(this).width() )
    $(tarea).height( $(this).height() )
    this.innerHTML = ""
    this.appendChild tarea
    tarea.select()

  createContent = (div)->
    src = $(div).attr("data-src")
    content = if m = src.match Note.ytreg
                createYoutbue(m[1])
              else if src.match(Note.imgreg)
                img = document.createElement 'img'
                img.src = item.text
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

