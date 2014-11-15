gulp       = require 'gulp'
jade       = require 'gulp-jade'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
plumber    = require 'gulp-plumber'
less       = require 'gulp-less'
sourcemaps = require 'gulp-sourcemaps'
connect    = require 'gulp-connect'
livereload = require 'gulp-livereload'

build_dest = './gh-pages'
files =
  jade  : './app/*.jade'
  coffee: './app/*.coffee'
  less  : './assets/css/*.less'


gulp.task 'jade', ->
  gulp.src files.jade
    .pipe jade()
    .pipe gulp.dest build_dest
    .pipe connect.reload()

gulp.task 'coffee', ->
  gulp.src files.coffee
    .pipe plumber()
    .pipe sourcemaps.init
        loadMaps: true
    .pipe coffee
        bare: true
    .pipe concat 'app.js'
    .pipe sourcemaps.write '.',
        addComment: true
        sourceRoot: '/src'
    .pipe gulp.dest build_dest
    .pipe connect.reload()

gulp.task 'less', ->
  gulp.src files.less
    .pipe plumber()
    .pipe less()
    .pipe gulp.dest build_dest + '/css'
    .pipe connect.reload()

gulp.task 'connect', ->
  connect.server({
    root: build_dest,
    livereload: true
  })

gulp.task 'watch', ['build','connect'], ->
  gulp.watch files.jade,   ['jade']
  gulp.watch files.coffee, ['coffee']
  gulp.watch files.less,   ['less']


gulp.task 'build', ['jade', 'coffee', 'less']
gulp.task 'default', ['build']
