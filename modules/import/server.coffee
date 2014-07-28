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

	decode = (filename) ->



	db.source.query "SELECT * FROM lychee_photos WHERE album = '#{ id }' ORDER BY takestamp ASC", (err, rows) ->

		# For each photo
		for row in rows
			do (row) ->

				filename = config.lychee.url + 'uploads/big/' + row.url
				console.log filename
				decode filename

		callback null, null

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