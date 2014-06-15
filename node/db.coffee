# Dependencies
mysql	= require 'mysql'
async	= require 'async'

# Kanban modules
log		= require './log'

# Variables
config		= require './../data/config.json'
structure	=	"""
				CREATE TABLE `lychee_users` (
				  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
				  `type` varchar(10) NOT NULL DEFAULT 'photographer',
				  `username` varchar(100) NOT NULL DEFAULT '',
				  `password` varchar(100) NOT NULL DEFAULT '',
				  `name` varchar(50) CHARACTER SET latin1 NOT NULL DEFAULT '',
				  `description` varchar(1000) CHARACTER SET latin1 DEFAULT NULL,
				  `primarymail` varchar(100) CHARACTER SET latin1 NOT NULL,
				  `secondarymail` varchar(100) CHARACTER SET latin1 NOT NULL DEFAULT '',
				  `service` varchar(30) CHARACTER SET latin1 NOT NULL DEFAULT 'paypal',
				  `currencycode` varchar(3) CHARACTER SET latin1 NOT NULL DEFAULT 'USD',
				  `currencysymbol` varchar(1) CHARACTER SET latin1 NOT NULL DEFAULT '$',
				  `currencyposition` tinyint(1) NOT NULL DEFAULT '0',
				  `priceperalbum` double(4,2) NOT NULL,
				  `priceperphoto` double(4,2) NOT NULL,
				  `percentperprice` int(11) NOT NULL DEFAULT '0',
				  `watermark` int(11) DEFAULT NULL,
				  PRIMARY KEY (`id`)
				) ENGINE=MyISAM DEFAULT CHARSET=utf8;
				"""

user =	(username, password) ->

	"""
	INSERT INTO `lychee_users` (`username`, `password`, `name`, `description`, `primarymail`, `secondarymail`, `service`, `currencycode`, `currencysymbol`, `currencyposition`, `priceperalbum`, `priceperphoto`, `percentperprice`, `watermark`)
	VALUES ('#{ username }','#{ password }','',NULL,'','','paypal','USD','$',0,9.99,5.99,20,1)
	"""

create = (callback) ->

	db.source.query structure, (err, rows) ->

		if err?
			callback err
			return false
		else
			callback null
			return true

db = module.exports =

	source: null

	load: (callback) ->

		log.status 'db', 'Connecting to database'

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

				db.source.query 'SELECT * FROM lychee_users LIMIT 0', (err, rows) ->

					if err?

						# Table does not exist
						log.warning 'db', 'Table lychee_users not found'

						# Create table
						db.source.query structure, (err, rows) ->

							if err?

								# Creation failed
								log.error 'db', 'Could not connect to database', err.stack
								callback false
								return false

							else

								# Creation success
								log.status 'db', 'Created table lychee_users'
								callback null
								return true

					else

						# Table exists
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

	users:

		add: (username, password, callback) ->

			db.source.query user(username, password), (err, rows) ->

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

			db.source.query "SELECT * FROM lychee_users WHERE id = '#{ id }' LIMIT 1", (err, rows) ->

				if err? or rows.length is 0
					log.error 'db', 'Could not get users from database', err
					callback null
					return false

				callback rows[0]
				return true