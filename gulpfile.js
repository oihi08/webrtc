"use strict"

// -- DEPENDENCIES -------------------------------------------------------------
var gulp    = require('gulp');
var coffee  = require('gulp-coffee');
var concat  = require('gulp-concat');
var header  = require('gulp-header');
var uglify  = require('gulp-uglify');
var gutil   = require('gulp-util');
var stylus  = require('gulp-stylus');
var pkg     = require('./package.json');

// -- FILES --------------------------------------------------------------------
var assets = 'assets/';
var source = {
  coffee : [ 'source/app.coffee'],
  styl   : [ 'source/app.styl']
}

var banner = ['/**',
  ' * <%= pkg.name %> - <%= pkg.description %>',
  ' * @version v<%= pkg.version %>',
  ' * @link    <%= pkg.homepage %>',
  ' * @author  <%= pkg.author.name %> (<%= pkg.author.site %>)',
  ' * @license <%= pkg.license %>',
  ' */',
  ''].join('\n');

// -- TASKS --------------------------------------------------------------------
gulp.task('coffee', function() {
  gulp.src(source.coffee)
    .pipe(concat(pkg.name + '.coffee'))
    .pipe(coffee().on('error', gutil.log))
    .pipe(uglify({mangle: false}))
    .pipe(header(banner, {pkg: pkg}))
    .pipe(gulp.dest(assets + '/js'));
});

gulp.task('styl', function() {
  gulp.src(source.styl)
    .pipe(concat(pkg.name + '.styl'))
    .pipe(stylus({compress: true, errors: true}))
    .pipe(header(banner, {pkg: pkg}))
    .pipe(gulp.dest(assets + '/css'));
});

gulp.task('init', function() {
  gulp.run(['coffee', 'styl'])
});

gulp.task('default', function() {
  gulp.watch(source.coffee, ['coffee']);
  gulp.watch(source.styl, ['styl']);
});
