# Dependencies
mysql	= require 'mysql'
async	= require 'async'

# Backend modules
log		= require './log'

# Variables
config		= require './../data/config.json'
structure	=

	users:

		"""
		CREATE TABLE IF NOT EXISTS `lychee_users` (
		  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
		  `type` varchar(30) NOT NULL DEFAULT 'photographer',
		  `username` varchar(100) NOT NULL DEFAULT '',
		  `password` varchar(100) NOT NULL DEFAULT '',
		  `name` varchar(50) NOT NULL DEFAULT '',
		  `description` varchar(1000) DEFAULT NULL,
		  `primarymail` varchar(100) NOT NULL,
		  `secondarymail` varchar(100) NOT NULL DEFAULT '',
		  `helpmail` varchar(100) NOT NULL DEFAULT '',
		  `avatar` varchar(1000) NOT NULL DEFAULT '',
		  `background` varchar(1000) NOT NULL DEFAULT '',
		  `service` varchar(30) NOT NULL DEFAULT 'paypal',
		  `currencycode` varchar(3) NOT NULL DEFAULT 'USD',
		  `currencysymbol` varchar(1) NOT NULL DEFAULT '$',
		  `currencyposition` tinyint(1) NOT NULL DEFAULT '0',
		  `priceperalbum` double(4,2) NOT NULL,
		  `priceperphoto` double(4,2) NOT NULL,
		  `percentperprice` int(11) NOT NULL DEFAULT '0',
		  `watermark` int(11) DEFAULT NULL,
		  PRIMARY KEY (`id`)
		) ENGINE=MyISAM DEFAULT CHARSET=utf8;
		"""

	user:

		"""
		INSERT INTO `lychee_users` (`username`, `password`, `name`, `description`, `primarymail`, `secondarymail`, `helpmail`, `avatar`, `background`, `service`, `currencycode`, `currencysymbol`, `currencyposition`, `priceperalbum`, `priceperphoto`, `percentperprice`, `watermark`)
		VALUES (?,?,'',NULL,'','','','','','paypal','USD','$',0,9.99,5.99,20,1)
		"""

	mails:

		"""
		CREATE TABLE IF NOT EXISTS `lychee_mails` (
		  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
		  `mail` varchar(100) NOT NULL,
		  `code` varchar(100) NOT NULL,
		  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		  PRIMARY KEY (`id`)
		) ENGINE=MyISAM DEFAULT CHARSET=utf8;
		"""

connectDatabase = ->

	return mysql.createConnection {
		host: config.host,
		port: config.port,
		user: config.user,
		password: config.password,
		database: config.database
	}

db = module.exports =

	source: null

	load: (callback) ->

		log.status 'db', 'Connecting to database'

		db.source = connectDatabase()

		db.source.connect (err) ->

			if err?

				log.error 'db', 'Could not connect to database', err.stack

				callback false
				return false

			else

				log.status 'db', 'Checking database'

				db.source.query 'SELECT * FROM lychee_users, lychee_mails LIMIT 0', (err, rows) ->

					if err?

						# Table does not exist
						log.warning 'db', 'Table lychee_users or lychee_mails not found'

						async.parallel [

							(callback) ->

								# Create table for users
								db.source.query structure.users, callback

							, (callback) ->

								# Create table for mails
								db.source.query structure.mails, callback

						], (err, results) ->

							if err?

								# Creation failed
								log.error 'db', 'Could not create tables in database', err.stack
								callback false
								return false

							else

								# Creation success
								log.status 'db', 'Created table lychee_users and lychee_mails'
								callback null
								return true

					else

						# Table exists
						callback null
						return true

		db.source.on 'error', (err) ->

			###
			# Connection to the MySQL server is usually
			# lost due to either server restart, or a
			# connnection idle timeout (the wait_timeout
			# server variable configures this)
			###
			if err.code is 'PROTOCOL_CONNECTION_LOST'

				# Lost connection
				log.warning 'db', 'Lost connection to database', err
				db.source = connectDatabase()

			else

				# Error
				log.error 'db', 'Database error', err
				throw err

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

	users:

		add: (username, password, callback) ->

			db.source.query structure.user, [username, password], (err, rows) ->

				if err?
					log.error 'db', 'Could not add user to database', err
					callback err
					return false

				callback null
				return true

		get: (callback) ->

			db.source.query 'SELECT * FROM lychee_users', (err, rows) ->

				if err?
					log.error 'db', 'Could not get users from database', err
					callback null
					return false

				callback rows
				return true

		me: (id, callback) ->

			db.source.query 'SELECT * FROM lychee_users WHERE id = ? LIMIT 1', [id], (err, rows) ->

				if err? or rows.length is 0
					log.error 'db', 'Could not get users from database', err
					callback null
					return false

				callback rows[0]
				return true