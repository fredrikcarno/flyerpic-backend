# Dependencies
mysql	= require 'mysql'
async	= require 'async'

# Kanban modules
log		= require './log'

# Variables
config	= require './../data/config.json'

db = module.exports =

	source: null

	load: (callback) ->

		log.status 'db', 'Loading database'

		db.source = mysql.createConnection {
			host: config.host,
			port: config.port,
			user: config.user,
			password: config.password,
			database: config.database
		}

		db.source.connect (err) ->

			if err?

				log.error 'db', 'Could not connect to database', err.stack

				callback false
				return false

			else

				log.status 'db', 'Checking database'

				db.source.query 'SELECT * FROM lychee_photos, lychee_albums, lychee_settings LIMIT 0', (err, rows) ->

					if err?
						callback false
						return false
					else
						callback null
						return true

	settings: (callback) ->

		obj = {}

		db.source.query 'SELECT `key`, `value` FROM lychee_settings', (err, rows) ->

			if err
				log.error 'db', 'Could not get settings from database', err
				callback null
				return false

			async.each rows, (row, finish) ->

				obj[row.key] = row.value
				finish()

			, (error) ->

				callback obj
				return true