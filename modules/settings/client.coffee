m.add m.settings =

	title: 'Settings'

	data: [
		{
			headline: true
			title: 'Account'
		}
		{
			id: 'avatar'
			title: 'Set Avatar Photo'
		}
		{
			id: 'username'
			title: 'Change Username and Name'
		}
		{
			id: 'password'
			title: 'Change Password'
		}
		{
			headline: true
			title: 'Flyers'
		}
		{
			id: 'background'
			title: 'Set Background Photo'
		}
		{
			headline: true
			title: 'Payment'
		}
		{
			id: 'mail'
			title: 'Set PayPal Email'
		}
		{
			id: 'priceperalbum'
			title: 'Set Price Per Session'
		}
		{
			id: 'priceperphoto'
			title: 'Set Price Per Photo'
		}
	]

	init: ->

		# Render
		m.settings.dom().append m.settings.render.all()

		# Bind menus
		m.settings.bind()

	show: ->

		# Blur menu
		m.menu.dom().addClass 'blur'

		# Show menus
		m.settings.dom().show()

	hide: ->

		# Restore menu
		m.menu.dom().removeClass 'blur'

		# Hide settings
		m.settings.dom().hide()

	bind: ->

		# Define shorthand
		dom = m.settings.dom

		dom('a.close').on 'click', m.settings.hide

	render:

		all: ->

			"""
			<a class="close ion-ios7-close-empty" href="#"></a>
			<div class="wrapper">
				#{ (m.settings.render.item item for item in m.settings.data).join '' }
			</div>
			"""

		item: (data) ->

			if data.headline is true

				"""
				<h2>#{ data.title }</h2>
				"""

			else

				"""
				<div class="row" id="settings_#{ data.id }">
					<p class="arrow ion-ios7-arrow-right"></p>
					<p class="title">#{ data.title }</p>
				</div>
				"""