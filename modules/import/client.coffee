m.add m.import =

	title: 'Import'

	init: ->

		# Render
		m.import.dom().append m.import.render()

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

	render: ->

		"""
		<div id="upload">
			<input id="upload_files" type="file" name="fileElem[]" multiple accept="image/*">
		</div>
		"""