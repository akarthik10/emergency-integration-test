var map;
var mapMarkers = {};
var currentInfoWindow;

function centerMap(lat,lon){
	var latlng = new L.LatLng(lat,lon);
	map.setZoom(12);
	map.panTo(latlng,{animate: true});
}

function spotterReportResourceLoaded(reportID){
	var marker = this.mapMarkers[reportID];
	// TO-DO : Do once all resources are loaded 
	if(marker._popup != undefined){ 
			var popup = marker._popup
			// http://stackoverflow.com/questions/22538473/leaflet-center-popup-and-marker-to-the-map
      var px = map.project(popup._latlng); // find the pixel location on the map where the popup anchor is
      px.y -= popup._container.clientHeight/2 // find the height of the popup container, divide by 2, subtract from the Y axis of marker location
      map.panTo(map.unproject(px));

	}
}

function mapShowMarkerInfo(map,reportID,title,description,images,videos,tableLink=false){
	var marker = this.mapMarkers[reportID];
	if(marker._popup == undefined){
		if(tableLink) {
			map.setZoom(12);
			map.panTo(marker._latlng);
		}
		var imageTags = "";
		if(images.length>0){
			var imagesArray = images.split(',');
			if(images != "" && imagesArray.length > 0){
				for(var i = 0; i<imagesArray.length; i++){
					imageTags += '<img src="'+imagesArray[i]+'" class="img-responsive center-block" onload="spotterReportResourceLoaded('+reportID+');">';
				}
			}
		}
		var videoTags = "";
		if(videos){
			var videosArray = videos.split(',');
			if(videos != "" && videosArray.length > 0){
				for(var i = 0; i<videosArray.length; i++){
					videoTags += '<video class="center-block" width="250" height="250" controls autobuffer autoplay onloadstart="spotterReportResourceLoaded('+reportID+');"><source src="'+videosArray[i]+'" type="video/mp4"><video/>';
				}
			}
		}
		var contentString = '<div class="infowindow pre-scrollable"><h4>'+title+'</h4><p>'+description+'</p><div class="info_images">'+imageTags+'</div><div class="info_videos">'+videoTags+'</div></div>';
		
		marker.bindPopup(contentString, {maxWidth: 350, minWidth: 250, maxHeight: 350, autoPan: false, closeButton: true});
		marker.openPopup();
	}
	else{
		if(tableLink) { // Only if clicked through a Table Link in the Left side Bar
			map.setZoom(12);
			map.panTo(marker._latlng);
			marker.closePopup();
			marker.openPopup();
			spotterReportResourceLoaded(reportID);
		}
		else {
			marker.openPopup();
		}
		
	}
	
}