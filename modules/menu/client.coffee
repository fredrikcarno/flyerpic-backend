m.add m.menu =

	title: 'Menu'

	data: [
		{
			id: 'createflyers'
			icon: 'ion-ios7-albums-outline'
			title: 'Create Flyers'
			description: 'Generate and download flyers'
		}
		{
			id: 'uploadsessions'
			icon: 'ion-ios7-cloud-upload-outline'
			title: 'Upload Sessions'
			description: 'Create and upload a new sessions'
		}
		{
			id: 'settings'
			icon: 'ion-ios7-cog-outline'
			title: 'Settings'
			description: 'Edit your personal settings and details'
		}
	]

	init: ->

		# Render
		m.menu.dom().append m.menu.render.all()

		# Bind menus
		m.menu.bind()

	bind: ->

		# Define shorthand
		dom = m.menu.dom

		dom('#createflyers').on 'click', ->

			# More here
			console.log 'clicked'

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