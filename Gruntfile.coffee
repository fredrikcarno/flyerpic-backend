module.exports = (grunt) ->

	grunt.initConfig

		pkg: grunt.file.readJSON 'package.json'
		exec: []

		coffee:

			assets:
				files:
					'cache/.temp/main.js': 'assets/coffee/*.coffee'

			modules:
				files:
					'cache/.temp/modules.js': 'modules/*/client.coffee'

		sass:

			assets:
				files: [{
					expand: true
					cwd: 'assets/scss/'
					src: ['*.scss']
					dest: 'cache/.temp/assets_css/'
					ext: '.css'
				}]

			modules:
				files:
					'cache/.temp/modules.css': 'cache/.temp/modules.scss'

		concat:

			css:
				options:
					separator: "\n"
				src: [
					'bower_components/normalize.css/normalize.css'
					'bower_components/basicNotification/dist/basicNotification.min.css'
					'assets/css/*.css'
					'cache/.temp/assets_css/*.css'
				]
				dest: 'cache/.temp/main.css'

			js:
				options:
					separator: "\n"
				src: [
					'bower_components/jQuery/dist/jquery.min.js'
					'bower_components/js-md5/js/md5.min.js'
					'bower_components/mousetrap/mousetrap.min.js'
					'bower_components/mousetrap/plugins/global-bind/mousetrap-global-bind.min.js'
					'bower_components/basicModal/dist/basicModal.min.js'
					'bower_components/basicNotification/dist/basicNotification.min.js'
					'assets/js/*.js'
					'cache/.temp/main.js'
				]
				dest: 'cache/.temp/main.js'

			modules:
				options:
					separator: "\n"
				src: 'modules/*/*.scss',
				dest: 'cache/.temp/modules.scss'

			json:
				options:
					banner: '['
					separator: ','
					footer: ']'
				src: 'modules/*/package.json'
				dest: 'cache/modules.json'

		uglify:

			assets:
				options:
					banner: '/*! <%= pkg.name %> <%= pkg.version %> | <%= grunt.template.today("yyyy-mm-dd") %> */\n'
				files:
					'cache/main.js': 'cache/.temp/main.js'

			modules:
				options:
					banner: '/*! <%= pkg.name %> <%= pkg.version %> | <%= grunt.template.today("yyyy-mm-dd") %> */\n'
				files:
					'cache/modules.js': 'cache/.temp/modules.js'

		cssmin:

			assets:
				options:
					banner: '/*! <%= pkg.name %> <%= pkg.version %> | <%= grunt.template.today("yyyy-mm-dd") %> */'
				files:
					'cache/main.css': 'cache/.temp/main.css'

			modules:
				options:
					banner: '/*! <%= pkg.name %> <%= pkg.version %> | <%= grunt.template.today("yyyy-mm-dd") %> */'
				files:
					'cache/modules.css': 'cache/.temp/modules.css'

		bake:

			js:
				options:
					content: 'languages/en.json'

				files:
					'cache/main.js': 'cache/main.js'

			modules:
				options:
					content: 'languages/en.json'

				files:
					'cache/modules.js': 'cache/modules.js'

		shell:

			main:
				command: '<%= exec %>'

		watch:

			js:
				files: [
					'languages/*.json'
					'assets/coffee/*.coffee'
					'assets/js/*.js'
					'!**/node_modules/**'
					'!**/bower_components/**'
				]
				tasks: ['js']
				options:
					spawn: false
					interrupt: true

			scss:
				files: [
					'assets/scss/*.scss'
					'assets/css/*.css'
				]
				tasks: ['css']
				options:
					spawn: false
					interrupt: true

			modules:
				files: [
					'languages/*.json'
					'modules/*/*'
					'!**/node_modules/**'
					'!**/bower_components/**'
				]
				tasks: ['modules']
				options:
					spawn: false
					interrupt: true

		autoprefixer:

			options:
				browsers: ['last 2 version', 'ie 8', 'ie 9']

			assets:
				src: 'cache/.temp/assets_css/*.css'

			modules:
				src: 'cache/.temp/modules.css'

		clean: ['cache/.temp/']

	require('load-grunt-tasks')(grunt)

	grunt.registerTask 'default', [
		'js'
		'css'
		'modules'
		'temp'
		'npm'
		'gulp'
	]

	grunt.registerTask 'js', [
		'coffee:assets'
		'concat:js'
		'uglify:assets'
		'bake:js'
	]

	grunt.registerTask 'css', [
		'sass:assets'
		'autoprefixer:assets'
		'concat:css'
		'cssmin:assets'
	]

	grunt.registerTask 'modules', [
		'coffee:modules'
		'concat:modules'
		'concat:json'
		'sass:modules'
		'autoprefixer:modules'
		'uglify:modules'
		'bake:modules'
		'cssmin:modules'
	]

	grunt.registerTask 'temp', [
		'clean'
	]

	grunt.registerTask 'npm', ->

		exec = grunt.config.get 'exec'

		# Read all directories
		grunt.file.expand("./modules/*").forEach (dir) ->

			exec.push "cd #{ dir }"
			exec.push 'npm install'
			exec.push 'cd ../../'

		# Save
		grunt.config.set 'exec', exec.join('&&')

		# When finished run in shell
		grunt.task.run 'shell'

	grunt.registerTask 'gulp', ->

		exec = grunt.config.get 'exec'

		# Read all directories
		grunt.file.expand("./flyers/*").forEach (dir) ->

			exec.push "cd #{ dir }"
			exec.push 'gulp'
			exec.push 'cd ../../'

		# Save
		grunt.config.set 'exec', exec.join('&&')

		# When finished run in shell
		grunt.task.run 'shell'