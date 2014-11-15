gulp       = require 'gulp'
jade       = require 'gulp-jade'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
plumber    = require 'gulp-plumber'
less       = require 'gulp-less'
sourcemaps = require 'gulp-sourcemaps'
connect    = require 'gulp-connect'
livereload = require 'gulp-livereload'
bowerFiles = require "main-bower-files"
filter     = require 'gulp-filter'

build_dest = './gh-pages'
files =
  jade  : './app/*.jade'
  coffee: './app/*.coffee'
  less  : './assets/css/*.less'
  vendor: './bower_components/**/*.js'


gulp.task 'jade', ->
  gulp.src files.jade
    .pipe plumber()
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

gulp.task 'vendor', ->
  jsFilter = filter '**/*.js'
  cssFilter = filter '**/*.css'

  gulp.src bowerFiles()
    .pipe concat 'vendor.js'
    .pipe gulp.dest build_dest
#    .pipe jsFilter.restore()
#    .pipe cssFilter
#    .pipe gulp.dest build_dest + '/css'

gulp.task 'connect', ->
  connect.server({
    root: build_dest,
    livereload: true
  })

gulp.task 'watch', ['build','connect'], ->
  gulp.watch files.jade,   ['jade']
  gulp.watch files.coffee, ['coffee']
  gulp.watch files.less,   ['less']
  gulp.watch files.vendor, ['vendor']


gulp.task 'build', ['jade', 'vendor', 'coffee', 'less']
gulp.task 'default', ['build']
