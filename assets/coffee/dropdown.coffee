$(document).ready ->

	dropdownTimeout = null

	$(document)

		.on 'click', '.dropdown .front', ->

			clearTimeout dropdownTimeout
			dropdown = $(this).parent()
			dropdown.find('.back').show()
			dropdown.addClass 'flip'

		.on 'click', '.dropdown .back ul li[class!="separator"]', ->

			dropdown = $(this).parent().parent().parent()

			value = $(this).clone()
			value.find('span').remove()
			value = value.html().trim()

			dropdown.find('.front span').html value
			dropdown.attr 'data-value', $(this).data('value')
			dropdown.removeClass 'flip'
			dropdownTimeout = setTimeout ->
				dropdown.find('.back').hide()
			, 3000