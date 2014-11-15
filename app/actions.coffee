listenActions = ->
  $('canvas').click (e)->
    style =
      top: e.pageY,
      left: e.pageX,
      width: "100px",
      height: "100px",
      backgroundColor: "red"
    insertNewItem("create a new note", JSON.stringify style)
