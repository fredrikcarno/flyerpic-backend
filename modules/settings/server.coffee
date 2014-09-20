# Dependencies
async		= require 'async'
validator	= require 'validator'

# Kanban modules
log			= require './../../node/log'
middleware	= require './../../node/middleware'

# Variables
db = null

module.exports = (app, _db) ->

	db = _db

	app.get '/api/m/settings/mail', middleware.auth, (req, res) ->

		return true