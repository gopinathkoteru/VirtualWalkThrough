root = require('./panel-annotation.js')
root.hotspot_count = 0
angle = undefined
angle1 = undefined
onPointerDownPointerX = undefined
onPointerDownPointerY = undefined
onPointerDownLon = undefined
onPointerDownLat =undefined
flag = false
lat = 0
lon = 0
uns_hotspot = undefined

$("#add-hotspot-button").on('click',->
	hotspot_id = "hotspot_" + root.hotspot_count 
	div = $("<div></div>",{id : hotspot_id})
	div.prepend("<div class='hotspot-title' style='color:yellow'>Title</div>
		<img class='hotspot' height='40px' width='40px' src='../test/images/logo.png'></img>
			")
	delete_div = $("<img height='20px' width='20px' src = '../test/images/delete.png'/>")
	delete_div.click ->
		div.remove()
		delete_div.remove()
	div.append(delete_div)

	div.attr('lat' ,parseInt(root.Config.lat))
	div.attr('lon', parseInt(root.Config.lon))

	div.css('position', 'absolute')
	div.css('left', $("#container").outerWidth()/2 + 'px')
	div.css('top', $("#container").outerHeight()/2 + 'px')

	$("#container").append(div)
	uns_hotspot = div
	return)

$("#save-hotspot-button").on('click',->
	uns_hotspot.attr('lat',parseInt(root.Config.lat))
	uns_hotspot.attr('lon',parseInt(root.Config.lon))
	uns_hotspot.find('.hotspot-title').html($("#hotspot-title").val())
	root.hotspot_count += 1
	return)

root.save_hotspot = () ->
	count = 0
	hotspots_angle = []
	i = 0
	while i < root.hotspot_count
		hotspot_id = "#hotspot_" + i
		hotspot = $(hotspot_id)
		data_hotspot = {}
		error = $("#adjust").val()
		error = parseInt(error)
		to_id = $("#list2").val() - 1
		if hotspot.length != 0
			data_hotspot.to_id = to_id
			data_hotspot.angle = parseInt(hotspot.attr('lon'))
			#data_hotspot.lat = parseInt(hotspot.attr('lat'))
			data_hotspot.error = error
			if hotspot.find('.hotspot-title').html()
				data_hotspot.text = hotspot.find('.hotspot-title').html()
			
			hotspots_angle[count] = data_hotspot
			count = count + 1
			hotspot.remove()
		i++
	root.hotspots_angle = hotspots_angle
	return
	
update = ()->
	i = 0
	while i < root.hotspot_count
		hotspot_id = "#hotspot_" + i
		hotspot = $(hotspot_id)
	
		angle = $(hotspot_id).attr('lon')
		angle1 = $(hotspot_id).attr('lat')
		rad_angle =THREE.Math.degToRad(angle)
		vector = new (THREE.Vector3)(30*Math.cos(rad_angle), angle1, 30*Math.sin(rad_angle))
		vector.x += 13*Math.cos(rad_angle)
		vector.z += 13*Math.sin(rad_angle)
		vector = vector.project(root.camera)
		container = $("#container")
		pos =
			x: (vector.x + 1)/2 * container.outerWidth()
			y: -(vector.y - 1)/2 * container.outerHeight()

		if hotspot
			if(vector.x > 1 or vector.x < -1 or vector.y > 1 or vector.y < -1 or vector.z > 1 or vector.z < -1)
					if( $(hotspot_id).css('display') != 'none')
						$(hotspot_id).removeAttr('style')
						$(hotspot_id).css('display', 'none')
			else 
				$(hotspot_id).css('display', 'inline')
				$(hotspot_id).css('left', '0px')
				$(hotspot_id).css('top', '0px')
				$(hotspot_id).css('transform', 'translate3d(' + (pos.x) + 'px,' + (pos.y) + 'px,0px)')
				$(hotspot_id).css('position', 'absolute')
				$(hotspot_id).css('font-family': "'Helvetica Neue', Helvetica, Arial, sans-serif")
				$(hotspot_id).css('font-size', '16px')
		i++
	requestAnimationFrame update
	return
update()
module.exports = root