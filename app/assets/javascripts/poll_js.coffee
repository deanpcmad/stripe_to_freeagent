ready = ->
	# Imports Poll
	imports = window.location.pathname.match(/imports\/[0-9a-zA-Z]*-[0-9a-zA-Z]*-[0-9a-zA-Z]*-[0-9a-zA-Z]*-[0-9a-zA-Z]*/i)
	if imports
		setInterval (->
			$.ajax "/#{imports[0]}.js",
				success: (data) ->
					data
		), 1000

$(document).ready(ready)
$(document).on('page:load', ready)