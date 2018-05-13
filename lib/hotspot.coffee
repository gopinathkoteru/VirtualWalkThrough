root = require("./pano.js")
class hotspot
	constructor: ()->
		@panoid = undefined
		@destroy = false

	load_texture : () ->
		texture = new THREE.Texture window.texture_placeholder
		material = new THREE.MeshBasicMaterial( { map: texture, overdraw: 0 ,side: THREE.DoubleSide ,depthTest: false, depthWrite: true, opacity: 1, transparent: true } )
		image = new Image();
		image.onload = ->
			image.onload = null
			texture.image = this
			texture.needsUpdate = true
		image.src = '../test/images/logo.png' 
		return material

	add_hotspot :(angle, hotspotId, dfrd) ->
		geometry = new THREE.PlaneBufferGeometry( 5, 5, 5 )
		material = @load_texture()
		hotspot = new THREE.Mesh( geometry, material )
		rad_angle = THREE.Math.degToRad( angle )
		hotspot.position.x = 40*Math.cos(rad_angle)
		hotspot.position.y = -10
		hotspot.position.z = 40*Math.sin(rad_angle)
		hotspot.renderOrder = 1
		v = new (THREE.Vector3)(-hotspot.position.x, 400, -hotspot.position.z)
		hotspot.lookAt(v)
		geometry = new THREE.PlaneBufferGeometry( 1, 1, 1 )
		panoid = @panoid
		text_to_show = ""
		if root.house[panoid][HOTSPOTS][hotspotId][TEXT] != undefined
			text_to_show = root.house[panoid][HOTSPOTS][hotspotId][TEXT]
		hotspot.panoid = root.house[panoid][HOTSPOTS][hotspotId][TO_ID]
		hotspot.deg_angle = angle
		
		container = $("#"+DirectPano.pano_div_id)
		text = $("<div></div>",{id : "hotspot_" + root.house[panoid][HOTSPOTS][hotspotId][TO_ID]})
		text.html(text_to_show)
		$("#" + DirectPano.pano_div_id).append(text)

		hotspot.hotspot_id = hotspotId
		hotspot.name = "hotspot"
		root.scene.add( hotspot )
		dfrd.resolve()
		return

	add_hotspots :(panoid) ->
		@panoid = panoid
		num_hotspots = root.house[panoid][HOTSPOTS].length
		dfrd = []
		i = 0
		while i < num_hotspots
			dfrd[i] = $.Deferred()
			i++
		i = 0
		while i < num_hotspots
			if @destroy
				@remove_hotspots()
				return
			@add_hotspot root.house[panoid][HOTSPOTS][i][ANGLE] ,i , dfrd[i]
			i++
		$.when.apply($, dfrd).done(->).promise()

	remove_hotspots :->
		len = root.scene.children.length
		p = 0
		i = 0
		while i < len
			object = root.scene.children[ p ]
			if object.name == "hotspot"
				object.geometry.dispose()
				object.material.dispose()
				root.scene.remove(object)
				$("#hotspot_" + object.panoid).remove()
			else
				p += 1
			i++
		return

	front_nearest_hotspot :(panoid)->	
		num_hotspots = root.house[panoid][HOTSPOTS].length
		near_id = -1
		near_angle = undefined
		flag = false
		i = 0
		while i < num_hotspots
			temp = root.house[panoid][HOTSPOTS][i][ANGLE]
			lon = (root.Config.lon + 360) % 360
			if temp < 0
				temp += 360
			if( ((lon>=45) &&(lon<=315) && (temp<=(lon+45)%360) &&(temp>=(lon-45+360)%360)) || ((lon<=45) && (temp>=0) && (temp<=lon+45)) || ((lon<=45)&&(temp>=(lon-45+360)%360) && (temp<=360)) ||  ((lon>=315) && (temp>=(lon-45)) && (temp<=360)) || ((lon>=315)&&(temp>=0) &&(temp<= (lon+45)%360)) )
				if flag == false || ((Math.abs temp - lon) < (Math.abs near_angle - lon))
					near_angle = temp
					near_id = i
					flag = true
			i++
		return near_id

	back_nearest_hotspot : (panoid) ->
		num_hotspots = root.house[panoid][HOTSPOTS].length
		near_id = -1
		near_angle = undefined
		flag = false
		i = 0
		while i < num_hotspots
			temp = root.house[panoid][HOTSPOTS][i][ANGLE]
			lon = (root.Config.lon + 360 + 180) % 360
			if temp < 0
				temp += 360
			if( ((lon>=45) &&(lon<=315) && (temp<=(lon+45)%360) &&(temp>=(lon-45+360)%360)) || ((lon<=45) && (temp>=0) && (temp<=lon+45)) || ((lon<=45)&&(temp>=(lon-45+360)%360) && (temp<=360)) ||  ((lon>=315) && (temp>=(lon-45)) && (temp<=360)) || ((lon>=315)&&(temp>=0) &&(temp<= (lon+45)%360)) )
				if flag == false || ((Math.abs temp - lon) < (Math.abs near_angle - lon))
					near_angle = temp
					near_id = i
					flag = true
			i++
		return near_id
	destroy_hotspot :->
		@destroy = true
		@remove_hotspots()

	update: () ->
		len = root.scene.children.length
		i = 0
		while i < len
			object = root.scene.children[ i ]
			if object.name == "hotspot"
				text = $("#hotspot_" + object.panoid)
				vector = object.position.clone()
				rad_angle =THREE.Math.degToRad((object.deg_angle+5))
				vector.x += 13*Math.cos(rad_angle)
				vector.z += 13*Math.sin(rad_angle)
				vector = vector.project(root.camera)
				container = $("#" + DirectPano.pano_div_id)
				pos =
					x: (vector.x + 1)/2 * container.outerWidth()
					y: -(vector.y - 1)/2 * container.outerHeight()
				if text
					if(vector.x > 1 or vector.x < -1 or vector.y > 1 or vector.y < -1 or vector.z > 1 or vector.z < -1)
						if( text.css('display') != 'none')
							text.removeAttr('style')
							text.css({
								'display': 'none'
							})
					else
						text.css({
							'display': 'block',
							'left': '-10px',
							'top': '0px',
							'transform': 'translate3d(' + (pos.x) + 'px,' + (pos.y) + 'px,0px)',
							'text-align': 'left',
							'color':  'Yellow',
							'position': 'absolute',
							'margin-left': '-20px'
						})
			i++
		return
root.hotspot = hotspot
module.exports = root