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
			id: 'menu_import'
			icon: 'ion-ios7-cloud-upload-outline'
			title: '{{ menu.import.title }}'
			description: '{{ menu.import.description }}'
		}
		{
			id: 'menu_settings'
			icon: 'ion-ios7-cog-outline'
			title: '{{ menu.settings.title }}'
			description: '{{ menu.settings.description }}'
		}
	]

	init: ->

		document.addEventListener 'moduleLoaded', (e) ->

			# Wait until the last module has been loaded
			if e.detail.name is 'settings'

				# Render
				m.menu.dom().append m.menu.render.all()

				# Bind menus
				m.menu.bind()

				# Show menus
				setTimeout ->
					m.menu.dom().show()
				, 200

	bind: ->

		# Define shorthand
		dom = m.menu.dom

		dom('#menu_create').on 'click', m.create.show
		dom('#menu_import').on 'click', m.import.step[0]
		dom('#menu_settings').on 'click', m.settings.show

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