build =

	page: (number) ->

		"""
		<div class="page" data-number="#{ number }">

			<div class="cutline vertical"></div>
			<div class="cutline horizontalTop"></div>
			<div class="cutline horizontalBottom"></div>

			<div class="flyers"></div>
		</div>
		"""

	flyer: (photographer, data) ->

		"""
		<div class="flyer">
			<div class="head">
				<img src="https://avatars1.githubusercontent.com/u/499088?s=460" width="48" height="48">
				<h1>#{ photographer.name }</h1>
				<a>#{ photographer.mail }</a>
			</div>
			<div class="steps">
				<div class="step">
					<div class="left">
						<a href="#" class="number">1</a>
					</div>
					<div class="right">
						<p>Visit example.com and enter your private code or scan the QR-Code with your phone</p>
						<div class="codes">
							<div class="qr">
								<img src="../../cache/#{ data.qr }" alt="" width="100" height="100">
							</div>
							<p class="separator">- or -</p>
							<div class="text">
								<img src="assets/img/locked.svg" alt="lock" width="14">
								<a href="#">#{ data.code }</a>
							</div>
						</div>
					</div>
				</div>
				<div class="step">
					<div class="left">
						<a href="#" class="number">2</a>
					</div>
					<div class="right">
						<p>Browse through your photos</p>
					</div>
				</div>
				<div class="step">
					<div class="left">
						<a href="#" class="number">3</a>
					</div>
					<div class="right">
						<p>Buy a digital copy of your photos and download them to your computer</p>
					</div>
				</div>
			</div>
		</div>
		"""

init = ->

	# Check hash
	hash = window.location.hash

	if	not hash? or
		hash is '' or
		hash is '#'

			$('body').html 'Error: Could not get data'
			return false

	# Parse hash
	hash = decodeURIComponent hash.substr(1)
	data = ''
	data = JSON.parse hash

	if data is ''

		$('body').html 'Error: Could not parse data'
		return false

	# For each flyer
	data.flyers.forEach (element, index, array) ->

		flyersPerPage = 4

		if index%flyersPerPage is 0

			# Build page
			number = index / flyersPerPage
			$('body').append build.page(number)

		# Build flyer
		flyer = build.flyer data.photographer, element
		$('body .page:last-child .flyers').append flyer

$(document).ready ->

	init()