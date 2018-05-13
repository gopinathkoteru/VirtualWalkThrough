root = require("./fallback-pano.js")
class Hotspot
	constructor: (pano_id) ->
		@pano_id = pano_id
	
	add_hotspot: (left, top, i, div1, div2) ->
		old_id = @pano_id
		new_id = root.house[old_id][HOTSPOTS][i][TO_ID]
		hotspot_div1 = $("<div></div>", {
			id: "hotspot_" + i + "_0",
			class: "hotspot"
		});
		hotspot =  $("<img  src='../test/images/logo.png' id='hotspot_" + i + "_0'/>")
		hotspot.css('height', '50')
		hotspot.css('width', '50')
		hotspot_annotation1 = $("<p>" + root.house[old_id][HOTSPOTS][i][TEXT] + "</p>")
		hotspot_annotation1.css('color', 'Yellow')
		hotspot_div1.prepend(hotspot)
		hotspot_div1.append(hotspot_annotation1)
		hotspot_div1.on('click',->
			root.transition = new root.Transition(old_id,new_id)
			return)
		div1.append(hotspot_div1)
		
		hotspot_div2 = $("<div></div>", {
	        id: "hotspot_" + i + "_1",
	        class: "hotspot" 
	    });
		hotspot =  $("<img  src='../test/images/logo.png' id='hotspot_" + i + "_1'/>")
		hotspot.css('height', '50')
		hotspot.css('width', '50')
		hotspot_annotation2 = $("<p>" + root.house[old_id][HOTSPOTS][i][TEXT] + "</p>")
		hotspot_annotation2.css('color', 'Yellow')
		hotspot_div2.append(hotspot)
		hotspot_div2.append(hotspot_annotation2)
		hotspot_div2.on('click',->
			root.transition = new root.Transition(old_id,new_id)
			return)
		div2.append(hotspot_div2)
		
		$("#hotspot_" + i + "_0").css('position', 'absolute')
		$("#hotspot_" + i + "_0").css('left', left)
		$("#hotspot_" + i + "_0").css('top', top)
		
		$("#hotspot_" + i + "_1").css('position', 'absolute')
		$("#hotspot_" + i + "_1").css('left', left)
		$("#hotspot_" + i + "_1").css('top', top)
		return

	add_hotspots: () ->
		pano_id = @pano_id
		num_hotspots = root.house[pano_id][HOTSPOTS].length
		img1 = $("#screen1")
		img2 = $("#screen2")
		i = 0
		while i < num_hotspots
			angle = (root.house[pano_id][HOTSPOTS][i][ANGLE] + 85)%360
			left = ((angle/360)*1500) + 'px'
			top = root.height/2 + 'px'
			@add_hotspot(left, top, i, img1, img2)
			i++
		return

	remove_hotspots: () ->
		$(".hotspot").remove()
		i = 0
		pano_id = @pano_id
		num_hotspots = root.house[pano_id][HOTSPOTS].length
		while i < num_hotspots
			$("#hotspot_" + i + "_0").off()
			$("#hotspot_" + i + "_1").off()
			i++
		return

root.Hotspot = Hotspot
module.exports = root
