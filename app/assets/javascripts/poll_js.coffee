ready = ->
	# Logs Poll
	logs = window.location.pathname.match(/logs\/[0-9]*/)
	if logs
		setInterval (->
			$.ajax "/#{logs[0]}.js",
				success: (data) ->
					data
		), 1000

$(document).ready(ready)
$(document).on('page:load', ready)