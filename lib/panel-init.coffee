root = require('./panel-hotspot.js')
front_pano = undefined
back_pano = undefined
house_id = undefined
position = undefined
fallback_image = ""
root.pano_paths = []
root.blur_paths = []

root.full_dataset = {}
localStorage.setItem('full_dataset', JSON.stringify(root.full_dataset))
one_dataset = {
	"pano_path": undefined,
	"hotspot": {}
}

root.Config = 
	img_name: ['r'
		'l' 
		'u' 
		'd' 
		'f' 
		'b'
	]
	webgl : true
	lon : 0
	lat : 0
container = $("#container")
scene = new (THREE.Scene)
	
texture_placeholder = $('<canvas/>').width(128).height(128)

renderer = new (THREE.WebGLRenderer)
	
renderer.setPixelRatio window.devicePixelRatio

container.append(renderer.domElement)
renderer.setSize container.outerWidth(), container.outerHeight()
camera = new (THREE.PerspectiveCamera)(90, container.outerWidth() / container.outerHeight(), 1, 1100)
camera.target = new (THREE.Vector3)(0, 0, 0)

animate = ->
	requestAnimationFrame(animate)
	if(root.Config.target_lon != undefined and root.Config.current_lon != undefined and Math.abs(root.Config.target_lon - root.Config.current_lon) > 0.1)
		root.Config.current_lon = root.Config.current_lon + (root.Config.target_lon - root.Config.current_lon)*0.15
		root.Config.lon = (root.Config.current_lon + 360)%360
	if(root.Config.target_lat != undefined and root.Config.current_lat != undefined and Math.abs(root.Config.target_lat - root.Config.current_lat) > 0.1)
		root.Config.current_lat = root.Config.current_lat + (root.Config.target_lat - root.Config.current_lat)*0.15
		root.Config.lat = root.Config.current_lat
	update()
	return

update = ->
	root.Config.lon = (root.Config.lon + 360)%360
	root.Config.lat = Math.max(-35, Math.min(35, root.Config.lat))
	phi = THREE.Math.degToRad(90 - (root.Config.lat))
	theta = THREE.Math.degToRad(root.Config.lon)
	camera.target.x = 500 * Math.sin(phi) * Math.cos(theta)
	camera.target.y = 500 * Math.cos(phi)
	camera.target.z = 500 * Math.sin(phi) * Math.sin(theta)
	camera.lookAt camera.target
	renderer.render scene, camera
	return

init = (scrollid,num_panos) ->
	test = ""
	i = 1
	while i<=num_panos
		test = test + "<option value='"+ i + "'>pano" +i + "</option>" 
		i++
	document.getElementById(scrollid).innerHTML = test;

change_pano = (id,value) ->
	opc = $("#opacity")[0].value
	if id == 1
		try
			front_pano.destroy_pano()
			front_pano = undefined
		catch error
			front_pano = undefined
		  
		front_pano = new root.Pano(value-1)
		front_pano.create_pano(opc)
	else
		try
			back_pano.destroy_pano()
			back_pano = undefined
		catch error
			back_pano = undefined

		back_pano = new root.Pano(value-1)
		back_pano.create_pano(1-opc)
		error_value = $("#adjust")[0].value
		back_pano.mesh.rotation.y = THREE.Math.degToRad(error_value)

		

animate()


$("#xml-submit").on('click',->
	xmlhttp=new XMLHttpRequest()
	xmlhttp.open("GET",$("#xml-path").val(),false)
	xmlhttp.send()
	xmlDoc=xmlhttp.responseXML
	house_id = $("#xml-path").val()
	console.log(house_id)

	num_panos = xmlDoc.getElementsByTagName("scene").length
	root.pano_paths = []
	root.blur_paths = []
	i = 0
	while i < num_panos
		xml_scene = xmlDoc.getElementsByTagName("scene")[i]
		root.blur_paths[i] = xml_scene.getElementsByTagName("preview")[0].getAttribute("url")
		root.pano_paths[i] = xml_scene.getElementsByTagName("image")[0].getElementsByTagName("level")[1].getElementsByTagName("cube")[0].getAttribute("url")
		i++
	
	init("list1",num_panos)
	init("list2",num_panos)

	$("#list1").trigger('change')
	$("#list2").trigger('change')
	return)

$("#list1").on('change',->
	list = $("#list1")
	value = list[0].options[list[0].selectedIndex].value
	change_pano(1,value)
	return)

$("#list2").on('change',->
	list = $("#list2")
	value = list[0].options[list[0].selectedIndex].value
	change_pano(2,value)
	return)

$("#save-data-button").click ->
	root.save_annotation()
	root.save_hotspot()
	if root.full_dataset[house_id] == undefined
		one_dataset = {}
		root.full_dataset[house_id] = one_dataset
	else
		one_dataset = root.full_dataset[house_id]
	from_id = $("#list1").val() - 1
	title = $("#pano-title").val()
	to_show_side_panel = false
	if $("#side-panel").val() == "on"
		to_show_side_panel = true
	#console.log to_show_side_panel
	if one_dataset[from_id] == undefined
		one_dataset[from_id] = {
			"title": title,    # Title of the scene e.g. Hall
			"path": root.pano_paths[from_id],
			"blur_image_path" : root.blur_paths[from_id],
			"side_panel": to_show_side_panel,
			"start_position" : position,
			"fallback_image": fallback_image,
			"hotspots": [],
			"annotations": [],
		}
	one_dataset[from_id]["annotations"] = root.annotation_angles
	one_dataset[from_id]["hotspots"] = root.hotspots_angle
	console.log(one_dataset)
	console.log(root.full_dataset)
	localStorage.setItem('full_dataset', JSON.stringify(one_dataset))

$('#container').click (e) ->
	if $('#add-hotspot-image').css('display') == 'block'
		l = e.pageX - 25
		t = e.pageY - 15
		$('#add-hotspot-image').css
			width: '50px'
			height: '50px'
			left: l
			top: t
			position: 'absolute'
	return

root.camera = camera
root.scene = scene
root.renderer = renderer
root.texture_placeholder = texture_placeholder

slider = $("#opacity")
slider.on('change mousemove',->
	opacity = slider[0].value
	value = $("#display")
	value.html(opacity)
	i = 0
	while i < 6
		j = 0
		while j < 1
			front_pano.mesh.children[i].children[j].material.opacity = opacity
			back_pano.mesh.children[i].children[j].material.opacity = 1 - opacity
			j++
		i++
	return)

$("#set-position").on('click',->
	position = parseInt(root.Config.lon)
	return)

$("#fallback-image-button").on('click',->
	fallback_image = $("#fallback-image").val()
	return)

adjust = $("#adjust")
adjust.on('change mousemove',->
	error_value = adjust[0].value
	error = $("#error")
	error.html(error_value)
	back_pano.mesh.rotation.y = THREE.Math.degToRad(error_value)
	return)


root.add_listeners()

module.exports = root