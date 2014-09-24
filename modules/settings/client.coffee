m.add m.settings =

	title: 'Settings'

	data: [
		{
			headline: true
			title: '{{ settings.list.account }}'
		}
		{
			id: 'avatar'
			title: '{{ settings.list.avatar }}'
			value: backend.settings.init.user.avatar
		}
		{
			id: 'password'
			title: '{{ settings.list.password }}'
			value: '&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;'
		}
		{
			headline: true
			title: '{{ settings.list.flyers }}'
		}
		{
			id: 'background'
			title: '{{ settings.list.background }}'
			value: backend.settings.init.user.background
		}
		{
			headline: true
			title: '{{ settings.list.payment }}'
		}
		{
			id: 'mail'
			title: '{{ settings.list.mail }}'
			value: backend.settings.init.user.primarymail
		}
		{
			id: 'priceperalbum'
			title: '{{ settings.list.priceperalbum }}'
			value: backend.settings.init.user.priceperalbum
		}
		{
			id: 'priceperphoto'
			title: '{{ settings.list.priceperphoto }}'
			value: backend.settings.init.user.priceperphoto
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

		# Show settings
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

		dom('#settings_mail').on 'click', m.settings.set.mail
		dom('#settings_priceperalbum').on 'click', m.settings.set.priceperalbum
		dom('#settings_priceperphoto').on 'click', m.settings.set.priceperphoto

	set:

		avatar: ->

			validate = (data) ->

				if	not data.avatar? or
					data.avatar.length <= 7

						modal.error 'avatar'
						return false

				url = 'api/m/settings/avatar?url=' + encodeURIComponent(data.avatar)
				backend.api url, (res) ->

					if res is true

						notification.show {
							icon: 'android-checkmark'
							text: '{{ settings.avatar.success }}'
						}
						m.settings.dom('#settings_avatar p.value').html data.avatar
						modal.close()
						return true

					modal.error 'avatar'
					return false

			modal.show
				body:	"""
						<h1>{{ settings.avatar.title }}</h1>
						<p>{{ settings.avatar.text }}</p>
						<input class="text" type="text" placeholder="http://example.com/avatar.png" data-name="avatar" autofocus value="#{ backend.settings.init.user.avatar }">
						"""
				class: 'login'
				buttons:
					cancel:
						fn: -> modal.close()
					action:
						title: '{{ settings.avatar.button }}'
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
				backend.api url, (res) ->

					if res is true

						notification.show {
							icon: 'android-checkmark'
							text: '{{ settings.password.success }}'
						}
						modal.close()
						return true

					modal.error 'password'
					return false

			modal.show
				body:	"""
						<h1>{{ settings.password.title }}</h1>
						<p>{{ settings.password.text }}</p>
						<input class="text" type="password" placeholder="password" data-name="password" autofocus>
						<input class="text" type="password" placeholder="repeat password" data-name="repassword">
						"""
				class: 'login'
				buttons:
					cancel:
						fn: -> modal.close()
					action:
						title: '{{ settings.password.button }}'
						fn: validate

		background: ->

			validate = (data) ->

				if	not data.background? or
					data.background.length <= 7

						modal.error 'background'
						return false

				url = 'api/m/settings/background?url=' + encodeURIComponent(data.background)
				backend.api url, (res) ->

					if res is true

						notification.show {
							icon: 'android-checkmark'
							text: '{{ settings.background.success }}'
						}
						m.settings.dom('#settings_background p.value').html data.background
						modal.close()
						return true

					modal.error 'background'
					return false

			modal.show
				body:	"""
						<h1>{{ settings.background.title }}</h1>
						<p>{{ settings.background.text }}</p>
						<input class="text" type="text" placeholder="http://example.com/background.png" data-name="background" autofocus value="#{ backend.settings.init.user.background }">
						"""
				class: 'login'
				buttons:
					cancel:
						fn: -> modal.close()
					action:
						title: '{{ settings.background.button }}'
						fn: validate

		mail: ->

			validate = (data) ->

				if	not data.mail? or
					data.mail.length <= 6

						modal.error 'mail'
						return false

				url = 'api/m/settings/mail?mail=' + encodeURI(data.mail)
				backend.api url, (res) ->

					if res is true

						notification.show {
							icon: 'android-checkmark'
							text: '{{ settings.mail.success }}'
						}
						m.settings.dom('#settings_mail p.value').html data.mail
						modal.close()
						return true

					modal.error 'mail'
					return false

			modal.show
				body:	"""
						<h1>{{ settings.mail.title }}</h1>
						<p>{{ settings.mail.text }}</p>
						<input class="text" type="text" placeholder="mail@example.com" data-name="mail" autofocus value="#{ backend.settings.init.user.primarymail }">
						"""
				class: 'login'
				buttons:
					cancel:
						fn: -> modal.close()
					action:
						title: '{{ settings.mail.button }}'
						fn: validate

		priceperalbum: ->

			validate = (data) ->

				if	not data.amount? or
					data.amount.length < 1

						modal.error 'amount'
						return false

				# Validate amount
				reg = /^[0-9]{1,}[\.,]{1}[0-9]{2}$/
				if not reg.test data.amount

					notification.show {
						icon: 'alert-circled'
						text: '{{ settings.priceperalbum.error }}'
					}
					modal.error 'amount'
					return false

				if data.amount.indexOf(',') isnt -1

					# Replace comma with dot
					data.amount = data.amount.replace ',', '.'

				url = 'api/m/settings/priceperalbum?amount=' + encodeURI(data.amount)
				backend.api url, (res) ->

					if res is true

						notification.show {
							icon: 'android-checkmark'
							text: '{{ settings.priceperalbum.success }}'
						}
						m.settings.dom('#settings_priceperalbum p.value').html data.amount
						modal.close()
						return true

					modal.error 'amount'
					return false

			modal.show
				body:	"""
						<h1>{{ settings.priceperalbum.title }}</h1>
						<p>{{ settings.priceperalbum.text }}</p>
						<input class="text" type="text" placeholder="9.99" data-name="amount" autofocus value="#{ backend.settings.init.user.priceperalbum }">
						"""
				class: 'login'
				buttons:
					cancel:
						fn: -> modal.close()
					action:
						title: '{{ settings.priceperalbum.button }}'
						fn: validate

		priceperphoto: ->

			validate = (data) ->

				if	not data.amount? or
					data.amount.length < 1

						modal.error 'amount'
						return false

				# Validate amount
				reg = /^[0-9]{1,}[\.,]{1}[0-9]{2}$/
				if not reg.test data.amount

					notification.show {
						icon: 'alert-circled'
						text: '{{ settings.priceperphoto.error }}'
					}
					modal.error 'amount'
					return false

				url = 'api/m/settings/priceperphoto?amount=' + encodeURI(data.amount)
				backend.api url, (res) ->

					if res is true

						notification.show {
							icon: 'android-checkmark'
							text: '{{ settings.priceperphoto.success }}'
						}
						m.settings.dom('#settings_priceperphoto p.value').html data.amount
						modal.close()
						return true

					modal.error 'amount'
					return false

			modal.show
				body:	"""
						<h1>{{ settings.priceperphoto.title }}</h1>
						<p>{{ settings.priceperphoto.text }}</p>
						<input class="text" type="text" placeholder="5.99" data-name="amount" autofocus value="#{ backend.settings.init.user.priceperphoto }">
						"""
				class: 'login'
				buttons:
					cancel:
						fn: -> modal.close()
					action:
						title: '{{ settings.priceperphoto.button }}'
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

				html =	"""
						<div class="row" id="settings_#{ data.id }">
							<p class="arrow ion-ios7-arrow-right"></p>
							<p class="title">#{ data.title }</p>
						"""

				if data.value? then html += """<p class="value">#{ data.value }</p>"""

				html += "</div>"