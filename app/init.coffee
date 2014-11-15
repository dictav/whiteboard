todoItemTable = null
init = ->
    client = new WindowsAzure.MobileServiceClient(
      'https://whiteboard.azure-mobile.net/',
      'ayQItbHiEURdZHPJXAyjjTrIRXWUog83')
    todoItemTable = client.getTable('todoitem')

refreshTodoItems = ->
  query = todoItemTable.where({complete: false}).read().then( (items)->
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
          style: JSON.stringify style
        ).then( ->
          console.log 'updated'
        , handleError)
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
#  refreshTodoItems()

