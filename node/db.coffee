# Dependencies
sqlite	= require 'sqlite3'
async	= require 'async'

# Kanban modules
log		= require './log'

db = module.exports =

	source: null

	load: (callback) ->

		log.status 'db', 'Loading database'

		db.source = new sqlite.Database 'data/main.sqlite', sqlite.OPEN_READWRITE | sqlite.OPEN_CREATE, (error) ->

			if error
				log.error 'db', 'Cloud not create/load database file', error
				return false

			db.exists (error) ->

				# Database exists
				return callback() if not error?

				# Database does not exist
				log.warning 'db', 'Database structure does not exist', error
				db.create (error) ->

					# Continue when successful
					return callback() if not error?

					# Show error
					log.error 'db', 'Could not create table `stats` or `settings`', error
					return false

	exists: (callback) ->

		log.status 'db', 'Checking database'

		db.source.run 'SELECT * FROM settings LIMIT 0', callback

	create: (callback) ->

		log.status 'db', 'Creating database structure'

		# Create settings
		db.source.run 'CREATE TABLE settings (key varchar(100) NOT NULL, value varchar(100) DEFAULT "")', callback

	settings:

		get: (callback) ->

			obj = {}

			db.source.all 'SELECT key, value FROM settings', (error, rows) ->

				if error
					log.error 'db', 'Could not get settings from database', error
					callback null
					return false

				async.each rows, (row, finish) ->

					obj[row.key] = row.value
					finish()

				, (error) ->

					callback obj
					return true

		set: (key, value, callback) ->

			db.settings.get (rows) ->

				if rows.hasOwnProperty key

					# Update
					db.source.run 'UPDATE settings SET value = $value WHERE key = $key',

						$key: key
						$value: value

					, (error) ->

						if error
							log.error 'db', "Could not set #{ key } in database", error
							callback error
							return false

						callback()
						return true

				else

					# Insert
					db.source.run 'INSERT INTO settings VALUES ($key, $value)',

						$key: key
						$value: value

					, (error) ->

						if error
							log.error 'db', "Could not set #{ key } in database", error
							callback error
							return false

						callback()
						return true

		remove: (key, callback) ->

			db.source.run 'DELETE FROM settings WHERE key = $key',

				$key: key

			, (error) ->

				if error
					log.error 'db', "Could not remove #{ key } from database", error
					callback error
					return false

				callback()
				return true