this.kanban =

	settings:

		init: null

	init: ->

		# Bind hotkeys
		Mousetrap.bindGlobal 'enter', () ->
			if $('.modalContainer').length isnt 0
				$('.modalContainer #action').addClass('active').click()

		Mousetrap.bindGlobal 'esc', () ->
			if $('.modalContainer[data-closable=true]').length isnt 0
				modal.close()
			else if $('.context').length isnt 0
				context.close()
			else if $('#menu.blur').length isnt 0
				m.settings.hide()

		kanban.api 'api/session/init', (data) ->

			if	data?.configured? and
				data.configured is false

					# Not configured
					login.set()
					return true

			if	data?.login? and
				data.login is true

					# Save data
					kanban.settings.init = data

					# Logged in
					modules.init()
					return true

			if	data?.login? and
				data.login is false

					# Not logged in
					login.show data
					return true

	serialize: (obj) ->

		str = []
		for p of obj
			if obj.hasOwnProperty(p)
				str.push encodeURIComponent(p) + "=" + encodeURIComponent(obj[p])
		return str.join "&"

	api: (url, callback) ->

		# Show notification
		loading = setTimeout ->
			loading = notification.show {
				icon: 'ios7-clock'
				text: 'Still loading ...'
				pin: true
			}
		, 3000

		$.ajax
			type: 'GET'
			url: url
			dataType: 'json'
			error: (jqXHR, textStatus, errorThrown) ->

				# Hide notification
				clearTimeout loading if loading
				notification.close loading if loading >= 100

				errorThrown = 'Unknown' if errorThrown is ''

				# Show error
				notification.show {
					icon: 'alert-circled'
					text: "Request failed and server returned: #{ errorThrown }"
				}
				console.error {
					url: url
					jqXHR: jqXHR
					textStatus: textStatus
					errorThrown: errorThrown
				}
				callback false
				return false

			success: (data) ->

				# Hide notification
				clearTimeout loading if loading
				notification.close loading if loading >= 100

				if data?.error?

					# Show error
					notification.show {
						icon: 'alert-circled'
						text: data.error
					}
					console.error data
					callback false
					return false

				callback data
				return true

	dom:

		content: $('#content')

		module: (name, elem) ->

			if not elem? then return kanban.dom.content.find("##{ name }")
			else return kanban.dom.content.find("##{ name }").find(elem)

	logout: ->

		kanban.api 'api/session/logout', (data) ->
			window.location.reload()

$(document).ready kanban.init