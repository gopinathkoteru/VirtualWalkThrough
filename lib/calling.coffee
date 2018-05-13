root = undefined
anim = undefined
DirectPano.show_pano = ()->
	image = $("<img id='start-image'/>")
	image.css({
		'visibility': 'visible',
		'height': Math.min(DirectPano.initial_height, window.innerHeight)  + 'px',
		'width': Math.min(DirectPano.initial_width, window.innerWidth) + 'px',
		'z-index': '1',
		'position': 'absolute',
		'left':'0px',
		'top': '0px',
		'background-image': './panos/1.tiles/mobile_l.jpg',
		'background-size': 'cover'
		})

	$("#" + DirectPano.pano_div_id).append(image)
	$("#panos-list").remove()
	$("#" + DirectPano.pano_div_id).append("<div id='panos-list'></div>")
	panos_list = $("#panos-list")

	root = require("./listeners.js")
	$.getJSON 'data.json', (data) ->
		root.house = data
		i = 0
		while i < Object.keys(root.house).length
			if root.house[i][SIDE_PANEL] == true
				panos_list.append("<div id='panos-list-entry-" + i + "'>" + root.house[i][TITLE] + "</div>")
				$("#panos-list-entry-" + i).attr('pano_id', parseInt(i))
				$("#panos-list-entry-" + i).bind 'click touchstart', ->
					if root.Transition.moving == false
						root.Transition.start(null, this.getAttribute('pano_id'))
					return
			i++

		root.Annotation = new root.annotation()
		root.Annotation.add_annotations(0)
	
		root.scene.children.length = 0

		root.add_listeners()

		root.Hotspot = new root.hotspot()
		root.Transition = new root.transition()
		root.Hotspot.add_hotspots(0)

		anim = new root.animation()
		root.Config.isUserInteracting = true
		return
	return

DirectPano.remove_pano = ->
	anim.destroy = true
	anim = null
	root.remove_listeners()
	root.Hotspot.destroy_hotspot()
	root.Hotspot = null
	root.Transition.destroy_transition()
	root.Transition = null
	root.Annotation.destroy_annotation()
	root.Annotation = null
	root.destroy()
	return