this.modules =

	_files:
		css: 'cache/modules.css'
		js: 'cache/modules.js'
		json: 'cache/modules.json'

	_build: (module) ->

		"""
		<div id='#{ module.name }'></div>
		"""

	init: ->

		# Load css and js files
		$('head').append "<link rel='stylesheet' href='#{ modules._files.css }' type='text/css'>"
		$('head').append "<script type='text/javascript' src='#{ modules._files.js }'></script>"

		# Save json
		kanban.api modules._files.json, (data) ->

			return false if not data?

			modules._files.json = data
			return true

		return true

	add: (module) ->

		# Add references
		module.name	= encodeURI(module.title).toLowerCase()
		module.dom	= (elem) -> kanban.dom.module(module.name, elem)

		# Build placeholder
		kanban.dom.content.append modules._build(module)

		# Init module
		module.init()
		# Trigger event
		document.dispatchEvent(
			new CustomEvent 'moduleLoaded', {
				detail:
					name: module.name
			}
		)