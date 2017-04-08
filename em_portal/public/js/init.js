function initAlertPortal() {
  usersGroup = L.layerGroup();
  circlesGroup = L.layerGroup();
  var amherstLatitude = 42.39;
  var amherstLongitude = -72.529;
  initmap(amherstLatitude, amherstLongitude);
}

function initmap(latitude, longitude) {
  // set up the map
  var mapOptions = {drawControl: false, zoomControl: false}
  map = new L.Map('map', mapOptions);

  // create the tile layer with correct attribution
  var osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  var osmAttrib='Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors';
  var osm = new L.TileLayer(osmUrl, {minZoom: 8, attribution: osmAttrib});   

  // start the map based on latitude and longitude passed to it.
  map.setView(new L.LatLng(latitude, longitude),12);
  map.addLayer(osm);
  L.control.zoom({
       position:'bottomright'
  }).addTo(map);

  // var polygonNotifications = new L.FeatureGroup();

  map.addControl(drawControl);
  setupMapData(map);
  setupMapEvents(map);
  // map.addLayer(polygonNotifications);

  var windowparams = new URLSearchParams(window.location.search);
  var windowproxy = windowparams.get('proxy');
  if(windowproxy){
      proxy = windowproxy;
  }

  loadAttributes();

  //loadPdata();
  //plotData();
  setInterval(function(){
    plotData();
    updatePdata();
  }, 20000); // load data every 20s
  // setupButtons();
}


function loadAttributes(){
  $.get( "data/attributes.json", function( data ) {
    // var json = JSON.parse(data);
    attributesList = AttributesList.createAttributes(data);
    updateUIForAttributes();
  });
  
}

function updateUIForAttributes(){
  for(var i = 0; i<attributesList.attributes.length; i++){

    var attribute = attributesList.attributes[i];
    var name = attribute.name;
    var title = attribute.title;
    var type = attribute.type;
    var options = attribute.options;

    if (type == "range") {

    } else if (type == "number") {

    }else if (type == "text") {

    }

    var div = "<div class='form-group'></div>";
    var divObject = $(div).appendTo('#polygon-notification-form');

    var label = "\n<label class='col-sm-3 control-label'>" + title + "</label>\n";
    var labelObject = divObject.html(label);

    var div2Object = $("\n<div class='col-sm-9'></div>\n").appendTo(labelObject);

    // now add all options
    var optionsHTML = "";
    for (var j = 0; j < options.length; j++){

      var option = options[j];
      var inputType = "number";
      var id = attribute.getAttributeIDName().toLowerCase()+"-"+option.name.toLowerCase();

      if(option.type == "number"){

        optionsHTML = optionsHTML + "\n<input type='number' name='"+id+"' id='"+id+"' value='"+option.value+"' placeholder='"+option.title+"' />\n"

      } else if(option.type == "bool"){

        optionsHTML = optionsHTML + "\n<label class='checkbox-inline'>\n<input type='checkbox' name='"+option.name+"' id='"+id+"' value='"+option.value+"' /> "+option.title+" \n</label>\n"
      }

    }
    div2Object.html(optionsHTML);
  }

}