# Dependencies
async	= require 'async'
crypto	= require 'crypto'
joi		= require 'joi'
_		= require 'underscore'
Encoder = require('qr').Encoder
encoder = new Encoder

# Kanban modules
log		= require './../../node/log'

# Variables
db = null

code = (user, callback) ->

	hash = ->

		currentDate = (new Date()).valueOf().toString()
		random = Math.random().toString()
		return crypto.createHash('sha1').update(currentDate + random).digest('hex')

	flatten = (array) ->

		###
		Description:	Turns an array with objects into an array
		Return:			Array[]
		###

		final = []

		for x in array
			do (x) ->

				final.push x.title

		return final

	generate = ->

		###
		Description:	Generates a valid code using the userID and a hash
		Return:			String
		###

		_hash = hash().substr 0, 8
		_user = if user < 10 then '0' + user else user

		return _user + _hash

	unique = (code, callback) ->

		###
		Description:	Checks if the given code is unique
		Return:			Boolean
		###

		db.source.query 'SELECT title FROM lychee_albums', (err, rows) ->

			if err?

				# Could not get codes
				log.error 'create', 'Could not get list of existing codes', err

				callback false
				return false

			else

				rows = flatten(rows)

				# Check if code exists in array
				index = _.indexOf rows, code

				# Return if code is unique
				callback index is -1
				return true

	looper = ->

		###
		Description:	Runs as long as an unique code has been found
		Return:			String
		###

		_code = generate()

		unique _code, (result) ->

			if result is true

				callback _code
				return true

			else

				looper()
				return false

	looper()

qr = (code) ->

	file	= "#{ code }.png"
	path	= './cache/' + file

	encoder.encode code, path

	return file

flyer = (user, callback) ->

	###
	Description:	Generates a json with qr and code
	Return:			JSON
	###

	data = {}

	# Get code
	code user, (_code) ->

		# Save code
		data.code = _code

		# Get qr image
		data.qr = qr data.code

		# Return data
		callback data
		return true

url = (user, number, callback) ->

	###
	Description:	Generates a json and converts it to a url
	Return:			String
	###

	# Get user info
	db.users.me user, (_user) ->

		flyers = []

		async.whilst ->

			return number isnt 0

		, (callback) ->

			flyer user, (_flyer) ->
				flyers.push _flyer
				number--
				callback()

		, (err) ->

			# Build json
			data =
				photographer:
					name: _user.name
					mail: _user.primarymail
				flyers: flyers

			# Parse url
			url = encodeURIComponent JSON.stringify(data)

			# Return data
			callback url

module.exports = (app, _db) ->

	db = _db

	url 1, 30, (data) ->
		console.log data