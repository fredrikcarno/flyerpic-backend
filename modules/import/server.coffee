# Dependencies
zbarimg		= require 'zbarimg'
async		= require 'async'

# Kanban modules
log			= require './../../node/log'
middleware	= require './../../node/middleware'

# Variables
db			= null
config		= require './../../data/config.json'

addAlbum = (callback) ->

	###
	Description:	Add temp-album to Lychee
	Return:			Err, Integer
					Integer is the ID of the album
	###

	sysstamp	= Math.round(new Date().getTime() / 1000)
	name		= "[TEMP] #{ sysstamp }"

	db.source.query "INSERT INTO lychee_albums (title, sysstamp, public, visible) VALUES ('#{ name }', '#{ sysstamp }', '0', '0')", (err, row) ->

		callback err, row.insertId
		return true

scanAlbum = (id, callback) ->

	###
	Description:	Scans and sorts an album of Lychee
	Return:			Err, JSON
					JSON contains the scanned QR-Code and the corresponding photos
	###

	# TODO: Check if id is numeric

	orderedRows = []

	scan = (row, callback) ->

		filename = config.lychee.path + 'uploads/big/' + row.url

		# Scan photo
		zbarimg filename, (err, code) ->

			# Save code
			if code? then row.code = code
			else row.code = ''

			# Reduce photo json
			row = {
				id: row.id
				title: row.title
				url: config.lychee.url + 'uploads/thumb/' + row.thumbUrl
				takestamp: row.takestamp
				code: row.code
			}

			callback null, row

	order = (row, callback) ->

		# If photo with code
		if row.code isnt ''

			orderedRows.push [row]

		# If photo without code
		else

			# Check if a session exists
			if orderedRows.length > 0
				# TODO: Do not ignore skipped photos
				orderedRows[orderedRows.length-1].push row

		callback null, row

	# Get photos of album from db
	db.source.query "SELECT * FROM lychee_photos WHERE album = '#{ id }' ORDER BY takestamp ASC", (err, rows) ->

		# Scan all photos
		async.map rows, scan, (err, rows) ->

			# Order by code
			async.mapSeries rows, order, (err, rows) ->
				callback err, orderedRows

setStructure = (structure, callback) ->

	###
	Description:	Moves all photos from the temp-album to their own reserved album
					based on the QR and the given and verified structure
	Return:			Err
	###

	# Convert structure
	structure = JSON.parse structure

	# For each session in structure
	async.map structure, (session, callback) ->

		# Get code of first photo
		code = session[0].code

		if	not code? or
			code is ''

				callback 'Code not found in session', session
				return false

		# Get id of album
		db.source.query "SELECT id FROM lychee_albums WHERE title = '#{ code }' LIMIT 1", (err, rows) ->

			if err?

				# Database error
				callback err, session
				return false

			if	not rows? or
				not rows[0].id?

					# Album not found
					callback "No album with the code '#{ code }' found", session
					return false

			# Save id
			id = rows[0].id

			# For each photo in session
			async.map session, (photo, callback) ->

				if photo.code is ''

					# Move photo to album
					db.source.query "UPDATE lychee_photos SET album = '#{ id }' WHERE id = '#{ photo.id }';", (err, rows) ->

						if err?

							# Database error
							callback err, photo
							return false

						else

							callback null, photo
							return true

				else

					# Skip photo
					callback null, photo
					return true

			, (err, rows) ->

				callback err, session

	, (err, rows) ->

		callback err

module.exports = (app, _db) ->

	db = _db

	app.get '/api/m/import/getLychee', middleware.auth, (req, res) ->

		res.json config.lychee
		return true

	app.get '/api/m/import/addAlbum', middleware.auth, (req, res) ->

		addAlbum (err, id) ->

			if err? or not id?
				res.json { error: 'Unable to add temp-album to Lychee', details: err }
				return false
			else
				res.json id
				return true

	app.get '/api/m/import/scanAlbum', middleware.auth, (req, res) ->

		scanAlbum req.query.id, (err, data) ->

			if err?
				res.json { error: 'Could not scan sessions', details: err }
				return false
			else
				res.json data
				return true

	app.get '/api/m/import/setStructure', middleware.auth, (req, res) ->

		setStructure req.query.structure, (err) ->

			if err?
				res.json { error: 'Could not apply the given structure', details: err }
				return false
			else
				res.json true
				return true