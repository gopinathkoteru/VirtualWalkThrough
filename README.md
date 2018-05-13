# Housing_Panorama
Instructions to make Panorama using panel
- Use KRPano to divide stitched(equirectangular) images into 6 images, so that each image can fit in one cube face
- The output of the above step would generate a vtour directory which will be having panos directory, we will use this panos Directory as the input
- There will be a tour.xml also in the same vtour Directory, this xml file is used as input for panel.
- Now open the panel by opening `lib/panel.html`, on the top left there is an input box where the path of the xml file should be added and then click submit, this will load the pano.
- Now hotspots and annotations can be added. Don't reload the panel.html at any point of time, othrewise the data would be lost
- After all the data is filled through the panel, Just open the console and run the following commands `house = localStorage.getItem('full_dataset');`, `house = JSON.parse(house);` and  `copy(house);`.
- These commands will copy the json data to the clipboard and then this data can be copied to the `test/data.json` file and you can now run it.

Now you need to edit `test/config.js` as per your Dataset
- In this, `DirectPano` object needs to be filled with desired values
- `pano_div_id` is the name of the div element in which pano should be loaded
- `image_div_id` is the name of the div element in which the full screen image will be loaded(such that on clicking this image the pano becomes full screen)
- `initial_width` is the the default width of the `pano_div_id`, if the window width is smaller than initial width, then automatically it will thw width would be changed, same is for `initial_height`.

To run this, do `./run.sh` (currently works only for OSX), this will make a `SimpleHTTPServer` at port 8000 and open a tab in the default browser
