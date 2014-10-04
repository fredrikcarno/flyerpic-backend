# Dependencies
zbarimg		= require 'zbarimg'
async		= require 'async'
validator	= require 'validator'
querystring	= require 'querystring'

# Backend modules
log			= require './../../node/log'
middleware	= require './../../node/middleware'

# Variables
db			= null
config		= require './../../data/config.json'

addAlbum = (title, shared, visible, downloadable, callback) ->

	###
	Description:	Add a album to Lychee
	Return:			Err, Integer
					Integer is the ID of the album
	###

	if not title?			then title = 'Unnamed'
	if not shared?			then shared = 0
	if not visible?			then visible = 1
	if not downloadable?	then downloadable = 1

	sysstamp = Math.round(new Date().getTime() / 1000)

	db.source.query 'INSERT INTO lychee_albums (title, sysstamp, public, visible, downloadable) VALUES (?, ?, ?, ?, ?)', [title, sysstamp, shared, visible, downloadable], (err, row) ->

		callback err, row.insertId
		return true

addTempAlbum = (callback) ->

	###
	Description:	Add temp-album to Lychee
	Return:			Err, Integer
					Integer is the ID of the album
	###

	sysstamp	= Math.round(new Date().getTime() / 1000)
	title		= "[TEMP] #{ sysstamp }"

	db.source.query 'INSERT INTO lychee_albums (title, sysstamp, public, visible, downloadable) VALUES (?, ?, 0, 0, 0)', [title, sysstamp], (err, row) ->

		callback err, row.insertId
		return true

getAlbum = (title, callback) ->

	###
	Description:	Get the id of an album based on the title
					Adds a new album when title not found
	Return:			Err, Integer
					Integer is the ID of the album
	###

	if	not title? or
		title is ''

			callback 'Title missing or empty'
			return false

	# Get id of album
	db.source.query 'SELECT id FROM lychee_albums WHERE title = ? LIMIT 1', [title], (err, rows) ->

		if err?

			# Database error
			log.error 'import', 'Could not get album from database', err
			callback err, null
			return false

		if not rows[0]?.id?

			# Album not found => Add new album
			addAlbum title, 1, 0, 1, callback
			return true

		# Save id
		id = rows[0].id

		# Return the id of the album
		callback null, id
		return true

setAlbum = (id, tag, callback) ->

	###
	Description:	Moves a photo and its watermarked version to an album
	Return:			Err
	###

	if	not id? or
		id is ''

			callback 'Album id missing for moving photo to album'
			return false

	if	not tag? or
		tag is ''

			callback 'Missing identifier tag for moving photo to album'
			return false

	# Move photo to album
	db.source.query "UPDATE lychee_photos SET album = ? WHERE tags LIKE '%#{ tag }%'", [id], (err, rows) ->

		if err?

			# Database error
			log.error 'import', 'Could not set album of photo', err
			callback err
			return false

		# Photos moved successful
		callback null
		return true

scanAlbum = (id, callback) ->

	###
	Description:	Scans and sorts an album of Lychee
	Return:			Err, JSON
					JSON contains the scanned QR-Code and the corresponding photos
	###

	if	not id? or
		not validator.isAlphanumeric(id)

			callback 'ID needs to be alphanumeric', null

	orderedRows = []
	unknownRows = []

	scan = (row, callback) ->

		filename = config.lychee.path + 'uploads/big/' + row.url

		# Scan photo
		zbarimg filename, (err, code) ->

			if	err? and
				err.message isnt 'No QR-Code found or barcode not supported'

					log.error 'import', 'Spawn new process failed. Could not scan code on photo.', err

			# Save code
			if code?
				row.code = code
				row.code = row.code.replace "#{ config.url }redirect.html#redirect/", ''
			else row.code = ''

			# Reduce photo json
			row = {
				id: row.id
				title: row.title
				url: config.lychee.url + 'uploads/thumb/' + row.thumbUrl
				takestamp: row.takestamp
				code: row.code
				tags: row.tags
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

				# Add to existing session
				orderedRows[orderedRows.length-1].push row

				if unknownRows.length isnt 0

					# Add previous unknown sessions to last session
					orderedRows[orderedRows.length-1] = orderedRows[orderedRows.length-1].concat unknownRows
					unknownRows = []

			else

				# Add to unknown session
				unknownRows.push row

		callback null, row

	# Get photos of album from db
	db.source.query "SELECT * FROM lychee_photos WHERE album = ? AND tags NOT LIKE '%watermarked%' ORDER BY takestamp ASC", [id], (err, rows) ->

		if err?

			log.error 'import', 'Could not get list of photos from database', err
			callback 'Could not get list of photos from database', null
			return false

		# Scan all photos
		async.mapLimit rows, 3, scan, (err, rows) ->

			if err?

				log.error 'import', 'Could not scan photos', err
				callback 'Could not scan photos', null
				return false

			# Order by code
			async.mapSeries rows, order, (err, rows) ->

				# Check if there are still photos in unknownRows
				if unknownRows.length isnt 0

					# Create placeholder photo which will be handled as the QR photo
					row = {
						id: 'placeholder' + new Date().getTime()
						title: ''
						url: 'assets/img/qrcode.svg'
						takestamp: 0
						code: 'Unknown Session'
						tags: ''
					}

					# Add rest as new session
					unknownRows.unshift row
					orderedRows.push unknownRows

				callback err, orderedRows

setStructure = (structure, callback) ->

	###
	Description:	Moves all photos from the temp-album to their own reserved album
					based on the QR and the given and verified structure
	Return:			Err
	###

	# Check structure
	if	not structure? or
		structure is ''

			# Parameter error
			callback 'Could not parse structure'
			return false

	# Convert structure
	structure = JSON.parse structure

	# For each session in structure
	async.map structure, (session, callback) ->

		# Get id of album
		getAlbum session[0].code, (err, id) ->

			if	err? or
				not id?

					callback 'Could not get album with code', session
					return false

			# For each photo in session
			async.map session, (photo, callback) ->

				# Check if photo is a photo without code
				# Only photos without a code will be moved
				if photo.code is ''

					# Move photo to album
					setAlbum id, photo.tags, (err) ->

						callback err, photo
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

		addTempAlbum (err, id) ->

			if err? or not id?
				log.error 'import', 'Unable to add temp-album to Lychee', err
				res.json { error: 'Unable to add temp-album to Lychee', details: err }
				return false
			else
				res.json id
				return true

	app.get '/api/m/import/scanAlbum', middleware.auth, (req, res) ->

		scanAlbum req.query.id, (err, data) ->

			if err?
				log.error 'import', 'Could not scan sessions', err
				res.json { error: 'Could not scan sessions', details: err }
				return false
			else
				res.json data
				return true

	app.get '/api/m/import/setStructure', middleware.auth, (req, res) ->

		setStructure req.query.structure, (err) ->

			if err?
				log.error 'import', 'Could not apply the given structure', err
				res.json { error: 'Could not apply the given structure', details: err }
				return false
			else
				res.json true
				return true