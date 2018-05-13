root = require('./fallback-annotation.js')
pano = undefined
class Transition
	constructor:(old_id , new_id) ->
		@destroy = false
		@old_id = old_id
		@new_id = new_id
		root.hotspot.remove_hotspots()
		root.hotspot = null
		root.annotation.remove_annotations()
		root.annotation = null
		
		pano = new root.Pano(new_id)
		if @destroy
			return
		change_opacity = @change_opacity.bind(this)
		pano.load_pano().done ->
			change_opacity()
			return
		return

	change_opacity:() ->
		if @destroy
			return
		time = 3000
		complete = @complete.bind(this)
		$("#image-screen1_" + @old_id).fadeTo(time, 0)
		$("#image-screen2_" + @old_id).fadeTo(time, 0)

		$("#image-screen1_" + @new_id).fadeTo(time, 1)
		$("#image-screen2_" + @new_id).fadeTo(time, 1, ->
			complete()
			return)
		return
	complete :() ->
		root.pano.remove_pano()
		root.pano = null
		new_id = @new_id
		if @destroy
			return
		console.log(@destroy)
		root.pano = pano
		root.hotspot = new root.Hotspot(new_id)
		root.hotspot.add_hotspots()
		root.annotation = new root.Annotation(new_id)
		root.annotation.add_annotations()
		return
	destroy_transition:() ->
		@destroy = true
		console.log(@destroy)
		$("#image-screen1_" + @old_id).stop()
		$("#image-screen2_" + @old_id).stop()

		$("#image-screen1_" + @new_id).stop()
		$("#image-screen2_" + @new_id).stop()

		root.pano.remove_pano()
		pano.remove_pano()
		root.pano = null



root.Transition = Transition
module.exports = root


