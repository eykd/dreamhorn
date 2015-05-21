var gulp = require('gulp');
var karma = require('karma');

var karmaTask = function(done) {
  karma.server.start({
    configFile: process.cwd() + '/karma.conf.js',
    singleRun: true
  }, done);
};

gulp.task('karma', karmaTask);


var karmaWatchTask = function(done) {
  karma.server.start({
    configFile: process.cwd() + '/karma.conf.js',
    singleRun: false
  }, done);
};

gulp.task('karma-watch', karmaWatchTask);

module.exports = karmaTask;
