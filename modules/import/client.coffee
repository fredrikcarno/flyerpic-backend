m.add m.import =

	title: 'Import'
	url: null
	sessions: null

	init: ->

		# Render
		m.import.dom().append m.import.render.upload()

		# Bind
		m.import.bind()

		# Authenticate
		m.import.getLychee()

	bind: ->

		# Define shorthand
		dom = m.import.dom

		dom('#upload_files').on 'change', -> m.import.step[1](this.files)

		$(document)
			.on 'click', '.verify .code a.edit', m.import.edit.rename
			.on 'click', '.verify .photo .overlay', m.import.edit.show
			.on 'click', '.verify .button.cancel', -> $('.verify_overlay').remove()
			.on 'click', '.verify .button.action', m.import.step[4]

	getLychee: ->

		# Request Lychee credentials
		kanban.api "api/m/import/getLychee", (data) ->

			# Validate response
			if	not data? or
				not data.url? or
				not data.token?

					# Data invalid
					notification.show {
						icon: 'alert-circled'
						text: 'Could not request Lychee credentials from server'
					}
					return false

			# Save data
			m.import.url	= data.url + 'php/api.php'
			m.import.token	= data.token

	step: [

		# Step 01
		# Show upload instructions
		->

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
						fn: -> m.import.dom('#upload_files').click()

		# Step 02
		# Upload photos
		, (files) ->

			globalProgress = 0

			# Add temp-album to Lychee
			addAlbum = (callback) ->

				kanban.api 'api/m/import/addAlbum', (id) ->

					if id >= 0 then callback id

			# Upload process
			process = (id, files, file) ->

				formData	= new FormData()
				xhr			= new XMLHttpRequest()
				progress	= 0
				preProgress	= 0

				finish = ->

					m.import.dom('#upload_files').val ''
					m.import.step[2] id

				# Check if file is supported
				if file.supported is false

					# Skip file
					if file.next?

						# Upload next file
						process id, files, file.next

					else

						# Look for supported files
						# If zero files are supported, hide the upload after a delay

						hasSupportedFiles = false

						# For each file
						$.each files, (i, file) ->

							if file.supported is true
								hasSupportedFiles = true

						if hasSupportedFiles is false then finish()

					return false

				formData.append 'function', 'upload'
				formData.append 'albumID', id
				formData.append 'token', m.import.token
				formData.append 0, file

				xhr.open 'POST', m.import.url

				xhr.onload = ->

					# On success
					if xhr.status is 200

						file.ready = true;
						wait = false;

						# Check if there are file which are not finished
						# For each file
						$.each files, (i, file) ->

							if file.ready is false
								wait = true

						# Finish upload when all files are finished
						if wait is false then finish()

				xhr.upload.onprogress = (e) ->

					if e.lengthComputable

						# Calculate progress
						progress		= (e.loaded / e.total * 100 | 0) / files.length
						globalProgress	= globalProgress - preProgress + progress
						preProgress		= progress

						if progress >= (100 / files.length)

							# Upload next file
							if file.next? then process id, files, file.next

				xhr.send formData

			# Check if files are selected
			if files.length <= 0 then return false

			# For each file
			$.each files, (i, file) ->

				file.num		= i
				file.ready		= false
				file.supported	= true
				file.next		= if i < (files.length-1) then files[i+1] else null

				# Check if file is supported
				if	file.type isnt 'image/jpeg' and
					file.type isnt 'image/jpg' and
					file.type isnt 'image/png' and
					file.type isnt 'image/gif'

						# File not supported
						file.ready		= true
						file.supported	= false

			# Show loading modal
			modal.show
				body:	"""
						<h1>{{ import.upload.title }}</h1>
						<p>{{ import.upload.description }}</p>
						<div class="progress">
							<div class="bar"><span>0%</span></div>
						</div>
						"""
				class: 'login'

			# Update progress
			p = ->
				htmlProgress = Math.round(globalProgress) + '%'
				if globalProgress <= 99
					$('.modal .progress .bar').css 'width', htmlProgress
					$('.modal .progress .bar span').html htmlProgress
					setTimeout p, 100
				else
					$('.modal .progress .bar').css 'width', '100%'
					$('.modal .progress .bar span').html 'Processing'

			# Start progress update
			p()

			# Create temp-album
			addAlbum (id) ->

				# Upload first file
				process id, files, files[0]

		# Step 03
		# Show scan loading-modal
		, (id) ->



			modal.show
				body:	"""
						<h1>{{ import.scan.title }}</h1>
						<p>{{ import.scan.description }}</p>
						<div class="spinner qr">
							<img src="assets/img/qrcode.svg">
							<div class="scan"></div>
						</div>
						"""
				class: 'login'

			# Start scanning
			kanban.api "api/m/import/scanAlbum?id=#{ id }", (sessions) ->

				# Validate response
				if	not sessions? or
					sessions is false

						# Data invalid
						notification.show {
							icon: 'alert-circled'
							text: 'Could not scan sessions'
						}
						return false

				# Show verify-dialog
				m.import.step[3] id, sessions

		# Step 04
		# Show the verify dialog
		, (id, sessions) ->

			# Save sessions
			m.import.sessions = sessions

			# Close scanning-modal
			modal.close()

			# Show verify-modal
			m.import.dom().append m.import.render.verify(id, m.import.sessions)

			# TODO: Adjust wrapper height

		# Step 05
		# Apply the verified structure
		, ->

			console.log m.import.sessions

			# Convert structure
			structure = JSON.stringify m.import.sessions

			# Send structure
			kanban.api "api/m/import/setStructure?structure=#{ structure }", (data) ->

				if	not data? or
					data isnt true

						# Sorting failed
						return false

				# Hide verify-modal
				$('.verify_overlay').remove()

				# TODO: Show final success dialog

	]

	find: (id, callback) ->

		x = 0
		y = 0

		found = false

		# For each session
		for session in m.import.sessions
			do (session) ->

				# Reset photo
				y = 0

				# For each photo
				for photo in session
					do (photo) ->

						# Is chosen photo
						if	"#{ photo.id }" is id or
							photo.id is id

								callback x, y
								found = true

						# Next photo
						y++

				# Next session
				x++

		if found is false
			callback null, null

	edit:

		show: (e) ->

			# Save element
			that = this

			# Set active status
			$(this).addClass 'active'

			# Get id of photo
			id = $(this).parent().attr('data-id')

			# Get code of parent session
			code = $(this).parent().parent().attr('data-code')

			items = [
				{ type: 'item', title: 'Full photo', icon: 'ion-arrow-expand', fn: -> m.import.edit.full(id, that) }
				{ type: 'separator' }
				{ type: 'item', title: 'Remove photo', icon: 'ion-trash-b', fn: -> m.import.edit.remove(id, that) }
			]

			# Add separator
			if m.import.sessions.length > 1
				items.push { type: 'separator' }

			for session in m.import.sessions
				do (session) ->

					if session[0].code isnt code
						items.push { type: 'item', title: session[0].code, icon: 'ion-forward', fn: -> m.import.edit.move(id, session[0], that) }

			context.show items, e, ->

				$(that).removeClass 'active'
				context.close()

		rename: () ->

			that = this

			id = $(that).attr('data-id')
			console.log id

			m.import.find id, (x, y) ->

				return false if not x? or not y?

				name = window.prompt 'Please correct the code for this session:', m.import.sessions[x][0].code

				if	name? and
					name isnt ''

						m.import.sessions[x][0].code = name
						$(that).parent().find('span').html name

		full: (id, that) ->

			$(that).removeClass 'active'
			context.close()

			m.import.find id, (x, y) ->

				return false if not x? or not y?

				# Convert to @2x
				url = m.import.sessions[x][y].url
				url = url.slice(0, -5) + '@2x.jpeg'

				# Open image
				window.open url

		remove: (id, that) ->

			context.close()

			m.import.find id, (x, y) ->

				return false if not x? or not y?

				# Remove from array
				m.import.sessions[x].splice y, 1

				# Remove from DOM
				$(that).parent().remove()

		move: (id, to, that) ->

			$(that).removeClass 'active'
			context.close()

			m.import.find id, (x, y) ->

				return false if not x? or not y?

				m.import.find to.id, (toX, toY) ->

					return false if not toX? or not toY?

					# Get
					temp = m.import.sessions[x][y]

					# Remove
					m.import.sessions[x].splice y, 1

					# Add
					m.import.sessions[toX].push temp

					# Remove from DOM
					elem = $(that).parent().detach()
					m.import.dom(".structure .session[data-code='#{ to.code }']").append elem

	render:

		upload: ->

			"""
			<div id="upload">
				<input id="upload_files" type="file" name="fileElem[]" multiple accept="image/*">
			</div>
			"""

		verify: (id, sessions) ->

			"""
			<div class="verify_overlay">
				<div class="verify">
					<div class="header">
						<h1>Confirm structure</h1>
						<p>Please check and confirm the shown structure of your scanned photos. Mark errors, wrong groupings and incorrect scanned codes to avoid wrong photos in wrong sessions.</p>
						<div class="buttons">
							<a class="button cancel">Cancel</a>
							<a class="button action"><span class="ion-checkmark"></span>Confirm structure</a>
						</div>
					</div>
					<div class="structure_wrapper">
						<div class="structure">
							#{ (m.import.render.session session for session in sessions).join '' }
						</div>
					</div>
				</div>
			</div>
			"""

		session: (session) ->

			"""
			<div class="session" data-code="#{ session[0].code }">
				<div class="code"><span>#{ session[0].code }</span><a class="edit ion-edit" href="#" data-id="#{ session[0].id }"></a></div>
				#{ (m.import.render.photo photo for photo in session).join '' }
			</div>
			"""

		photo: (photo) ->

			html =	"""
					<div class="photo" data-id="#{ photo.id }">
						<img src="#{ photo.url }">
					"""

			if photo.code is ''

				html +=	"""
						<div class="overlay">
							<a class="icon ion-edit" href="#"></a>
						</div>
						"""

			else

				html +=	"""
						<div class="scanned">
							<a class="icon ion-qr-scanner"></a>
						</div>
						"""

			html +=	"""
					</div>
					"""

			return html