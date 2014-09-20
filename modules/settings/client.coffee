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

		dom('#settings_avatar').on 'click', m.settings.set.avatar

		dom('#settings_password').on 'click', m.settings.set.password

		dom('#settings_background').on 'click', m.settings.set.background

	set:

		avatar: ->

			validate = (data) ->

				if	not data.avatar? or
					data.avatar.length <= 7

						modal.error 'avatar'
						return false

				url = 'api/m/settings/avatar?url=' + encodeURIComponent(data.avatar)
				kanban.api url, (data) ->

					if data is true

						notification.show {
							icon: 'android-checkmark'
							text: 'Changed avatar'
						}

					modal.close()
					return true

			modal.show
				body:	"""
						<h1>Avatar</h1>
						<p>Your avatar will be visible on the flyers and in the store. Enter a direct URL to your avatar below:</p>
						<input class="text" type="text" placeholder="http://example.com/avatar.png" data-name="avatar">
						"""
				class: 'login'
				buttons:
					cancel:
						fn: -> modal.close()
					action:
						title: 'Save Avatar'
						fn: validate

		password: ->

			validate = (data) ->

				if	not data.password? or
					data.password.length <= 4

						modal.error 'password'
						return false

				if	data.password isnt data.repassword

						modal.error 'repassword'
						return false

				url = 'api/m/settings/password?password=' + encodeURI(data.password)
				kanban.api url, (data) ->

					if data is true

						notification.show {
							icon: 'android-checkmark'
							text: 'Changed password'
						}

					modal.close()
					return true

			modal.show
				body:	"""
						<h1>Password</h1>
						<p>Enter a new password for your account below:</p>
						<input class="text" type="password" placeholder="password" data-name="password">
						<input class="text" type="password" placeholder="repeat password" data-name="repassword">
						"""
				class: 'login'
				buttons:
					cancel:
						fn: -> modal.close()
					action:
						title: 'Save Password'
						fn: validate

		background: ->

			validate = (data) ->

				if	not data.background? or
					data.background.length <= 7

						modal.error 'background'
						return false

				url = 'api/m/settings/background?url=' + encodeURIComponent(data.background)
				kanban.api url, (data) ->

					if data is true

						notification.show {
							icon: 'android-checkmark'
							text: 'Changed background'
						}

					modal.close()
					return true

			modal.show
				body:	"""
						<h1>Background</h1>
						<p>Your background will be visible on the top of each flyer. Enter a direct URL to your background below:</p>
						<input class="text" type="text" placeholder="http://example.com/background.png" data-name="background">
						"""
				class: 'login'
				buttons:
					cancel:
						fn: -> modal.close()
					action:
						title: 'Save Background'
						fn: validate

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