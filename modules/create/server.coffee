# Dependencies
async		= require 'async'
crypto		= require 'crypto'
joi			= require 'joi'
_			= require 'underscore'
phantom		= require 'node-phantom'
validator	= require 'validator'
pdfconcat	= require 'pdfconcat'
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
			do (x) -> final.push x.title

		return final

	generate = ->

		###
		Description:	Generates a valid code using the userID and a hash
		Return:			String
		###

		_hash = hash().substr 0, 8
		_user = if user < 10 then '0' + user else user

		# Replace numbers with unmistakable chars
		replace = {
			'0': 'a'
			'1': 'b'
			'2': 'd'
			'3': 'e'
			'4': 'f'
			'5': 'g'
			'6': 'h'
			'7': 'j'
			'8': 'k'
			'9': 'm'
		}

		# Turn _user into shorthand
		for x of replace
			do (x) -> _user = _user.replace x, replace[x]

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

	reserve = (code, callback) ->

		###
		Description:	Add code as album to avoid equal generated codes
		Return:			Err
		###

		sysstamp = Math.round(new Date().getTime() / 1000)

		db.source.query "INSERT INTO lychee_albums (title, sysstamp, public, visible) VALUES ('#{ code }', '#{ sysstamp }', '1', '0')", (err, rows) ->

			callback err
			return true

	looper = ->

		###
		Description:	Runs as long as an unique code has been found
		Return:			String
		###

		_code = generate()

		# Check if code is unique
		unique _code, (result) ->

			if result is true

				# Reserve code
				reserve _code, (err) ->

					if err?
						callback null
						return false
					else
						callback _code
						return true

			else

				# Generate new code
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
				guide: false
				template: false
				codes: false
				cutlines: true
				photographer:
					name: _user.name
					mail: _user.primarymail
					help: _user.helpmail
				flyers: flyers

			# Set type
			switch type
				when 'pdf'
					data.guide		= 'guides/en.pdf'
				when 'template'
					data.guide		= 'guides/en.pdf'
					data.template	= true
				when 'codes'
					data.guide		= 'guides/en.pdf'
					data.codes		= true

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

	# Set paths
	file = {
		guide: JSON.parse(data).guide		# Path to guide
		flyers: "cache/#{ hash() }.pdf"		# Flyers only
		final: "cache/_#{ hash() }.pdf"		# Flyers with guide
	}

	# Set size of paper
	paperSize	= { format: 'A4', orientation: 'portrait', margin: '0.3cm' }

	phantom.create (err, ph) ->

		if err?
			callback { error: 'Unable to init phantom', details: err }
			return false

		ph.createPage (err, page) ->

			if err?
				callback { error: 'Unable to create page for pdf', details: err }
				return false

			page.set 'paperSize', paperSize, ->
				page.open _url, (err, status) ->

					if status isnt 'success' or err?

						callback { error: 'Unable to load the flyer url', details: null }
						return false

					else

						setTimeout ->
							page.render file.flyers, ->

								if file.guide isnt false

									pdfconcat [file.guide, file.flyers], file.final, (err) ->

										if err?

											callback { error: 'Unable to concat the pdfs', details: err }
											return false

										callback null, file.final
										return true

								else

									callback null, file.flyers
									return true

						, 200

module.exports = (app, _db) ->

	db = _db

	app.get '/api/m/create/url/pdf', middleware.auth, (req, res) ->

		url 'pdf', req.query.cutlines, req.session.user, req.query.number, (err, data) ->

			if err?
				log.error 'create', err.error, err.details
				res.json err
				return false
			else
				res.json data
				return true

	app.get '/api/m/create/url/template', middleware.auth, (req, res) ->

		url 'template', req.query.cutlines, req.session.user, 0, (err, data) ->

			if err?
				log.error 'create', err.error, err.details
				res.json err
				return false
			else
				res.json data
				return true

	app.get '/api/m/create/url/codes', middleware.auth, (req, res) ->

		url 'codes', req.query.cutlines, req.session.user, req.query.number, (err, data) ->

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