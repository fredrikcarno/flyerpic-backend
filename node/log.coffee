# Dependencies
colors = require 'colors'

name = 'kanban    '.white

norm = (text) ->

	filler = '         ' #9
	length = filler.length - text.length

	if length > 0

		text += filler.substr text.length
		return text

	return text

log = module.exports =

	status: (source, text) ->

		source = norm source
		console.log name + "#{ source }".green + "#{ text }"

	warning: (source, text, error) ->

		source = norm source
		console.warn name + "#{ source }".yellow + "#{ text }"
		console.warn error if error?

	error: (source, text, error) ->

		source = norm source
		console.error name + "#{ source }".red + "#{ text }"
		console.error error