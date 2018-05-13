root = require("./hotspot.js")
object = undefined
class annotation
	constructor:() ->
		@panoid = undefined
		@length = 0
		@destroy = false

	add_annotation:(annotation_id)->
		anno_id = annotation_id
		annotation_id = "annotation_" + annotation_id
		div = $("<div></div>",{id : annotation_id})
		div.prepend("<img class='annotation' height='40px' width='40px' src='../test/images/info.png'></img>
			<div class='hotspot-title'>
				<div class='hotspot-text'>" + root.house[@panoid][ANNOTATIONS][anno_id][TITLE] +
				"</div>
			</div>
			<div class='info-hotspot'>
				" + root.house[@panoid][ANNOTATIONS][anno_id][DESC] +
			"</div>
			")
		$("#" + DirectPano.pano_div_id).append(div)
		anno = $("#" + annotation_id)

		anno.bind 'click touchstart', ->
			if anno.find('.info-hotspot').css('visibility') == 'visible'
				anno.find('.info-hotspot').css('visibility', 'hidden')
				anno.find('.hotspot-title').css('visibility', 'hidden')
				anno.find('.hotspot-title').css('opacity', '0')
				anno.find('.annotation').css('border-radius', '100px')
				return
			else
				anno.find('.info-hotspot').css('visibility', 'visible')
				anno.find('.hotspot-title').css('visibility', 'visible')
				anno.find('.hotspot-title').css('opacity', '1')
				anno.find('.hotspot-title').css('border-radius', '0px 10px 0px 0px')
				anno.find('.annotation').css('border-radius', '10px 0px 0px 0px')
				return
		anno.hover (->
			anno.find('.hotspot-title').css('visibility', 'visible')
			anno.find('.hotspot-title').css('opacity', '1')
			if anno.find('.info-hotspot').css('visibility') == 'hidden'
				anno.find('.hotspot-title').css('border-radius', '0px 10px 10px 0px')
				anno.find('.annotation').css('border-radius', '10px 0px 0px 10px')
			return
		), ->
			if anno.find('.info-hotspot').css('visibility') == 'hidden'
				anno.find('.hotspot-title').css('visibility', 'hidden')
				anno.find('.hotspot-title').css('opacity', '0')
				anno.find('.annotation').css('border-radius', '100px')
			return
		return
	
	add_annotations:(panoid)->
		@panoid = panoid
		try
			@length = root.house[panoid][ANNOTATIONS].length
			i = 0
			while i < @length
				if @destroy
					@remove_annotations()
					return
				@add_annotation(i)
				i++
		catch
			@length = 0
			return
		return

	remove_annotations:->
		i = 0
		while i < @length
			$("#annotation_" + i).remove()
			i++
		return

	destroy_annotation:->
		@destroy = true
		@remove_annotations()
	
	update:()->
		i = 0
		panoid = @panoid
		while i < @length
			annotation_id = "#annotation_" + i
			annotation = $(annotation_id)
			angle = root.house[panoid][ANNOTATIONS][i][LON]
			rad_angle =THREE.Math.degToRad(angle)
			vector = new (THREE.Vector3)(30*Math.cos(rad_angle), root.house[panoid][ANNOTATIONS][i][LAT], 30*Math.sin(rad_angle))
			vector.x += 13*Math.cos(rad_angle)
			vector.z += 13*Math.sin(rad_angle)
			vector = vector.project(root.camera)
			container = $("#" + DirectPano.pano_div_id)
			pos =
				x: (vector.x + 1)/2 * container.outerWidth()
				y: -(vector.y - 1)/2 * container.outerHeight()
			if annotation
				if(vector.x > 1 or vector.x < -1 or vector.y > 1 or vector.y < -1 or vector.z > 1 or vector.z < -1)
					if( annotation.css('display') != 'none')
						annotation.removeAttr('style')
						annotation.css('display', 'none')
				else 
					annotation.css('display', 'inline')
					annotation.css('left', '-10px')
					annotation.css('top', '0px')
					annotation.css('transform', 'translate3d(' + (pos.x) + 'px,' + (pos.y) + 'px,0px)')
					annotation.css('position', 'absolute')
					annotation.css('font-family': "'Helvetica Neue', Helvetica, Arial, sans-serif")
					annotation.css('font-size', '16px')
			i++
		return
root.annotation = annotation
module.exports = root
