# Dependencies
jsesc		= require 'jsesc'

# Backend modules
db			= require './db'
log			= require './log'
session		= require './session'

login = module.exports =

	set: (req, res) ->

		parse = (req, callback, error) ->

			# Check if required data exists

			if not req.query?
				error 'params'
				return false

			if not req.query.username?
				error 'username'
				return false

			if not req.query.password?
				error 'password'
				return false

			# Escape data

			for key, value of req.query
				value = jsesc value

			callback()
			return true

		db.users.get (users) ->

			if users.length isnt 0

				# Entries found
				res.json { error: 'No permissions to change username and password', details: null }
				return false

			else

				parse req, ->

					db.users.add req.query.username, req.query.password, (err) ->

						if err?

							# Error
							res.json { error: 'Could not store username or password in database', details: err }
							return false

						else

							# Success
							session.login req, res
							return true

				, (err) ->

					# Required data missing
					res.json 400, { error: 'Parameter ' + err + ' required' }
					return false