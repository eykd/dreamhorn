var gulp             = require('gulp');
var iconfont         = require('gulp-iconfont');
var config           = require('../../config').iconFonts;
var generateIconStyles = require('./generateIconStyles');

gulp.task('iconFont', function() {
  return gulp.src(config.src)
    .pipe(iconfont(config.options))
    .on('codepoints', generateIconStyles)
    .pipe(gulp.dest(config.dest));
});
