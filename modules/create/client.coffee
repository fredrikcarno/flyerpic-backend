m.add m.create =

	title: 'Create'

	init: ->

		# Do something

	show: ->

		modal.show
			body:	"""
					<h1>{{ create.dialog.title }}</h1>
					<p>{{ create.dialog.description }}</p>
					<input class="text" type="text" placeholder="{{ create.dialog.input.number }}" data-name="number">
					"""
			closable: true
			class: 'login'
			buttons:
				cancel:
					title: '{{ create.dialog.close }}'
					fn: -> modal.close()
				action:
					title: '{{ create.dialog.confirm }}'
					color: 'normal'
					icon: ''
					fn: m.create.get.pdf

	get:

		pdf: (data) ->

			modal.close()

			params	= "api/m/create/url/pdf?number=#{ data.number }"
			url		= 'http://localhost:8888/flyers/01/index.html'

			kanban.api params, (data) ->

				params = "api/m/create/generate/pdf?url=#{ url }&data=#{ data }"

				kanban.api params, (data) ->

					alert data
					#window.open url + data