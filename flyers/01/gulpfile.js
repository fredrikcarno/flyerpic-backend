var	gulp = require('gulp'),
	plugins = require("gulp-load-plugins")();

paths = {
	'sass': './assets/scss/*.scss',
	'css': [
		'./bower_components/normalize.css/normalize.css',
		'./assets/css/*.css'
	],
	'coffee': './assets/coffee/*.coffee',
	'js': './bower_components/jQuery/dist/jquery.min.js',
	'temp': {
		'folder': './dist/.temp',
		'styles': [
			'./dist/.temp/css.min.css',
			'./dist/.temp/sass.min.css'
		],
		'scripts': [
			'./dist/.temp/js.min.js',
			'./dist/.temp/coffee.min.js'
		]
	},
	'clean': './dist/.temp'
}

gulp.task('sass', function() {

	var stream =
		gulp.src(paths.sass)
			.pipe(plugins.sass())
			.pipe(plugins.concat('sass.min.css', {newLine: "\n"}))
			.pipe(gulp.dest(paths.temp.folder));

	return stream;

});

gulp.task('css', function() {

	var stream =
		gulp.src(paths.css)
			.pipe(plugins.concat('css.min.css', {newLine: "\n"}))
			.pipe(gulp.dest(paths.temp.folder));

	return stream;

});

gulp.task('styles', ['sass', 'css'], function() {

	var stream =
		gulp.src(paths.temp.styles)
			.pipe(plugins.concat('styles.min.css', {newLine: "\n"}))
			.pipe(plugins.autoprefixer('last 2 versions'))
			.pipe(plugins.minifyCss())
			.pipe(gulp.dest('./dist'));

	return stream;

});

gulp.task('coffee', function() {

	var stream =
		gulp.src(paths.coffee)
			.pipe(plugins.coffee({bare: true}).on('error', plugins.util.log))
			.pipe(plugins.concat('coffee.min.js', {newLine: "\n"}))
			.pipe(gulp.dest(paths.temp.folder));

	return stream;

});

gulp.task('js', function() {

	var stream =
		gulp.src(paths.js)
			.pipe(plugins.concat('js.min.js', {newLine: "\n"}))
			.pipe(gulp.dest(paths.temp.folder));

	return stream;

});

gulp.task('scripts', ['coffee', 'js'], function() {

	var stream =
		gulp.src(paths.temp.scripts)
			.pipe(plugins.concat('scripts.min.js', {newLine: "\n"}))
			.pipe(plugins.uglify())
			.pipe(gulp.dest('./dist'));

	return stream;

});

gulp.task('clean', function() {

	var stream =
		gulp.src(paths.clean, {read: false})
			 .pipe(plugins.clean());

	return stream;

});

gulp.task('default', ['styles', 'scripts']);

gulp.task('watch', ['styles', 'scripts'], function() {
	plugins.livereload.listen();
	gulp.watch(paths.sass, ['styles']);
	gulp.watch(paths.css, ['styles']);
	gulp.watch(paths.coffee, ['scripts']);
	gulp.watch(paths.js, ['scripts']);
});