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

	loading: ->

		modal.show
			body:	"""
					<h1>Creating Flyers</h1>
					<p>Please wait till your flyers are generated. This process can take a while.</p>
					<div class="spinner">
						<div class="rect1"></div>
						<div class="rect2"></div>
						<div class="rect3"></div>
						<div class="rect4"></div>
						<div class="rect5"></div>
					</div>
					"""
			closable: false
			class: 'login'
			buttons:
				cancel:
					title: ''
					fn: -> modal.close()
				action:
					title: ''
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

		# Set type
		switch data.action
			when 'pdf'
				params	= "api/m/create/url/pdf?number=#{ data.number }"
			when 'template'
				params	= "api/m/create/url/template"
			when 'codes'
				params	= "api/m/create/url/codes?number=#{ data.number }"

		url = 'http://localhost:8888/flyers/01/index.html'

		# Show loading dialog
		m.create.loading()

		kanban.api params, (data) ->

			# Stop when data is invalid
			if data is false
				modal.close()
				return false

			params = "api/m/create/output/pdf?url=#{ url }&data=#{ data }"

			kanban.api params, (file) ->

				# Stop when data is invalid
				if file is false
					modal.close()
					return false

				modal.close()
				window.open file