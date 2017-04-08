@extends('layouts.sidebar_layout')

@section('title')
  Spotter Reports
@stop

@section('assets')
  <link rel="stylesheet" href="style.css">
  <link rel="stylesheet" href="css/custom_map.css">
  <script src="main.js"></script>
@stop

@section('sidebar')

  <div>
            <div class="box box-info">
            <div class="box-header with-border">
              <h3 class="box-title">{{$title}}</h3>
            </div>
            <!-- /.box-header -->
            <div class="box-body pre-scrollable spotter-reports-table">
              @if (count($reports) >= 1)
                <div class="table-responsive">
                  <table class="table no-margin">
                    <thead>
                    <tr>
                      <th>Summary</th>
                      <th>Device</th>
                      <th>Details</th>
                    </tr>
                    </thead>
                    <tbody>
                      <?php 
                        foreach($reports as $report) {
                          
                          $latLon = $report->lat.",".$report->lon;
                          $title = str_replace(array("\r", "\n"), '', $report->title);
                          if(!isset($title) || $title == ""){
                            $title = "No description";
                          }
                          $description = str_replace(array("\r", "\n"), '', $report->description);
                          $images = $report->images;
                          $videos = $report->videos;
                          
                          $imagesJSONString = "";
                          if(count($images) > 0){
                            foreach($images as $image){
                              $imagesJSONString .= $image->url.",";
                            }
                          }

                          $videosJSONString = "";
                          if(count($videos) > 0){
                            $stringVideos = array();
                            foreach($videos as $video){
                              $videosJSONString .= $video->url.",";
                            }
                          }

                        ?>
                      <tr>
                        <td>
                          <strong>
                            <a href="javascript:void(0)" onclick="centerMap(<?php echo $latLon; ?>);mapShowMarkerInfo(map,<?php echo $report->id; ?>,'<?php echo $title; ?>','<?php echo $description; ?>','<?php echo $imagesJSONString; ?>','<?php echo $videosJSONString; ?>', true);"><?php echo $title; ?></a>
                          </strong>
                          <br><span class="report_date"><?php echo $report->getCreatedPrettyString(); ?></span>
                          <?php 
                            if(count($images) > 0){
                              ?><span class="icon"><img src="images/icns/photo.png"></span>
                              <?php
                            }
                            if(count($videos) > 0){
                              ?><span class="icon"><img src="images/icns/video.png"></span>
                              <?php
                            }
                          ?>
                          </td>
                        <td class="valign" style="width: 75px;" align="center">
                          <a href="{{ route('spotterReports.index') }}?user=<?php echo $report->userID;?>"><?php echo $report->userID; ?></a><br>
                        </td>
                        <td class="valign" style="width: 75px;" align="center">
                          <a href="{{ route('spotterReports.index') }}?report=<?php echo $report->id; ?>"><span class="icon small_icon"><img src="images/icns/info.png"></span></a><br>
                        </td>
                      </tr>

                        <?php
                        }
                      ?>
                    </tbody>
                  </table>
                </div>
              @elseif (count($reports) == 0)
                <div>
                  No Spotter Reports to Display
                </div>
              @endif
              <!-- /.table-responsive -->
            </div>
            <!-- /.box-body -->
          </div>
      
  </div>
@stop
@section('main_content')
  <div class="" id="map" align="center"></div>
  <style>#map{height: 580px;}</style>
  <script>
    var polygonCoords = [];
    var bounds;
    function initSpotterReportMap() {
        // Create a map object and specify the DOM element for display.
      bounds = new L.LatLngBounds();
      var i; 
      var myLatLng = new L.LatLng(latitude,longitude);
      var mapDiv = document.getElementById('map');
      var mapOptions = {drawControl: false, zoomControl: false}
      map = L.map(mapDiv, mapOptions);

      // create the tile layer with correct attribution
      var osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
      var osmAttrib='Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors';
      var osm = new L.TileLayer(osmUrl, {minZoom: 0, maxZoom:200, attribution: osmAttrib});   

      // start the map based on latitude and longitude passed to it.
      map.setView([latitude, longitude],12);
      map.addLayer(osm);
      L.control.zoom({
           position:'bottomright'
      }).addTo(map);

      @if (count($reports) >= 1)
        <?php 
          $i = 0;
          foreach($reports as $report) {
            $reportID = $report->id;
            $lat = $report->lat;
            $lon = $report->lon;
            $title = str_replace(array("\r", "\n"), '', $report->title);
            $description = str_replace(array("\r", "\n"), '', $report->description);
            if($i == 0){
              $firstLat = $lat;
              $firstLon = $lon;
            }
            $images = $report->images;
            $videos = $report->videos;
            
            $imagesJSONString = "";
            if(count($images) > 0){
              foreach($images as $image){
                $imagesJSONString .= $image->url.",";
              }
            }

            $videosJSONString = "";
            if(count($videos) > 0){
              $stringVideos = array();
              foreach($videos as $video){
                $videosJSONString .= $video->url.",";
              }
            }
            ?>
            
            addMarker(map,'<?php echo $reportID; ?>','<?php echo $title; ?>','<?php echo $description; ?>','<?php echo $imagesJSONString; ?>','<?php echo $videosJSONString; ?>',[<?php echo $lat.", ".$lon; ?>])
            <?php
            $i++;
          }
        ?>
      
        polygonCoords.push(new L.LatLng(<?php echo $firstLat.", ".$firstLon;  ?>));
          
        for (i = 0; i < polygonCoords.length; i++) {
           bounds.extend(polygonCoords[i]);
        }
        
        // The Center of the polygon
        // var latlng = bounds.getCenter();
        // map.panTo(latlng);
        // debugger;
        // map.fitBounds(bounds);
        map.fitWorld();
      @endif
    }
    function addMarker(map, reportID,title,description,images,videos,latlon){
      polygonCoords.push(latlon);
      var marker = L.marker(latlon);
      map.addLayer(marker);
      marker.on('click', function() {
        var marker = this;
        if(marker._popup==undefined)
          mapShowMarkerInfo(map,reportID,title,description,images,videos);
      });
      mapMarkers[reportID] = marker;
    }

    jQuery(document).ready(function(){
      initSpotterReportMap();
    });
  </script>
@stop

