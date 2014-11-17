gulp       = require 'gulp'
plumber    = require 'gulp-plumber'
notify     = require 'gulp-notify'
jade       = require 'gulp-jade'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
less       = require 'gulp-less'
uglify     = require 'gulp-uglify'
minify     = require 'gulp-minify-css'
sourcemaps = require 'gulp-sourcemaps'
connect    = require 'gulp-connect'
livereload = require 'gulp-livereload'
bowerFiles = require "main-bower-files"
filter     = require 'gulp-filter'

build_dest = './gh-pages'
git_root = __dirname.replace(/~/, process.env.HOME).replace(/\//g, '\\/')
handler    = notify.onError("<%=error.toString().replace(/#{git_root}/,'')%>")
files =
  jade  : './app/views/**/*.jade'
  coffee: './app/scripts/**/*.coffee'
  less  : './app/css/**/*.less'
  assets: './app/assets/**/*'

gulp.task 'jade', ->
  gulp.src files.jade
    .pipe plumber(handler)
    .pipe jade()
    .pipe gulp.dest build_dest
    .pipe connect.reload()

gulp.task 'coffee', ->
  gulp.src files.coffee
    .pipe plumber(handler)
    .pipe sourcemaps.init
        loadMaps: true
    .pipe coffee
        bare: true
    .pipe concat 'app.js'
    .pipe uglify()
    .pipe sourcemaps.write '.',
        addComment: true
        sourceRoot: '/app'
    .pipe gulp.dest build_dest
    .pipe connect.reload()

gulp.task 'less', ->
  gulp.src files.less
    .pipe plumber(handler)
    .pipe sourcemaps.init
        loadMaps: true
    .pipe less()
    .pipe sourcemaps.write '.',
        addComment: true
        sourceRoot: '/accets/css'
    .pipe gulp.dest build_dest + '/css'
    .pipe connect.reload()

gulp.task 'assets', ->
  gulp.src files.assets
    .pipe gulp.dest build_dest + '/assets'

gulp.task 'vendor', ->
  gulp.src 'vendor/**/*'
    .pipe gulp.dest build_dest + '/vendor'

  jsFileter = filter '*.js'
  cssFileter = filter '*.css'
  gulp.src bowerFiles()
    .pipe jsFileter
    .pipe concat 'vendor.js'
    .pipe uglify()
    .pipe gulp.dest build_dest

  gulp.src bowerFiles()
    .pipe cssFileter
    .pipe concat 'vendor.css'
    .pipe minify()
    .pipe gulp.dest build_dest + '/css'


gulp.task 'connect', ->
  connect.server({
    root: build_dest,
    livereload: true
  })

gulp.task 'watch', ['build','connect'], ->
  gulp.watch files.jade,   ['jade']
  gulp.watch files.coffee, ['coffee']
  gulp.watch files.less,   ['less']


gulp.task 'build', ['jade', 'vendor', 'coffee', 'less']
gulp.task 'default', ['build']
