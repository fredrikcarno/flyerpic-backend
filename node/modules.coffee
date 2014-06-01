# Dependencies
fs		= require 'fs'
async	= require 'async'

# Kanban modules
log		= require './log'

# Variables
list	= 'cache/modules.json'

modules = module.exports = (app, db, callback) ->

	log.status 'modules', 'Getting list of modules'

	fs.readFile list, (error, data) ->

		if error
			log.error 'modules', "Could not read #{ list }", error
			return false

		# Parse modules
		data = JSON.parse data

		# Load modules
		async.each data, (m, finish) ->

			if m.main?

				log.status 'modules', "Loading #{ m.name }"
				require('./../modules/' + m.name + '/' + m.main) app, db.source
				finish()

			else

				finish()

		, callback