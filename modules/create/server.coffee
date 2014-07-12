# Dependencies
async		= require 'async'
crypto		= require 'crypto'
joi			= require 'joi'
_			= require 'underscore'
phantom		= require 'node-phantom'
validator	= require 'validator'
Encoder 	= require('qr').Encoder
encoder 	= new Encoder

# Kanban modules
log			= require './../../node/log'
middleware	= require './../../node/middleware'

# Variables
db = null

hash = ->

	###
	Description:	Generates a good readable 20 chars long random hash
	Return:			String
	###

	value = crypto.randomBytes(20).toString('hex')
	value = value.replace /[01liao]/g, ''

	if value.length < 20 then return hash()
	else return value.substr(0, 20)

code = (user, callback) ->

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

	###
	Description:	Generates the QR-File based on the code
	Return:			String
	###

	# Validate code
	if not code? or not validator.isAlphanumeric code
		return false

	file	= "#{ code }.png"
	path	= './cache/' + file

	# Generate QR-File
	encoder.encode code, path

	return file

flyer = (user, callback) ->

	###
	Description:	Generates a json with qr and code
	Return:			Err, JSON
	###

	data = {}

	# Validate user
	if not user?
		callback { error: 'Invalid value for user', details: null }
		return false

	# Get code
	code user, (_code) ->

		# Validate code
		if not _code? or not validator.isAlphanumeric _code
			callback { error: 'Invalid returned code', details: null }
			return false

		# Save code
		data.code = _code

		# Make qr image
		if qr(data.code) is false
			callback { error: 'Could not generate QR-File', details: null }
			return false

		# Return data
		callback null, data
		return true

url = (type, cutlines, user, number, callback) ->

	###
	Description:	Generates a json and converts it to a url
	Return:			Err, String
	###

	# Validate type
	if not type?
		callback { error: 'Invalid data for variable type', details: null }
		return false

	# Validate user
	if not validator.isInt user
		callback { error: 'Invalid data for variable user', details: null }
		return false

	# Validate number
	if not validator.isInt number
		callback { error: 'Invalid data for variable number', details: null }
		return false

	# Turn number into pages
	# 4 flyers per page
	number = number * 4

	# Get user info
	db.users.me user, (_user) ->

		flyers = []

		async.whilst ->

			return number isnt 0

		, (callback) ->

			flyer user, (err, _flyer) ->

				if err?
					callback err
					return false
				else
					flyers.push _flyer
					number--
					callback()

		, (err) ->

			# Handle err
			if err?
				callback err
				return false

			# Build json
			data =
				photographer:
					name: _user.name
					mail: _user.primarymail
					template: false
					codes: false
					cutlines: true
				flyers: flyers

			# Set type
			switch type
				when 'template'
					data.template = true
				when 'codes'
					data.codes = true

			# Set cutlines
			if cutlines is 'false'
				data.cutlines = false

			# Parse url
			_url = encodeURIComponent JSON.stringify(data)

			# Return data
			callback null, _url

output = (_url, data, callback) ->

	###
	Description:	Generates a pdf from the flyers html and generated data
	Return:			Err, Boolean
	###

	# Validate _url
	if not validator.isURL _url
		callback { error: 'Invalid data for variable url', details: null }
		return false

	# Validate data
	if not data?
		callback { error: 'Invalid data for variable data', details: null }
		return false

	# Concat url and data
	_url = _url + '#' + data

	phantom.create (err, ph) ->

		if err?
			callback { error: 'Unable to init phantom', details: err }
			return false

		ph.createPage (err, page) ->

			if err?
				callback { error: 'Unable to create page for pdf', details: err }
				return false

			file		= "cache/#{ hash() }.pdf"
			paperSize	= { format: 'A4', orientation: 'portrait', margin: '0.3cm' }

			page.set 'paperSize', paperSize, ->
				page.open _url, (err, status) ->

					if status isnt 'success' or err?

						callback { error: 'Unable to load the flyer url', details: null }
						return false

					else

						setTimeout ->
							page.render file, ->
								callback null, file
								return true
						, 200

module.exports = (app, _db) ->

	db = _db

	app.get '/api/m/create/url/pdf', middleware.auth, (req, res) ->

		url 'pdf', true, req.session.user, req.query.number, (err, data) ->

			if err?
				log.error 'create', err.error, err.details
				res.json err
				return false
			else
				res.json data
				return true

	app.get '/api/m/create/url/template', middleware.auth, (req, res) ->

		url 'template', true, req.session.user, 0, (err, data) ->

			if err?
				log.error 'create', err.error, err.details
				res.json err
				return false
			else
				res.json data
				return true

	app.get '/api/m/create/url/codes', middleware.auth, (req, res) ->

		url 'codes', true, req.session.user, req.query.number, (err, data) ->

			if err?
				log.error 'create', err.error, err.details
				res.json err
				return false
			else
				res.json data
				return true

	app.get '/api/m/create/output/pdf', middleware.auth, (req, res) ->

		output req.query.url, req.query.data, (err, file) ->

			if err? or not file?
				log.error 'create', err.error, err.details
				res.json err
				return false
			else
				res.json file
				return true