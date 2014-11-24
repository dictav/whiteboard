var canvasClickListner, canvasHoldListner, canvasListner, canvasTimer, clickCount, handleError, init, listenActions, timer;

clickCount = 0;

timer = null;

canvasTimer = null;

canvasClickListner = function(e) {
  if ($(this).hasClass('noclick')) {
    $(this).removeClass('noclick');
    return;
  }
  if (Note.editingNote) {
    Note.editingNote.setEditing(false);
    return;
  }
  if (Stroke.drawingStroke) {
    Stroke.drawingStroke.save();
    return;
  }
  clickCount++;
  console.log('canvas click count', clickCount);
  if (clickCount === 1) {
    return timer = setTimeout(function() {
      clickCount = 0;
      return Note.create("create a new note", {
        top: e.pageY,
        left: e.pageX
      });
    }, 300);
  } else {
    clickCount = 0;
    Stroke.drawingStroke = Stroke.create({
      x: e.pageX,
      y: e.pageY
    });
    return clearTimeout(timer);
  }
};

canvasHoldListner = function(e) {
  if (e.type === 'mousedown') {
    canvasTimer = setTimeout((function(_this) {
      return function() {
        var p, s, _i, _j, _len, _len1, _ref, _ref1;
        $(_this).addClass('noclick');
        _ref = Stroke.allStrokes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          _ref1 = s.paths;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            p = _ref1[_j];
            if (Math.pow(p.x - e.pageX, 2) + Math.pow(p.y - e.pageY, 2) < 300) {
              console.log('clear', s);
              s["delete"]();
              Stroke.refresh();
              canvasTimer = null;
              return;
            }
          }
        }
        return console.log('NOT HOGE');
      };
    })(this), 900);
  }
  if (e.type === 'mouseup' && canvasTimer) {
    console.log('cancel clear');
    clearTimeout(canvasTimer);
    return canvasTimer = null;
  }
};

canvasListner = function() {
  var canvas;
  canvas = $('#canvas');
  canvas.attr('width', canvas.width());
  canvas.attr('height', canvas.height());
  canvas.on('mousemove', function(e) {
    if (!Stroke.drawingStroke) {
      return;
    }
    return Stroke.drawingStroke.addPath({
      x: e.pageX,
      y: e.pageY
    });
  }).on('dblclick', function(e) {
    return e.preventDefault();
  }).on('click', canvasClickListner).on('mousedown mouseup', canvasHoldListner);
  return $(document).on('keyup', function(e) {
    var path, stroke;
    console.log('keyup', e.keyCode);
    stroke = Stroke.drawingStroke;
    if (!stroke) {
      return;
    }
    path = null;
    switch (e.keyCode) {
      case 37:
        path = {
          x: 0,
          y: stroke.paths.last().y
        };
        break;
      case 38:
        path = {
          x: stroke.paths.last().x,
          y: 0
        };
        break;
      case 39:
        path = {
          x: $(this).width(),
          y: stroke.paths.last().y
        };
        break;
      case 40:
        path = {
          x: stroke.paths.last().x,
          y: $(this).height()
        };
        break;
      default:
        return;
    }
    stroke.addPath(path);
    return stroke.save();
  });
};

listenActions = function() {
  canvasListner();
  $('#dialog_yes').click(function() {
    if (Note.completeNote) {
      Note.completeNote.complete();
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
    return Note["default"].backgroundColor = $(this).css('backgroundColor');
  });
};

init = function() {
  var client;
  client = new WindowsAzure.MobileServiceClient("https://whiteboard.azure-mobile.net/", "TiLMzcFCaJaUjuEmZycYLJjoJpIDve68");
  Note.table = client.getTable('notes');
  return Stroke.table = client.getTable('strokes');
};

handleError = function(error) {
  return console.log("ERR", error);
};

$(document).ready(function() {
  init();
  listenActions();
  Note.refresh();
  Note.deleteGomi();
  return Stroke.refresh();
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

window.Note = (function() {
  var createContent, createYoutbue, extractStyle;

  Note.table = null;

  Note.editingNote = null;

  Note.completeNote = null;

  Note.allNotes = [];

  Note.imgreg = /^https?:\/\/(?:[a-z0-9\-_]+\.)+[a-z]{2,6}(?:\/[^\/#?]+)+\.(?:jpe?g|gif|png)$/;

  Note.ytreg = /^https?:\/\/www.youtube.com\/watch\?v=(.+)/;

  Note["default"] = {
    width: "100px",
    height: "100px",
    backgroundColor: "red"
  };

  Note.deleteGomi = function() {
    return Note.table.where({
      text: "create a new note"
    }).read().then(function(items) {
      var item, _i, _len;
      console.log('delete', items.length, 'items');
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        Note.table.del({
          id: item.id
        });
      }
      return console.log('delete done');
    }, handleError);
  };

  Note.refresh = function() {
    var note, query, _i, _len, _ref;
    _ref = this.allNotes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      note = _ref[_i];
      note.remove();
    }
    window.Note.allNotes = [];
    return query = Note.table.where({
      complete: false
    }).read().then(function(items) {
      var item, _j, _len1, _results;
      _results = [];
      for (_j = 0, _len1 = items.length; _j < _len1; _j++) {
        item = items[_j];
        note = new Note(item);
        window.Note.allNotes.push(note);
        _results.push(document.body.appendChild(note.view));
      }
      return _results;
    }, window.handleError);
  };

  Note.create = function(text, style) {
    var data, k, note, v, _ref;
    _ref = this["default"];
    for (k in _ref) {
      v = _ref[k];
      style[k] || (style[k] = v);
    }
    data = {
      text: text,
      style: JSON.stringify(style),
      complete: false
    };
    note = new Note(data);
    this.allNotes.push(note);
    note.insert();
    return note;
  };

  function Note(item) {
    var v;
    this.item = item;
    this.clickHandler = __bind(this.clickHandler, this);
    this.setEditing = __bind(this.setEditing, this);
    this.clickCount = 0;
    this.timer = null;
    v = $(this.build());
  }

  Note.prototype.insert = function() {
    return Note.table.insert(this.item).then(function(data) {
      return console.log('inserted note', data);
    }, window.handleError);
  };

  Note.prototype.update = function(data) {
    data.id = this.item.id;
    return Note.table.update(data).then(function(data) {
      return console.log('updated note', data);
    }, window.handleError);
  };

  Note.prototype.complete = function() {
    return Note.table.update({
      id: this.item.id,
      complete: true
    }).then((function(_this) {
      return function() {
        console.log('completed');
        return $(_this.view).remove();
      };
    })(this), handleError);
  };

  Note.prototype.setEditing = function(tof) {
    if (tof) {
      Note.editingNote = this;
      return this.replaceTextArea();
    } else {
      this.item.text = $('textarea', this.view).first().val();
      this.update({
        text: this.item.text
      });
      Note.editingNote = null;
      return this.rebuild();
    }
  };

  Note.prototype.rebuild = function() {
    $(this.view).remove();
    return this.build();
  };

  Note.prototype.build = function() {
    var div, style;
    div = document.createElement("div");
    div.className = "note";
    div.id = this.item.id;
    style = JSON.parse(this.item.style);
    $(div).css(style);
    createContent(div, this.item.text);
    document.body.appendChild(div);
    this.view = div;
    $(this.view).on('click', this.clickHandler).on('dblclick', function(e) {
      return e.preventDefault();
    }).draggable({
      stop: (function(_this) {
        return function(e, ui) {
          $(_this.view).addClass('noclick');
          _this.item.style = JSON.stringify(extractStyle(_this.view));
          return _this.update({
            style: _this.item.style
          });
        };
      })(this)
    });
    return this.view;
  };

  Note.prototype.remove = function() {
    return $(this).remove();
  };

  Note.prototype.clickHandler = function(e) {
    var flag;
    if ($(this.view).hasClass('noclick')) {
      $(this.view).removeClass('noclick');
      return;
    }
    $(this).css('z-index', 999);
    if (Note.editingNote) {
      flag = Note.editingNote === this;
      Note.editingNote.setEditing(false);
      this.clickCount = 0;
      if (flag) {
        return;
      }
    }
    this.clickCount++;
    if (this.clickCount === 1) {
      return this.timer = setTimeout((function(_this) {
        return function() {
          _this.clickCount = 0;
          return _this.setEditing(true);
        };
      })(this), 500);
    } else {
      this.clickCount = 0;
      clearTimeout(this.timer);
      Note.completeNote = this;
      return $('#dialog').show();
    }
  };

  Note.prototype.replaceTextArea = function() {
    var tarea;
    tarea = document.createElement('textarea');
    tarea.value = this.item.text;
    $(tarea).width($(this.view).width());
    $(tarea).height($(this.view).height());
    this.view.innerHTML = "";
    this.view.appendChild(tarea);
    return tarea.select();
  };

  extractStyle = function(dom) {
    return {
      backgroundColor: $(dom).css("backgroundColor"),
      height: $(dom).height(),
      width: $(dom).width(),
      left: $(dom).css("left"),
      top: $(dom).css("top")
    };
  };

  createContent = function(div, src) {
    var content, img, m;
    content = (m = src.match(Note.ytreg)) ? createYoutbue(m[1]) : src.match(Note.imgreg) ? (img = document.createElement('img'), img.src = src, img) : document.createTextNode(src);
    return div.appendChild(content);
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

  return Note;

})();

window.Stroke = (function() {
  Stroke.table = null;

  Stroke.allStrokes = [];

  Stroke.drawingStroke = null;

  Stroke["default"] = {
    width: 8,
    color: "rgba(0,0,0,0.5)"
  };

  Stroke.create = function(path) {
    var data, stroke;
    data = {
      width: Stroke["default"].width,
      color: Stroke["default"].color,
      data: JSON.stringify([path])
    };
    stroke = new Stroke(data);
    Stroke.allStrokes.push(stroke);
    console.log('create stroke', stroke);
    return stroke;
  };

  Stroke.refresh = function() {
    var c, canvas, condition, query;
    this.allStrokes = [];
    canvas = $('canvas')[0];
    c = canvas.getContext('2d');
    c.save();
    c.setTransform(1, 0, 0, 1, 0, 0);
    c.clearRect(0, 0, canvas.width, canvas.height);
    c.restore();
    condition = function() {
      return this.data !== "";
    };
    return query = Stroke.table.where(condition).read().then(function(strokes) {
      var stroke, _i, _len, _results;
      console.log('strokes', strokes);
      _results = [];
      for (_i = 0, _len = strokes.length; _i < _len; _i++) {
        stroke = strokes[_i];
        _results.push(Stroke.allStrokes.push(new Stroke(stroke)));
      }
      return _results;
    });
  };

  function Stroke(stroke) {
    this.stroke = stroke;
    this.paths = JSON.parse(this.stroke.data);
    this.paths.last = function() {
      return this[this.length - 1];
    };
    this.context = $('canvas')[0].getContext('2d');
    this.context.strokeStyle = this.stroke.color;
    this.context.lineWidth = this.stroke.width;
    this.build();
  }

  Stroke.prototype.build = function() {
    var i, path, _i, _len, _ref;
    this.context.beginPath();
    _ref = this.paths;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      path = _ref[i];
      if (i === 0) {
        this.context.moveTo(path.x, path.y);
      } else {
        this.context.lineTo(path.x, path.y);
      }
    }
    this.context.stroke();
    return this.context.closePath();
  };

  Stroke.prototype.addPath = function(path) {
    var x, y;
    x = path.x;
    y = path.y;
    if (Math.pow(this.paths.last().x - x, 2) + Math.pow(this.paths.last().y - y, 2) < 300) {
      return;
    }
    this.context.beginPath();
    this.context.moveTo(this.paths.last().x, this.paths.last().y);
    this.context.lineTo(x, y);
    this.context.stroke();
    this.context.closePath();
    return this.paths.push(path);
  };

  Stroke.prototype.save = function() {
    Stroke.drawingStroke = null;
    return this.insert();
  };

  Stroke.prototype.insert = function() {
    var data;
    data = {
      width: this.stroke.width,
      color: this.stroke.color,
      data: JSON.stringify(this.paths)
    };
    console.log('insert stroke', data);
    return Stroke.table.insert(data).then((function(_this) {
      return function(stroke) {
        _this.stroke.id = stroke.id;
        return console.log('inserted stroke', stroke);
      };
    })(this), handleError);
  };

  Stroke.prototype.update = function(data) {
    data.id = this.stroke.id;
    return Stroke.table.update(data).then(function(data) {
      return console.log('update stroke', data);
    }, window.handleError);
  };

  Stroke.prototype["delete"] = function() {
    console.log('delete stroke');
    return Stroke.table.del({
      id: this.stroke.id
    }).then(function() {
      return console.log('deleted stroke');
    }, window.handleError);
  };

  return Stroke;

})();

//# sourceMappingURL=app.js.map