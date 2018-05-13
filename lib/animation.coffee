root = require("./init.js")
time = undefined
lat = undefined
flag = false
class animation
	
	constructor: ->
		@destroy = false
		@animate()
	
	animate : ->
		if not @destroy
			requestAnimationFrame =>
				@animate()
			@update()
			root.Hotspot.update()
			root.Annotation.update()
			if(root.Config.target_lon != undefined and root.Config.current_lon != undefined && Math.abs(root.Config.target_lon - root.Config.current_lon) > 0.1)
				if root.Transition.moving == true
					root.Config.target_lon == undefined
					root.Config.current_lon = undefined
				else
					root.Config.current_lon = (root.Config.current_lon + (root.Config.target_lon - root.Config.current_lon)*0.15)
					root.Config.lon = (root.Config.current_lon + 360)%360
			if(root.Config.target_lat != undefined and root.Config.current_lat != undefined && Math.abs(root.Config.target_lat - root.Config.current_lat) > 0.1)
				if root.Transition.moving == true
					root.Config.target_lat = undefined
					root.Config.current_lat = undefined
				else
					root.Config.current_lat = (root.Config.current_lat + (root.Config.target_lat - root.Config.current_lat)*0.15)
					root.Config.lat = root.Config.current_lat
			if flag==true
				if root.Config.isUserInteracting == true
					flag = false
				else
					duration = Date.now() - time
					if duration < 1000
						root.Config.lat = lat - (lat * duration / 1000)
					else
						flag = false
						root.Config.lat = 0
		return
	
	update : ->
		if root.Config.isUserInteracting == false and root.Config.autoplay == true and root.Transition.moving == false
			root.Config.lon += 0.2
		else if root.Config.isUserInteracting == false
			duration = Date.now() - root.Config.stop_time
			if duration > 2000
				root.Config.autoplay = true
				flag = true
				time = Date.now()
				lat = root.Config.lat
		root.Config.lon = (root.Config.lon + 360) % 360
		root.Config.lat = Math.max(-35, Math.min(35, root.Config.lat))
		phi = THREE.Math.degToRad(90 - (root.Config.lat))
		theta = THREE.Math.degToRad(root.Config.lon)
		root.camera.target.x = 500 * Math.sin(phi) * Math.cos(theta)
		root.camera.target.y = 500 * Math.cos(phi)
		root.camera.target.z = 500 * Math.sin(phi) * Math.sin(theta)
		root.camera.lookAt root.camera.target
		root.renderer.render root.scene, root.camera
		return


root.animation = animation
module.exports = root
