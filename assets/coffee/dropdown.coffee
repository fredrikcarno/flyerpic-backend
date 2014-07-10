$(document).ready ->

	dropdownTimeout = null

	$(document)
		.on 'click', '.dropdown .front', ->
			clearTimeout dropdownTimeout
			dropdown = $(this).parent()
			dropdown.find('.back').show()
			dropdown.addClass 'flip'
		.on 'click', '.dropdown .back ul li', ->
			dropdown = $(this).parent().parent().parent()
			dropdown.find('span').html $(this).html()
			dropdown.attr 'data-value', $(this).data('value')
			dropdown.removeClass 'flip'
			dropdownTimeout = setTimeout ->
				dropdown.find('.back').hide()
			, 3000
