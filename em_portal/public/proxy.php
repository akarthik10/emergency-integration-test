<?php 
  
  $page = "";
//  $url = "http://hazard.hpcc.umass.edu:8080/GNS/selectwithin?field=geoLocationCurrent.coordinates&within=[[-72.939451,42.095098],[-72.164915,42.624798]]";
  $url = "";
  if(isset($_REQUEST['proxy'])){
    $url = $_REQUEST['proxy'];
    //print_r($url);
    //echo "<br>";
  }
  $page = file_get_contents($url);
  echo $page;
?>