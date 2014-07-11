m.add m.create =

	title: 'Create'

	init: ->

		# Do something

	show: ->

		$(document).on 'click', '.dropdown .back ul li', ->
			if $(this).data('value') is 'template'
				$('.modal input.text[data-name="number"]').hide()
			else
				$('.modal input.text[data-name="number"]').show()

		modal.show
			body:	"""
					<h1>{{ create.dialog.title }}</h1>
					<p>{{ create.dialog.description }} <a href="#">{{ create.dialog.help }}</a></p>
					<div id="type" class="dropdown" data-value="pdf">
						<div class="front text"><span>{{ create.dialog.dropdown.pdf.title }}</span></div>
						<div class="back">
							<ul>
								<li data-value="pdf">
									{{ create.dialog.dropdown.pdf.title }}
									<span>{{ create.dialog.dropdown.pdf.info }}</span>
								</li>
								<li class="separator"></li>
								<li data-value="template">
									{{ create.dialog.dropdown.template.title }}
									<span>{{ create.dialog.dropdown.template.info }}</span>
								</li>
								<li data-value="codes">
									{{ create.dialog.dropdown.codes.title }}
									<span>{{ create.dialog.dropdown.codes.info }}</span>
								</li>
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

		data.action = $('#type').data 'value'

		# Check input when value required
		# Value is irrelevant when type is template
		if data.action isnt 'template'

			# Is value available and between 0 and 101?
			if	not data?.number? or
				not (data.number > 0 and data.number <= 100)

					# Invalid number
					modal.error 'number'
					return false

		modal.close()

		# Set type
		switch data.action
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