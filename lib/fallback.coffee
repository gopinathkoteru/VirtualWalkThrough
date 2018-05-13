root = require("./fallback-transition.js")
root.width = undefined
root.height = undefined
flag = false
offset = 1500 - window.innerWidth
(($) ->
	$.fn.dragabble = (opt) ->
		`var $el`
		opt = $.extend({
			handle: ''
			cursor: 'move'
			}, opt)
		if opt.handle == ''
			$el = this
		else
			$el = @find(opt.handle)
		set_x = undefined
		set_offset = undefined
		$el.css('cursor', opt.cursor).on('mousedown', (e) ->
			flag = true
			$drag = $el
			set_x = e.pageX
			set_offset = $(this).offset().left
			e.preventDefault()
			return
		).on('mousemove', (e) ->
			if flag == true
				g = set_offset + (e.pageX - set_x)*2
				g = Math.floor(g)
				keypress = undefined
				if e.pageX > set_x
					keypress = 1
				else
					keypress = 2
				set_offset = g
				set_x = e.pageX
				$(this).offset left: g
				p = Math.floor($(this).offset().left)
				if keypress == 1
					if Math.abs(p) % 1500 <= 200
						if Math.abs(p) % 3000 <=200
							q = $('#screen1').offset().left - p
							$('#screen2').offset left: q - 1500 + p
						else
							q = $('#screen2').offset().left - p
							$('#screen1').offset left: q - 1500 + p
				else
					p = p + offset
					if Math.abs(p) % 1500 <= 200
						if Math.abs(p) % 3000 <=200
							p = p - offset
							q = $('#screen1').offset().left - p
							$('#screen2').offset left: q + 1500 + p
						else
							p = p - offset
							q = $('#screen2').offset().left - p
							$('#screen1').offset left: q + 1500 + p
			return
		).on('mouseup', ->
			flag = false
			return
		).on('keydown', (e) ->
			keypressed = e.keyCode
			p = $(this).offset().left
			if keypressed == 38
				hotspots = $(this).find(".hotspot")
				num_hotspots = hotspots.length
				i = 0
				while i < num_hotspots
					if $(hotspots[i]).offset().left > 200 && $(hotspots[i]).offset().left < 300 
						$(hotspots[i]).trigger('click')
						return
					i++
			else if keypressed == 37
				$(this).offset left: p - 10
				p = $(this).offset().left
				p = p + offset
				if Math.abs(p) % 1500 <= 200
					if Math.abs(p) % 3000 <= 200 
						p = p - offset
						q = $('#screen1').offset().left - p
						$('#screen2').offset left: q + 1500 + p
					else
						p = p - offset
						q = $('#screen2').offset().left - p
						$('#screen1').offset left: q + 1500 + p
			else if keypressed == 39
				$(this).offset left: p + 10
				if Math.abs(p) % 1500 <= 200
					if Math.abs(p) % 3000 <= 200
						q = $('#screen1').offset().left - p
						$('#screen2').offset left: q - 1500 + p
					else
						q = $('#screen2').offset().left - p
						$('#screen1').offset left: q - 1500 + p
			else if keypressed == 27
				escape_fullscreen()
			return
		).on 'click', (e) ->
			$(this).focus()
			return
	return
) jQuery
update_dimensions = ->
	$("#" + DirectPano.pano_div_id).css({
		width : root.width,
		height : root.height
		})
	$("#screen1").css({
		height : root.height
		})
	$("#screen2").css({
		height : root.height
		})

	$("#screen2").offset({
		top:0,
		left:-1500
	})

	$("#image-screen1_" + root.pano.pano_id).css({
		height : root.height + 30
		})
	$("#image-screen2_" + root.pano.pano_id).css({
		height : root.height + 30
		})
	num_hotspots = root.house[root.hotspot.pano_id][HOTSPOTS].length
	i = 0
	while i < num_hotspots
		$("#hotspot_" + i + "_0").css({
			top : root.height/2
			})
		$("#hotspot_" + i + "_1").css({
			top : root.height/2
			})
		i++

	num_annotations = root.house[root.annotation.pano_id][ANNOTATIONS].length
	i = 0
	while i < num_annotations
		offset = root.house[root.annotation.pano_id][ANNOTATIONS][i][LAT]
		$("#annotation_1_" + i).css({
			top : root.height/2 - 2*offset
			})
		$("#annotation_2_" + i).css({
			top : root.height/2 - 2*offset
			})
		i++
	return
go_fullscreen = ->
	root.width = window.innerWidth
	root.height = window.innerHeight
	$('#'+ DirectPano.image_div_id).css({
		'visibility': 'hidden'
		})
	update_dimensions()
	return
escape_fullscreen = ->
	root.width = DirectPano.initial_width
	root.height = DirectPano.initial_height
	$('#'+ DirectPano.image_div_id).css({
		'visibility': 'visible'
		})
	update_dimensions()
	return

$('#'+ DirectPano.image_div_id).bind 'touchstart click', ->
	go_fullscreen()
	return

container = $("#" + DirectPano.pano_div_id)
container.css("overflow","hidden")
root.width = DirectPano.initial_width
root.height = DirectPano.initial_height

container.css({
	'width' : root.width,
	'height' : root.height
	})

div = $("<div></div>",{id : "drag",tabindex : 0})

div.width(window.innerWidth).height(window.innerHeight)

div1 = $("<div></div>",{id : "screen1"})
div2 = $("<div></div>",{id: "screen2"})

div1.css({
	"width" : "1500px",
	"height": root.height
	})
div2.css({
	"width" : "1500px",
	"height": root.height
	})

div.append(div1)
div.append(div2)

container.append(div)

DirectPano.show_fallback_pano = ->
	$("#drag").offset({
		left : 0
		})
	$.getJSON 'data.json', (data) ->
		root.house = data
		root.pano = new root.Pano(0)
		root.pano.load_pano().done ->
			$(document).ready(->
				$("#image-screen1_0").fadeTo(3000, 1)
				$("#image-screen2_0").fadeTo(3000 , 1, ->
					root.hotspot = new root.Hotspot(0)
					root.hotspot.add_hotspots()
					root.annotation = new root.Annotation(0)
					root.annotation.add_annotations()
					return)
				return)
			return

		div2.offset({
			top:0,
			left:-1500
		})

		div.dragabble()
		return
	return

DirectPano.remove_fallback_pano = ->
	try
	  root.transition.destroy_transition()
	  root.transition = null
	catch error
	  root.transition = null
	
	try
		root.hotspot.remove_hotspots()
		root.hotspot = null
	catch error
		root.hotspot = null
	
	try
		root.annotation.remove_annotations()
		root.annotation = null
	catch error
		root.annotation = null

	try	
		root.pano.remove_pano()
		root.pano = null
	catch error
		root.pano = null
	return
