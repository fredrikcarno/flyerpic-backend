# Dependencies
jsesc		= require 'jsesc'
async		= require 'async'

# Kanban modules
log			= require './log'
login		= require './login'
middleware	= require './middleware'
session		= require './session'

error =

	e401: (req, res) ->

		res.json 401, { error: 'You are not authorized to view this page' }
		return true

module.exports = (app, callback) ->

	log.status 'api', 'Setting routes'

	# Session
	app.all '/api/session/init', session.init
	app.get '/api/session/login', session.login
	app.all '/api/session/logout', session.logout

	# Login
	app.get '/api/login/set', login.set
	app.get '/api/login/reset', middleware.auth, login.reset

	# Error
	app.all '/401', error.e401

	callback()