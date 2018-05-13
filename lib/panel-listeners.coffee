root = require("./panel-pano.js")
onPointerDownPointerX = undefined
onPointerDownPointerY = undefined
onPointerDownLon = undefined
onPointerDownLat =undefined

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
	container = $("#container")
	vector.set event.clientX / container.outerWidth() * 2 - 1, -(event.clientY / container.outerHeight()) * 2 + 1, 0.5
	vector.unproject root.camera
	tantheta = (vector.z / vector.x)
	theta = Math.atan(tantheta)
	theta = theta*180/Math.PI
	if theta < 0
		if(vector.x < 0)
			theta += 180
		else
			theta += 360
	else if vector.z <0 and vector.x < 0
		theta += 180
	root.theta = parseInt(theta)
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
	return

on_key_up = (event) ->
	root.Config.isUserInteracting = false
	root.Config.stop_time = Date.now()
	root.Config.autoplay = false
	return

add_listeners = ->
	$("#container").on
		click: (event) ->
			$("#container").focus();
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
		keydown: (event) ->
			on_key_down(event)
			return
		keyup: (event) ->
			on_key_up(event)
			return

remove_listeners = ()->
	$("#container").off()
	return
root.add_listeners = add_listeners
root.remove_listeners = remove_listeners
module.exports = root





