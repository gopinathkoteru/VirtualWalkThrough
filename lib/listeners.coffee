root = require("./transition.js")
onPointerDownPointerX = undefined
onPointerDownPointerY = undefined
onPointerDownLon = undefined
onPointerDownLat =undefined

touch_handler = (event) ->
	touches = event.changedTouches
	first = touches[0]
	type = ''
	switch event.type
		when 'touchstart'
			type = 'mousedown'
		when 'touchmove'
			type = 'mousemove'
		when 'touchend'
			type = 'mouseup'
		else
			return
	simulatedEvent = document.createEvent('MouseEvent')
	simulatedEvent.initMouseEvent type, true, true, window, 1, first.screenX, first.screenY, first.clientX, first.clientY, false, false, false, false, 0, null
	first.target.dispatchEvent simulatedEvent
	event.preventDefault()
	return

on_mouse_down = (event) ->
	event.preventDefault()
	root.Config.current_lon = root.Config.lon
	root.Config.target_lon = root.Config.lon
	root.Config.current_lat = root.Config.lat
	root.Config.target_lat = root.Config.lat
	root.Config.isUserInteracting = true
	onPointerDownPointerX = event.clientX
	onPointerDownPointerY = event.clientY
	onPointerDownLon = root.Config.lon
	onPointerDownLat = root.Config.lat
	vector = new (THREE.Vector3)
	container = $("#" + DirectPano.pano_div_id)
	vector.set event.clientX / container.outerWidth() * 2 - 1, -(event.clientY / container.outerHeight()) * 2 + 1, 0.5
	vector.unproject root.camera
	root.raycaster.set root.camera.position, vector.sub(root.camera.position).normalize()
	intersects = root.raycaster.intersectObjects(root.scene.children, true)
	if intersects.length > 0 and intersects[0].object.name == 'hotspot'
		root.Transition.start intersects[0].object.hotspot_id
	return

on_mouse_move = (event) ->
	if root.Config.isUserInteracting == true
		mouseSpeed = 0.3
		root.Config.target_lon = ((onPointerDownPointerX - (event.clientX)) * mouseSpeed + onPointerDownLon)
		root.Config.target_lat = (event.clientY - onPointerDownPointerY) * mouseSpeed + onPointerDownLat
	return

on_mouse_up = (event) ->
	root.Config.isUserInteracting = false
	root.Config.stop_time = Date.now()
	root.Config.autoplay = false
	return

on_mouse_wheel = (event) ->
	x = event.pageX
	y = event.pageY
	elementMouseIsOver = document.elementFromPoint(x, y)
	if $("#" + elementMouseIsOver.id).parent().attr('id') != 'panos-list'
		if event.wheelDeltaY
			root.camera.fov -= event.wheelDeltaY * 0.05
		else if event.wheelDelta
			root.camera.fov -= event.wheelDelta * 0.05
		else if event.detail
			root.camera.fov += event.detail * 1.0
		root.camera.fov = Math.max(60, Math.min(90, root.camera.fov))
		root.camera.updateProjectionMatrix()
	return

on_key_down = (event) ->
	near_id = undefined
	if !event
		event = window.event
	root.Config.isUserInteracting = true
	keyPressed = event.keyCode
	if keyPressed == 37
		root.Config.current_lon = root.Config.lon
		root.Config.target_lon = root.Config.lon - 20
	else if keyPressed == 39
		root.Config.current_lon = root.Config.lon
		root.Config.target_lon = root.Config.lon + 20
	else if keyPressed == 38
		if root.Transition.moving == false
			near_id = root.Hotspot.front_nearest_hotspot(root.Transition.current_pano)
			if near_id != -1
				root.Transition.start near_id
	else if keyPressed == 40
		if root.Transition.moving == false
			near_id = root.Hotspot.back_nearest_hotspot(root.Transition.current_pano)
			if near_id != -1
				root.Transition.start near_id
	else if keyPressed == 27
		container = $("#"+DirectPano.pano_div_id)
		if container.width() == window.innerWidth  and container.height() == window.innerHeight 
			root.escape_fullscreen()
	return

on_key_up = (event) ->
	root.Config.isUserInteracting = false
	root.Config.stop_time = Date.now()
	root.Config.autoplay = false
	return

add_listeners = ->
	$("#" + DirectPano.pano_div_id).on
		click: (event) ->
			$("#" + DirectPano.pano_div_id).focus();
			return
		mousedown: (event) -> 
			on_mouse_down(event) 
			return
		mousemove: (event) ->
			on_mouse_move(event)
			return
		mouseup: (event) ->
			on_mouse_up(event)
			return
		mousewheel: (event) ->
			on_mouse_wheel(event.originalEvent)	
			return
		DOMMouseScroll: (event) ->
			on_mouse_wheel(event.originalEvent)
			return
		touchstart: (event) ->
			touch_handler(event.originalEvent)
			return
		touchmove: (event) ->
			touch_handler(event.originalEvent)
			return
		touchend: (event) ->
			touch_handler(event.originalEvent)
			return
		keydown: (event) ->
			on_key_down(event)
			return
		keyup: (event) ->
			on_key_up(event)
			return

remove_listeners = ()->
	$("#" + DirectPano.pano_div_id).off()
	return
root.add_listeners = add_listeners
root.remove_listeners = remove_listeners
module.exports = root


