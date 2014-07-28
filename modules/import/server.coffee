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
	###

	sysstamp	= Math.round(new Date().getTime() / 1000)
	name		= "[TEMP] #{ sysstamp }"

	db.source.query "INSERT INTO lychee_albums (title, sysstamp, public, visible) VALUES ('#{ name }', '#{ sysstamp }', '0', '0')", (err, row) ->

		callback err, row.insertId
		return true

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