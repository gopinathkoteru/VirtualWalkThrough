root = {}
size = 256/2
offset = [
		{
			position: [
				-size/2
				size/2
				0
			]
		}
		{
			position:[
				size/2
				size/2
				0
			]
		}
		{
			position: [
				-size/2
				-size/2
				0
			]
		}
		{
			position:[
				size/2
				-size/2
				0
			]
		}
]
dist = 256/2
sides = [
  {
    position: [
      -1*dist
      0
      0
    ]
    rotation: [
      0
      Math.PI/2
      0
    ]
  }
  {
    position: [
      dist
      0
      0
    ]
    rotation: [
      0
      -Math.PI/2
      0
    ]
  }
  {
    position: [
      0
      dist
      0
    ]
    rotation: [
      Math.PI / 2
      0
      Math.PI
    ]
  }
  {
    position: [
      0
      -1*dist
      0
    ]
    rotation: [
      -Math.PI / 2
      0
      Math.PI
    ]
  }
  {
    position: [
      0
      0
      dist
    ]
    rotation: [
      0
      Math.PI
      0
    ]
  }
  {
    position: [
      0
      0
      -1*dist
    ]
    rotation: [
      0
      0
      0
    ]
  }
]
class Pano
	constructor: (@pano_id) ->
		@name = "panorama"
		@destroy = false

		@img_width = 512
		@tile_width = 512

	create_pano: (opacity) ->
		@mesh = new THREE.Object3D()
		dfrd = []
		num_slices = (@img_width / @tile_width) * (@img_width / @tile_width)
		i = 0
		while i < 6*num_slices
			dfrd[i] = $.Deferred()
			i++
		path1 = root.pano_paths[@pano_id]
		i = 0
		while i < 6
			j = 0
			slices = new THREE.Object3D()
			while j < num_slices
				path = path1
				path = path.replace(/%s/g,root.Config.img_name[i])
				path = path.replace(/%h/g,j%2 + 1)
				path = path.replace(/%v/g,parseInt(j/2) + 1)
				console.log(path)
				texture = @load_clear_texture(path ,dfrd[num_slices*i+j])

				material = new THREE.MeshBasicMaterial( { map: texture, overdraw: 0 ,side:THREE.DoubleSide,blending: THREE.AdditiveBlending ,depthTest: false } )
				geometry = new THREE.PlaneBufferGeometry(256/Math.sqrt(num_slices), 256/Math.sqrt(num_slices), 7, 7)
				slice = new THREE.Mesh geometry , material
					
				slice.material.transparent = true
				slice.material.opacity = opacity
				if num_slices == 1
					slice.position.x = 0
					slice.position.y = 0
					slice.position.z = 0
				else
					slice.position.x = offset[j].position[0]
					slice.position.y = offset[j].position[1]
					slice.position.z = 0
					
				slices.add(slice)
				j++
			slices.rotation.x = sides[i].rotation[0]
			slices.rotation.y = sides[i].rotation[1]
			slices.rotation.z = sides[i].rotation[2]

			slices.updateMatrix()

			slices.position.x = sides[i].position[0]
			slices.position.y = sides[i].position[1]
			slices.position.z = sides[i].position[2]

			slices.updateMatrix()

			@mesh.add(slices)
			i++
		root.scene.add @mesh

		return $.when.apply($, dfrd).done(->).promise()
		
	destroy_pano: () ->
		@destroy = true
		root.scene.remove(@mesh)
		num_slices = (@img_width / @tile_width) * (@img_width / @tile_width)
		i = 0
		while i < 6
			j = 0
			while j < num_slices
				@mesh.children[i].children[j].material.map.dispose()
				@mesh.children[i].children[j].material.dispose()
				@mesh.children[i].children[j].geometry.dispose()
				@mesh.children[i].children[j] = null
				j++
			@mesh.children[i] = null
			i++
	
	load_clear_texture: (path,dfrd) ->
		texture = new THREE.Texture root.texture_placeholder
		pano_id = @pano_id
		image = new Image();
		
		image.onload = ->
			image.onload = null
			texture.image = this
			texture.needsUpdate = true
			dfrd.resolve()
			
			return
		image.src = path

		return texture

root.Pano = Pano
module.exports = root
