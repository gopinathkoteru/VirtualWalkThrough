root = require("./annotation.js")
class transition
	constructor:() ->
		@current_pano = 0
		@moving = false
		@destroy = false 
		
		root.clear_images = {}
		root.blur_images = {}

		path = root.house[@current_pano][PATH]
		blur_path = root.house[@current_pano][BLUR_PATH]

		@blur_pano = new root.Pano(0,true)
		@clear_pano = new root.Pano(0, false)

		@blur_pano.create_pano( blur_path, 0.0)
		@clear_pano.create_pano(path, 1.0).done ->
			time = 1000
			$("#start-image").fadeTo(time, 0,->
				$("#start-image").remove()
				root.Config.isUserInteracting = false
				return)

		@preload_images().done =>
			@preload_panel_images()
			return

		return

	save_clear_images: ->
		current_pano = @current_pano
		num_slices = (@clear_pano.img_width / @clear_pano.tile_width) * (@clear_pano.img_width / @clear_pano.tile_width)
		i = 0
		while i < 6
			do ->
				texture = new THREE.Texture( root.texture_placeholder )
				image_index = i
				j = 0
				while j < num_slices
					do ->
						offset = j
						path = root.house[current_pano][PATH]
						path = path.replace(/%s/g,root.Config.img_name[i])
						path = path.replace(/%h/g,j%2 + 1)
						path = path.replace(/%v/g,parseInt(j/2) + 1)
						if not root.clear_images[path]
							image = new Image()
							image.onload = ->
								image.onload = null
								texture.image = this
								texture.needsUpdate = true
								console.log(path)
								root.clear_images[path] = image
								return
							
							image.src = path
						return
					j++
				return
			i++
		return

	preload_images:->
		i = 0
		j = 0
		dfrd = []
		current_pano = @current_pano
		while i < root.house[current_pano][HOTSPOTS].length
			do ->
				pano_id = root.house[current_pano][HOTSPOTS][i][TO_ID]
				dfrd[j++] = $.Deferred()
				fpath = root.house[pano_id][BLUR_PATH]
				if not root.blur_images[fpath]
					texture = new THREE.Texture( root.texture_placeholder )
					image = new Image()
					image.onload = ->
						image.onload = null
						texture.image = this
						texture.needsUpdate = true
						root.blur_images[fpath] = image
						dfrd[j-1].resolve()
						return
									
					image.src = fpath
				return
			i++
		$.when.apply($, dfrd).done(->).promise()

	preload_panel_images: () ->
		i = 0
		while i < Object.keys(root.house).length
			if root.house[i][SIDE_PANEL] == true
				pano_id = i
					
				fpath = root.house[pano_id][BLUR_PATH]
				if not root.blur_images[fpath]
					texture = new THREE.Texture( root.texture_placeholder )
					image = new Image()
					image.onload = ->
						image.onload = null
						texture.image = this
						texture.needsUpdate = true
						root.blur_images[fpath] = image
						return
					image.src = fpath
			i++
		return

	start : (hotspot_id, panoId) ->
		current_pano = @current_pano
		pano_id = null
		error = 0
		hotspot_angle = 0
		rotate_angle = 0
		dist = 0
		if hotspot_id != null
			pano_id = root.house[current_pano][HOTSPOTS][hotspot_id][TO_ID]
			hotspot_angle = root.house[current_pano][HOTSPOTS][hotspot_id][ANGLE]
			error = root.house[current_pano][HOTSPOTS][hotspot_id][ERROR]
			dist = 60
		else
			pano_id = panoId
			error = 0

		$('div[id^=panos-list-entry-]').removeClass('active')
		title = root.house[pano_id][TITLE]
		i = 0
		while i < Object.keys(root.house).length
			if root.house[i][TITLE] == title and root.house[i][SIDE_PANEL] == true
				$('#panos-list-entry-' + i).addClass('active')
				break
			i++
		@moving = true
		@current_pano = pano_id
		@save_clear_images()

		if hotspot_id!=null
			rotate_angle = @find_rotation_angle(hotspot_angle)
		else
			root.Config.lon = root.house[pano_id][START_POSITION]
			root.Config.lat = 0

		root.Hotspot.remove_hotspots()
		root.Annotation.remove_annotations()

		@preload_images()
		@load_blur_pano(error,hotspot_angle,dist).done =>
			@old_pano_to_blur_pano(error,hotspot_angle,rotate_angle,dist)
			return
	
		return
		
	find_rotation_angle : (hotspot_angle)->
		
		rotate_angle = hotspot_angle - root.Config.lon

		while rotate_angle > 180
			rotate_angle = rotate_angle - 360

		while rotate_angle < -180
			rotate_angle = rotate_angle + 360

		if rotate_angle > 50
			rotate_angle = (rotate_angle - 180) % 360
		else if rotate_angle < -50
			rotate_angle = (rotate_angle + 180) % 360

		rotate_angle = rotate_angle + root.Config.lon
		return rotate_angle

	load_blur_pano : (error,hotspot_angle,dist)->
		if @destroy
			return $.when().done(->).promise()
		dfrd = []
		num_slices = (@blur_pano.img_width / @blur_pano.tile_width) * (@blur_pano.img_width / @blur_pano.tile_width)
		i = 0
		while i < 6*num_slices
			dfrd[i] = $.Deferred()
			i++
		
		@blur_pano.pano_id = @current_pano
		i = 0
		while i < 6
			j = 0
			while j < num_slices
				path = root.house[@current_pano][PATH]
				path = path.replace(/%s/g,root.Config.img_name[i])
				path = path.replace(/%h/g,j%2 + 1)
				path = path.replace(/%v/g,parseInt(j/2) + 1)
				console.log(path)
				
				@blur_pano.mesh.children[i].children[j].material.map.dispose()
				
				if root.clear_images[path]
					@blur_pano.mesh.children[i].children[j].material.map = @blur_pano.load_clear_texture(path, dfrd[num_slices*i + j])
				else
					path = root.house[@current_pano][BLUR_PATH]
					@blur_pano.mesh.children[i].children[j].material.map = @blur_pano.load_blur_texture(path, dfrd[num_slices*i + j] , i)
				
				@blur_pano.mesh.children[i].children[j].material.opacity = 0
				j++
			i++
		
		@blur_pano.mesh.rotation.y = THREE.Math.degToRad(error)	
		@blur_pano.mesh.position.x = dist*Math.cos(THREE.Math.degToRad(hotspot_angle ))
		@blur_pano.mesh.position.z = dist*Math.sin(THREE.Math.degToRad(hotspot_angle ))

		$.when.apply($, dfrd).done(->).promise()

	load_clear_pano :(error) ->
		if @destroy
			return $.when().done(->).promise()
		
		
		dfrd = []
		num_slices = (@clear_pano.img_width / @clear_pano.tile_width) * (@clear_pano.img_width / @clear_pano.tile_width)
		i = 0
		while i < 6*num_slices
			dfrd[i] = $.Deferred()
			i++
		
		@clear_pano.pano_id = @current_pano
		@clear_pano.mesh.rotation.y = THREE.Math.degToRad(error)
		i = 0
		while i < 6
			j = 0
			while j < num_slices
				path = root.house[@current_pano][PATH]
				path = path.replace(/%s/g,root.Config.img_name[i])
				path = path.replace(/%h/g,j%2 + 1)
				path = path.replace(/%v/g,parseInt(j/2) + 1)
				console.log(path)
				@clear_pano.mesh.children[i].children[j].material.map.dispose()
				@clear_pano.mesh.children[i].children[j].material.map = @clear_pano.load_clear_texture(path, dfrd[num_slices*i + j])
				@clear_pano.mesh.children[i].children[j].material.opacity = 0
				j++
			i++

		$.when.apply($, dfrd).done(->).promise()

	old_pano_to_blur_pano :(error,hotspot_angle,rotate_angle,dist) ->
		console.log(dist)
		if @destroy
			return
		time1 = 0.1
		if dist
			time1 = 0.4
			TweenLite.to(root.Config, time1, {lon: rotate_angle, lat: 0, ease: Power0.easeOut})

		time = 1
		del = 0
		if dist
			time = 2
			del = 0.3
		blur_pano = @blur_pano
		clear_pano = @clear_pano

		TweenLite.to(blur_pano.mesh.position, time, {x: 0, z: 0, delay:del,ease: Expo.easeOut})

		blur_num_slices = (@blur_pano.img_width / @blur_pano.tile_width) * (@blur_pano.img_width / @blur_pano.tile_width)
		i = 0
		while i < 6
			j = 0
			while j < blur_num_slices
				TweenLite.to(blur_pano.mesh.children[i].children[j].material, time, {opacity: 1, delay:del,ease: Expo.easeOut})
				j++
			i++

		clear_num_slices = (@clear_pano.img_width / @clear_pano.tile_width) * (@clear_pano.img_width / @clear_pano.tile_width)
		i = 0
		while i < 6
			j = 0
			while j < clear_num_slices
				TweenLite.to(clear_pano.mesh.children[i].children[j].material, time, {opacity: 0,delay:del, ease: Expo.easeOut})
				j++
			i++
		TweenLite.to(clear_pano.mesh.position, time, {x:-1*dist*Math.cos(THREE.Math.degToRad(hotspot_angle )),z:-1*dist*Math.sin(THREE.Math.degToRad(hotspot_angle )),delay:del,ease: Expo.easeOut,onComplete: @check_new_pano_load.bind(this),onCompleteParams : [error]})
		
		return

	check_new_pano_load : (error)->
		if @destroy
			return

		@clear_pano.mesh.position.x = 0
		@clear_pano.mesh.position.z = 0

		clear_num_slices = (@clear_pano.img_width / @clear_pano.tile_width) * (@clear_pano.img_width / @clear_pano.tile_width)
		i = 0
		while i < 6
			j = 0
			while j < clear_num_slices
				@clear_pano.mesh.children[i].children[j].material.opacity = 0
				@clear_pano.mesh.children[i].children[j].material.map.dispose()
				j++
			i++

		blur_num_slices = (@blur_pano.img_width / @blur_pano.tile_width) * (@blur_pano.img_width / @blur_pano.tile_width)
		while i < 6
			j = 0
			while j < blur_num_slices
				@blur_pano.mesh.children[i].children[j].material.opacity = 1
				j++
			i++

		@load_clear_pano(error).done =>
			@blur_pano_to_new_pano(error)
			return
		return

	blur_pano_to_new_pano : (error)->
		if @destroy
			return
		blur_pano = @blur_pano
		clear_pano = @clear_pano
		time = 0.5
		blur_num_slices = (@blur_pano.img_width / @blur_pano.tile_width) * (@blur_pano.img_width / @blur_pano.tile_width)
		i = 0
		while i < 6
			j = 0
			while j < blur_num_slices
				TweenLite.to(blur_pano.mesh.children[i].children[j].material, time, {opacity: 0, ease: Power0.easeOut})
				j++
			i++
		i = 0

		clear_num_slices = (@clear_pano.img_width / @clear_pano.tile_width) * (@clear_pano.img_width / @clear_pano.tile_width)
		while i < 6
			j = 0
			while j < clear_num_slices
				if i is 5 and j is (clear_num_slices-1)
					TweenLite.to(clear_pano.mesh.children[i].children[j].material, time, {opacity: 1, ease: Power0.easeOut, onComplete: @complete.bind(this),onCompleteParams : [error]})
				else
					TweenLite.to(clear_pano.mesh.children[i].children[j].material, time, {opacity: 1, ease: Power0.easeOut})
				j++
			i++
		return

	complete : (error)->
		if @destroy
			return
		
		@clear_pano.mesh.rotation.y = 0
		root.Config.lon += error
		pano_id = @current_pano
		root.Hotspot.add_hotspots(pano_id).done =>
			root.Annotation.add_annotations(pano_id)
			@moving = false
			return
		return

	destroy_transition : ()->
		@destroy = true
		blur_pano = @blur_pano
		clear_pano = @clear_pano
		TweenLite.killTweensOf(blur_pano);
		TweenLite.killTweensOf(clear_pano);
		
		@blur_pano.destroy_pano()
		@clear_pano.destroy_pano()

		@blur_pano = null
		@clear_pano = null
		return

root.transition = transition
module.exports = root

			
			



