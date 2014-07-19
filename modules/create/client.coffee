m.add m.create =

	title: 'Create'

	init: ->

		# Do something

	show: ->

		$(document).on 'click', '.dropdown[data-name="action"] .back ul li', ->
			if $(this).attr('data-value') is 'template'
				$('.modal .dropdown[data-name="number"]').hide()
			else
				$('.modal .dropdown[data-name="number"]').show()

		modal.show
			body:	"""
					<h1>{{ create.dialog.title }}</h1>
					<p>{{ create.dialog.description }} <a href="#">{{ create.dialog.help }}</a></p>
					<div class="dropdown" data-name="action" data-value="pdf">
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
					<div class="dropdown" data-name="cutlines" data-value="true">
						<div class="front text"><span>Include cutting lines</span></div>
						<div class="back">
							<ul>
								<li data-value="true">
									Include cutting lines
								</li>
								<li data-value="false">
									Exclude cutting lines
								</li>
							</ul>
						</div>
					</div>
					<div class="dropdown" data-name="number" data-value="-">
						<div class="front text"><span>{{ create.dialog.input.placeholder }}</span></div>
						<div class="back">
							<ul>
								<li data-value="1">
									4 {{ create.dialog.input.number }}
									<span>1 A4 Pages</span>
								</li>
								<li data-value="5">
									20 {{ create.dialog.input.number }}
									<span>5 A4 Pages</span>
								</li>
								<li data-value="10">
									40 {{ create.dialog.input.number }}
									<span>10 A4 Pages</span>
								</li>
								<li data-value="15">
									60 {{ create.dialog.input.number }}
									<span>15 A4 Pages</span>
								</li>
								<li data-value="20">
									80 {{ create.dialog.input.number }}
									<span>20 A4 Pages</span>
								</li>
								<li data-value="25">
									100 {{ create.dialog.input.number }}
									<span>25 A4 Pages</span>
								</li>
							</ul>
						</div>
					</div>
					"""
			class: 'login'
			buttons:
				action:
					title: '{{ create.dialog.confirm }}'
					color: 'normal'
					fn: m.create.get

	loading: ->

		modal.show
			body:	"""
					<h1>{{ create.loading.title }}</h1>
					<p>{{ create.loading.description }}</p>
					<div class="spinner"><span class="dot"></span></div>
					"""
			class: 'login'

	get: (data) ->

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
				params	= "api/m/create/url/pdf?cutlines=#{ data.cutlines }&number=#{ data.number }"
			when 'template'
				params	= "api/m/create/url/template?cutlines=#{ data.cutlines }"
			when 'codes'
				params	= "api/m/create/url/codes?cutlines=#{ data.cutlines }&number=#{ data.number }"

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