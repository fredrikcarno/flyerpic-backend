# Dependencies
async = require 'async'

# Kanban modules
db = require './db'

session = module.exports =

	init: (req, res) ->

		if	req.session?.login? and
			req.session.login is true

				# Logged in
				res.json {
					login: true
					version: process.env.npm_package_version
					configured: true
				}

		else

			db.users.get (users) ->

				# Not logged in
				res.json {
					login: false
					version: process.env.npm_package_version
					name: process.env.npm_package_name
					configured: users.length isnt 0
				}

	login: (req, res) ->

		if	req.query? and
			req.query.username? and
			req.query.password?

				db.users.get (users) ->

					async.each users, (user, finish) ->

						if	req.query.username is user.username and
							req.query.password is user.password

								# Login vaild
								req.session.login = true
								res.json true
								return true

						else finish()

					, (err) ->

						# Login invaild
						res.json false
						return false

		else

			# Required data missing
		 	res.json false
			return false

	logout: (req, res) ->

		delete req.session.login
		res.json true
		return true