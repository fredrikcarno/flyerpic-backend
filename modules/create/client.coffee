m.add m.create =

	title: 'Create'

	init: ->

		# Do something

	show: ->

		modal.show
			body:	"""
					<h1>{{ create.dialog.title }}</h1>
					<p>{{ create.dialog.description }}</p>
					<div id="type" class="dropdown" data-value="pdf">
						<div class="front text"><span>PDF A4 with Codes</span></div>
						<div class="back">
							<ul>
								<li data-value="pdf">PDF A4 with Codes</li>
								<li data-value="template">PDF A4 without Codes</li>
								<li data-value="codes">PDF A4 Codes only</li>
							</ul>
						</div>
					</div>
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
					fn: m.create.get

	get: (data) ->

		action = $('#type').data 'value'

		modal.close()

		switch action
			when 'pdf'
				params	= "api/m/create/url/pdf?number=#{ data.number }"
			when 'template'
				params	= "api/m/create/url/template"
			when 'codes'
				params	= "api/m/create/url/codes?number=#{ data.number }"

		url = 'http://localhost:8888/flyers/01/index.html'

		kanban.api params, (data) ->

			params = "api/m/create/output/pdf?url=#{ url }&data=#{ data }"

			kanban.api params, (file) ->

				window.open file