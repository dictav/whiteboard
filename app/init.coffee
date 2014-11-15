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
      style = JSON.parse item.style
      console.log style
      $(div).css(style)
      div.innerHTML = item.text
      document.body.appendChild div
      console.log div
  , handleError)

handleError = (error) ->
  console.log "ERR",error

insertNewItem = (text, style)->
  console.log 'insert'
  todoItemTable.insert({ text: text, style: style, complete: false })
    .then( refreshTodoItems, handleError)


$(document).ready ->
  init()
  listenActions()
  refreshTodoItems()

