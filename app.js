var appendNote, beginX, beginY, clickCount, createContent, createYoutbue, deletingNote, drawing, editingNote, extractStyle, handleError, imgreg, init, insertNewItem, lineColor, lineWidth, listenActions, noteClickCount, noteColor, noteEditing, noteHeight, noteTimer, noteWidth, refreshTodoItems, strokeStrike, timer, todoItemTable, updateNote, ytreg;

todoItemTable = null;

editingNote = null;

deletingNote = null;

noteColor = "red";

noteWidth = "100px";

noteHeight = "100px";

lineColor = "rgba(0,0,0,0.5)";

lineWidth = 8;

clickCount = 0;

noteClickCount = 0;

noteTimer = null;

noteEditing = false;

drawing = false;

beginX = 0;

beginY = 0;

timer = null;

listenActions = function() {
  var canvas;
  canvas = $('#canvas');
  canvas.attr('width', canvas.width());
  canvas.attr('height', canvas.height());
  canvas.on('click', function(e) {
    var style, tarea;
    if (editingNote) {
      tarea = $('textarea', editingNote).first();
      editingNote.innerHTML = jQuery('<div>').text(tarea.val()).html();
      $(editingNote).width(tarea.width());
      $(editingNote).height(tarea.height());
      style = extractStyle(editingNote);
      todoItemTable.update({
        id: editingNote.id,
        style: JSON.stringify(style),
        text: editingNote.innerHTML
      }).then(function() {
        console.log('updated');
        return refreshTodoItems();
      }, handleError);
      editingNote = null;
      return;
    }
    if (drawing) {
      drawing = false;
      return;
    }
    clickCount++;
    console.log('click', clickCount);
    if (clickCount === 1) {
      return timer = setTimeout(function() {
        clickCount = 0;
        style = {
          top: e.pageY,
          left: e.pageX,
          width: noteWidth,
          height: noteHeight,
          backgroundColor: noteColor
        };
        return insertNewItem("create a new note", JSON.stringify(style));
      }, 300);
    } else {
      clickCount = 0;
      drawing = true;
      beginX = e.pageX;
      beginY = e.pageY;
      return clearTimeout(timer);
    }
  }).on('dblclick', function(e) {
    return e.preventDefault();
  });
  canvas.on('mousemove', function(e) {
    var context, x, y;
    if (!drawing) {
      return;
    }
    x = e.pageX;
    y = e.pageY;
    if ((beginX - x) * (beginX - x) + (beginY - y) * (beginY - y) < 200) {
      return;
    }
    context = this.getContext("2d");
    context.strokeStyle = lineColor;
    context.lineWidth = lineWidth;
    context.beginPath();
    context.moveTo(beginX, beginY);
    context.lineTo(x, y);
    context.stroke();
    context.closePath();
    beginX = x;
    return beginY = y;
  });
  $(document).on('keyup', function(e) {
    if (!drawing) {
      return;
    }
    switch (e.keyCode) {
      case 37:
        strokeStrike(0, beginY);
        break;
      case 38:
        strokeStrike(beginX, 0);
        break;
      case 39:
        strokeStrike($(this).width(), beginY);
        break;
      case 40:
        strokeStrike(beginX, $(this).height());
        break;
      default:
        return;
    }
    return drawing = false;
  });
  $('#dialog_yes').click(function() {
    if (deletingNote) {
      todoItemTable.update({
        id: deletingNote.id,
        complete: true
      }).then(function() {
        console.log('completed');
        return refreshTodoItems();
      }, handleError);
    }
    return $('#dialog').hide();
  });
  $('#dialog_no').click(function() {
    return $('#dialog').hide();
  });
  $('#color_panel').on('click', function() {
    if (this.className === 'inactive') {
      return this.className = "active";
    } else {
      return this.className = 'inactive';
    }
  });
  return $('#color_panel div').on('click', function() {
    var current, parent, tmp;
    parent = $('#color_panel').first();
    if (parent.hasClass('inactive')) {
      return;
    }
    tmp = document.createElement('div');
    current = parent.children()[2];
    parent[0].replaceChild(tmp, this);
    parent[0].replaceChild(this, current);
    parent[0].replaceChild(current, tmp);
    return noteColor = $(this).css('backgroundColor');
  });
};

strokeStrike = function(x, y) {
  var canvas, context;
  canvas = $('#canvas')[0];
  context = canvas.getContext("2d");
  context.strokeStyle = lineColor;
  context.lineWidth = lineWidth;
  context.beginPath();
  context.moveTo(beginX, beginY);
  context.lineTo(x, y);
  context.stroke();
  return context.closePath();
};

init = function() {
  var client;
  client = new WindowsAzure.MobileServiceClient('https://whiteboard.azure-mobile.net/', 'ayQItbHiEURdZHPJXAyjjTrIRXWUog83');
  return todoItemTable = client.getTable('todoitem');
};

createYoutbue = function(id) {
  var iframe;
  iframe = document.createElement('iframe');
  iframe.className = 'youtube-player';
  iframe.type = "text/html";
  iframe.src = "http://www.youtube.com/embed/" + id + "?rel=0";
  $(iframe).attr("frameborder", "0");
  $(iframe).attr("autoplay", "1");
  return iframe;
};

imgreg = /^https?:\/\/(?:[a-z0-9\-_]+\.)+[a-z]{2,6}(?:\/[^\/#?]+)+\.(?:jpe?g|gif|png)$/;

ytreg = /^https?:\/\/www.youtube.com\/watch\?v=(.+)/;

createContent = function(item) {
  var img, m;
  if (m = item.text.match(ytreg)) {
    return createYoutbue(m[1]);
  } else if (item.text.match(imgreg)) {
    img = document.createElement('img');
    img.src = item.text;
    return img;
  } else {
    return document.createTextNode(item.text);
  }
};

updateNote = function(note) {
  var style;
  style = extractStyle(note);
  return todoItemTable.update({
    id: note.id,
    style: JSON.stringify(style),
    text: note.innerHTML
  }).then(function() {
    return refreshTodoItems();
  }, handleError);
};

appendNote = function(item) {
  var div, style;
  div = document.createElement("div");
  div.className = "note";
  div.id = item.id;
  style = JSON.parse(item.style);
  $(div).css(style);
  div.appendChild(createContent(item));
  return document.body.appendChild(div);
};

refreshTodoItems = function() {
  var query;
  return query = todoItemTable.where({
    complete: false
  }).read().then(function(items) {
    var item, _i, _len;
    $('.note').remove();
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      item = items[_i];
      appendNote(item);
    }
    return $('.note').draggable({
      stop: function(e) {
        return updateNote(this);
      }
    }).on('click', function() {
      var f;
      $(this).css('z-index', 999);
      if (editingNote) {
        f = this === editingNote;
        editingNote.innerHTML = $('textarea', editingNote)[0].value;
        updateNote(editingNote);
        editingNote = null;
        noteClickCount = 0;
        if (f) {
          return;
        }
      }
      noteClickCount++;
      if (noteClickCount === 1) {
        return noteTimer = setTimeout((function(_this) {
          return function() {
            var tarea;
            noteClickCount = 0;
            editingNote = _this;
            tarea = document.createElement('textarea');
            tarea.value = _this.innerHTML;
            $(tarea).width($(_this).width());
            $(tarea).height($(_this).height());
            _this.innerHTML = "";
            _this.appendChild(tarea);
            return tarea.select();
          };
        })(this), 500);
      } else {
        noteClickCount = 0;
        clearTimeout(noteTimer);
        deletingNote = this;
        return $('#dialog').show();
      }
    }).on('dblclick', function(e) {
      return e.preventDefault;
    });
  }, handleError);
};

handleError = function(error) {
  return console.log("ERR", error);
};

insertNewItem = function(text, style) {
  console.log('insert');
  return todoItemTable.insert({
    text: text,
    style: style,
    complete: false
  }).then(refreshTodoItems, handleError);
};

extractStyle = function(dom) {
  console.log($(dom).height(), $(dom).width());
  return {
    backgroundColor: $(dom).css("backgroundColor"),
    height: $(dom).height(),
    width: $(dom).width(),
    left: $(dom).css("left"),
    top: $(dom).css("top")
  };
};

$(document).ready(function() {
  init();
  listenActions();
  return refreshTodoItems();
});

//# sourceMappingURL=app.js.map