root = require('./panel-listeners.js')
root.annotation_count = 0
angle = undefined
angle1 = undefined
onPointerDownPointerX = undefined
onPointerDownPointerY = undefined
onPointerDownLon = undefined
onPointerDownLat =undefined
flag = false
lat = 0
lon = 0
uns_annotation = undefined

$("#add-annotation-button").on('click',->
	annotation_id = "annotation_" + root.annotation_count 
	div = $("<div></div>",{id : annotation_id})
	div.prepend("<img class='annotation' height='40px' width='40px' src='../test/images/info.png'></img>
		<div class='hotspot-title'>
				<div class='hotspot-text'>" + "title"+
				"</div>
			</div>
			<div class='info-hotspot'>
				" + "Description" +
			"</div>
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
	uns_annotation = div
	$("#" + annotation_id).bind 'click touchstart', ->
		if $("#" + annotation_id).find('.hotspot-title').css('visibility') == 'visible' or  $("#" + annotation_id).find('.hotspot-title').css('opacity') == '1'
			$("#" + annotation_id).find('.info-hotspot').css('visibility', 'hidden')
			$("#" + annotation_id).find('.hotspot-title').css('visibility', 'hidden')
			$("#" + annotation_id).find('.hotspot-title').css('opacity', '0')
			$("#" + annotation_id).find('.annotation').css('border-radius', '100px')
			return
		else
			$("#" + annotation_id).find('.info-hotspot').css('visibility', 'visible')
			$("#" + annotation_id).find('.hotspot-title').css('visibility', 'visible')
			$("#" + annotation_id).find('.hotspot-title').css('opacity', '1')
			$("#" + annotation_id).find('.annotation').css('border-radius', '10px 0px 0px 0px')
			return
	return)

$("#fix-annotation-button").on('click',->
	uns_annotation.attr('lat',parseInt(root.Config.lat))
	uns_annotation.attr('lon',parseInt(root.Config.lon))
	uns_annotation.find('.hotspot-text').html($("#annotation-title").val())
	uns_annotation.find('.info-hotspot').html(nl2br($("#annotation-desc").val()))
	root.annotation_count += 1
	return)

root.save_annotation = () ->
	count = 0
	annotation_angles = []
	i = 0
	while i < root.annotation_count
		annotation_id = "#annotation_" + i
		annotation = $(annotation_id)
		data_annotation = {}
		if annotation.length != 0
			data_annotation.lon = parseInt(annotation.attr('lon'))
			data_annotation.lat = parseInt(annotation.attr('lat'))
			data_annotation.title = annotation.find('.hotspot-text').html()
			data_annotation.desc = nl2br(annotation.find('.info-hotspot').html())
			console.log data_annotation 
			annotation_angles[count] = data_annotation
			count = count + 1
			annotation.remove()
		i++
	root.annotation_angles = annotation_angles
	return

nl2br = (str)-> 
	breakTag = '<br>'
	return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1'+ breakTag)
	
update = ()->
	i = 0
	while i < root.annotation_count
		annotation_id = "#annotation_" + i
		annotation = $(annotation_id)
	
		angle = $(annotation_id).attr('lon')
		angle1 = $(annotation_id).attr('lat')
		rad_angle =THREE.Math.degToRad(angle)
		vector = new (THREE.Vector3)(30*Math.cos(rad_angle), angle1, 30*Math.sin(rad_angle))
		vector.x += 13*Math.cos(rad_angle)
		vector.z += 13*Math.sin(rad_angle)
		vector = vector.project(root.camera)
		container = $("#container")
		pos =
			x: (vector.x + 1)/2 * container.outerWidth()
			y: -(vector.y - 1)/2 * container.outerHeight()

		if annotation
			if(vector.x > 1 or vector.x < -1 or vector.y > 1 or vector.y < -1 or vector.z > 1 or vector.z < -1)
					if( $(annotation_id).css('display') != 'none')
						$(annotation_id).removeAttr('style')
						$(annotation_id).css('display', 'none')
			else 
				$(annotation_id).css('display', 'inline')
				$(annotation_id).css('left', '0px')
				$(annotation_id).css('top', '0px')
				$(annotation_id).css('transform', 'translate3d(' + (pos.x) + 'px,' + (pos.y) + 'px,0px)')
				$(annotation_id).css('position', 'absolute')
				$(annotation_id).css('font-family': "'Helvetica Neue', Helvetica, Arial, sans-serif")
				$(annotation_id).css('font-size', '16px')
		i++
	requestAnimationFrame update
	return
update()
module.exports = root