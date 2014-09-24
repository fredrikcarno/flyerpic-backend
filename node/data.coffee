# Dependencies
fs = require 'fs'

# Backend modules
log = require './log'

data = module.exports =

	dir: 'data/'

	store: (name, data, callback) ->

		log.status 'data', "Saving #{ name }"

		fs.writeFile module.exports.dir + name, data, (error) ->

			if error
				log.error 'data', "Could not save #{ name }", error
				return false

			callback()
			return true