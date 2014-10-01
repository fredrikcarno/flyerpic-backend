m.add m.create =

	title: 'Create'

	init: ->

		return true

	show: ->

		$(document).on 'click', '.dropdown[data-name="action"] .back ul li', ->
			if $(this).attr('data-value') is 'template'
				$('.modal .dropdown[data-name="number"]').hide()
			else
				$('.modal .dropdown[data-name="number"]').show()

		modal.show
			body:	"""
					<h1>{{ create.dialog.title }}</h1>
					<p>{{ create.dialog.description }} <a href="mailto:#{ backend.settings.init.user.helpmail }">{{ create.dialog.help }}</a></p>
					<div class="dropdown" data-name="action" data-value="pdf">
						<div class="front text"><span>{{ create.dialog.type.pdf.title }}</span></div>
						<div class="back">
							<ul>
								<li data-value="pdf">
									{{ create.dialog.type.pdf.title }}
									<span>{{ create.dialog.type.pdf.info }}</span>
								</li>
								<li class="separator"></li>
								<li data-value="template">
									{{ create.dialog.type.template.title }}
									<span>{{ create.dialog.type.template.info }}</span>
								</li>
								<li data-value="codes">
									{{ create.dialog.type.codes.title }}
									<span>{{ create.dialog.type.codes.info }}</span>
								</li>
							</ul>
						</div>
					</div>
					<div class="dropdown" data-name="cutlines" data-value="true">
						<div class="front text"><span>{{ create.dialog.cutlines.true }}</span></div>
						<div class="back small">
							<ul>
								<li data-value="true">
									{{ create.dialog.cutlines.true }}
								</li>
								<li data-value="false">
									{{ create.dialog.cutlines.false }}
								</li>
							</ul>
						</div>
					</div>
					<div class="dropdown" data-name="number" data-value="-">
						<div class="front text"><span>{{ create.dialog.number.placeholder }}</span></div>
						<div class="back">
							<ul>
								<li data-value="1">
									4 {{ create.dialog.number.flyer }}
									<span>1 A4 Pages</span>
								</li>
								<li data-value="5">
									20 {{ create.dialog.number.flyer }}
									<span>5 A4 Pages</span>
								</li>
								<li data-value="10">
									40 {{ create.dialog.number.flyer }}
									<span>10 A4 Pages</span>
								</li>
								<li data-value="15">
									60 {{ create.dialog.number.flyer }}
									<span>15 A4 Pages</span>
								</li>
								<li data-value="20">
									80 {{ create.dialog.number.flyer }}
									<span>20 A4 Pages</span>
								</li>
								<li data-value="25">
									100 {{ create.dialog.number.flyer }}
									<span>25 A4 Pages</span>
								</li>
							</ul>
						</div>
					</div>
					"""
			class: 'login'
			buttons:
				cancel:
					title: ''
					fn: -> modal.close()
				action:
					title: '{{ create.dialog.confirm }}'
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

		backend.api params, (data) ->

			# Stop when data is invalid
			if data is false
				modal.close()
				return false

			params = "api/m/create/output/pdf?url=#{ url }&data=#{ data }"

			backend.api params, (file) ->

				# Stop when data is invalid
				if file is false
					modal.close()
					return false

				modal.close()
				m.create.open file

	open: (file) ->

		modal.show
			body:	"""
					<h1>{{ create.open.title }}</h1>
					<p>{{ create.open.description }} <a href="mailto:#{ backend.settings.init.user.helpmail }">{{ create.dialog.help }}</a></p>
					"""
			class: 'login'
			buttons:
				cancel:
					title: ''
					fn: -> modal.close()
				action:
					title: '{{ create.open.confirm }}'
					fn: ->
						window.open file
						return true