m.add m.menu =

	title: 'Menu'

	data: [
		{
			id: 'menu_create'
			icon: 'ion-ios7-albums-outline'
			title: '{{ menu.create.title }}'
			description: '{{ menu.create.description }}'
		}
		{
			id: 'menu_upload'
			icon: 'ion-ios7-cloud-upload-outline'
			title: '{{ menu.upload.title }}'
			description: '{{ menu.upload.description }}'
		}
		{
			id: 'menu_settings'
			icon: 'ion-ios7-cog-outline'
			title: '{{ menu.settings.title }}'
			description: '{{ menu.upload.description }}'
		}
	]

	init: ->

		# Render
		m.menu.dom().append m.menu.render.all()

		# Add route
		router.on '/', ->
			setTimeout ->
				m.menu.dom().show()
			, 100

		# Bind menus
		m.menu.bind()

		# Init routes
		router.init()

	bind: ->

		# Define shorthand
		dom = m.menu.dom

		dom('#create, #upload, #settings').on 'click', ->
			router.setRoute '/' + $(this).attr('id')

	render:

		all: ->

			"""
			#{ (m.menu.render.item item for item in m.menu.data).join '' }
			"""

		item: (data) ->

			"""
			<div class='item' id='#{ data.id }'>
				<div class='icon #{ data.icon }'></div>
				<h1 class='title'>#{ data.title }</h1>
				<p class='description'>#{ data.description }</p>
			</div>
			"""