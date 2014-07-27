m.add m.import =

	title: 'Import'

	init: ->

		# Render
		m.import.dom().append m.import.render()

		# Authenticate
		m.import.auth()

	show: ->

		modal.show
			body:	"""
					<h1>{{ import.dialog.title }}</h1>
					<p>{{ import.dialog.description }} <a href="#">{{ import.dialog.help }}</a></p>
					"""
			class: 'login'
			buttons:
				action:
					title: '{{ import.dialog.confirm }}'
					color: 'normal'
					fn: -> $("#import #upload_files").click()

	loading: ->

		# Upload modal

	get: (data) ->

		# Validate data

	auth: ->

		# Request Lychee credentials
		kanban.api "api/m/import/getLychee", (data) ->

			# Validate response
			if	not data? or
				not data.url? or
				not data.username? or
				not data.password?

					# Data invalid
					notification.show {
						icon: 'alert-circled'
						text: "Could not request Lychee credentials from server"
					}
					return false

			# Login into Lychee
			$.ajax
				type: "POST"
				url: data.url + 'php/api.php'
				data:
					function: 'login'
					user: data.username
					password: md5(data.password)
				success: (data) ->

					if data is ''

						# Data invalid
						notification.show {
							icon: 'alert-circled'
							text: "Could not log in to Lychee"
						}

	render: ->

		"""
		<div id="upload">
			<input id="upload_files" type="file" name="fileElem[]" multiple accept="image/*">
		</div>
		"""