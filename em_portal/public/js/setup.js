/*******************************************************************************
INFORMAÇÕES DE IDENTIFICAÇÃO DA VERSÃO
Versão: 1.0                    Data: 27/06/2016 13:10
Objetivo/Manutenção: 
Autor: Paulo Mann
*******************************************************************************/

/*******************************************************************************
' Nome........: setupMapEvents
' Objetivo....: 
' 
' Entrada.....:
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function setupMapEvents()
{
  map.whenReady(loadPdata);

  map.on('draw:deleted', function (e) 
  {
    var layers = e.layers;
    layers.eachLayer(function (layer) 
    {
      removePolygon(layer);
    });
  });
  map.on('draw:editstart', function (e)
  {
    //addPolygonsEditOptionEvent();
    //addPolygonsDragOptionEvent();
  })
  map.on('draw:edited', function (e) 
  {
    var layers = e.layers;
    layers.eachLayer(function (layer) 
    {
      var polygon = layer;
      // notifyUsersInsidePolygon(polygon);
      var receivers = polygon.receivers.slice();
      for(var i = 0; i < receivers.length; i++)
        removePolygonNotificationIfOutside(receivers[i]); 
    });
    removePolygonsEditOptionEvent();
  });
  map.on('draw:editstop', function(e)
  {
    removePolygonsEditOptionEvent();
    removePolygonsDragOptionEvent();
  });
  map.on('draw:drawstart', function (e)
  {
    file = null;
    var layerType = e.layerType;
    if(layerType == 'polygon'){
      //createNotificationPolygon();
      createPolygon();  
    }else if(layerType == 'marker'){
      createMarker();
    }
  });
  map.on('draw:created', function (e)
  {
    var layer = e.layer;
    layer.file = file;
    var layerType = e.layerType;
    if(layerType == 'polygon')
    {
      var polygon = layer;
      polygon.summary = $("#polygon-notification-summary").val();
      // polygon.time = $("#polygon-time").val();
      polygon.details = $("#polygon-notification-details").val();
      polygon.messageColor = polygonColor;
      polygon.receivers = [];
      // notifyUsersInsidePolygon(polygon);
      setupPolygonEvents(polygon);
      polygonNotifications.addLayer(polygon);
      createNotificationPolygon(polygon);
      map.addLayer(polygon);
      //TO DO DANIEL- ADD COMMENT
      polygonsDrawn[polygon._leaflet_id] = polygon;
      polygon.on('click', function(e) {
        delete polygonsDrawn[polygon._leaflet_id]
        removeSelectedPolygon(polygon, map)
      });
    }
    else if(layerType == 'marker')
    {
      var marker = layer;
      marker.options.draggable = true;
      marker.addTo(map);
      if(markerType == 'user')
      {
        setupUserEvents(marker, userColor);
        setupNotificationRadius(marker, userColor);
        changeUserState(marker, true);
        var i = getIndexUser(marker);
        var record = getPdataValue(i);  
        var gnsUserFields = record.gnsUserFields;
        notifyIfNotificationsAreNearby(marker, gnsUserFields);
      }
      else
        createNotification(layer);
    }
  });
}

/*******************************************************************************
' Nome........: plotData
' Objetivo....: 
' 
' Entrada.....: p_data
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function plotData()
{
  /*
  usersGroup.eachLayer(function (layer) 
  {
    map.removeLayer(layer);
  });
  circlesGroup.eachLayer(function (layer) 
  {
    map.removeLayer(layer);
  });
  users = [];
  usersGroup = L.layerGroup();
  circles = [];
  circlesGroup = L.layerGroup();
  */
  $.each(p_data, function(index, value)
  {
    var color;
    var guid = index;
    var record = value; 
    var gnsUserFields = record.gnsUserFields; 
    var latlng;
    var j = 0;
    var latitude;
    var longitude;
    $(gnsUserFields.geoLocation).each(function(index, value){
      if (j == 0)
        latitude = value;
      else
        latlng = L.marker([latitude, value]).getLatLng();
      j++;
    });
    j = 0;
    $(gnsUserFields.geoLocationCurrent).each(function(index, value){
      // geoJSON
      if ('coordinates' in value){
        latitude = value.coordinates[1];
        longitude = value.coordinates[0];
        if(latitude && longitude){
          latlng = L.marker([latitude, longitude]).getLatLng();
          color = "blue";
        }else{
          color = "green";
        }
        return false;
      }else{
        if (j == 0)
          latitude = value;
        else
          latlng = L.marker([latitude, value]).getLatLng();
        j++;
      }
    });

    if (guid == "5B50085EA94A8462824390413C6D66381B41A681"){
      color = "red";
    }

    if('accountID' in gnsUserFields && gnsUserFields.accountID == 'edu.umass.arun.UMassEmergency'){
      color = "orange";
    }

    if (!latlng){
      return true;
      var defaultLat = 42.38;
      var defaultLon = -72.52;
      var x = Math.random();
      var y = Math.random();
      var left = Math.random() > 0.5;
      var top = Math.random() > 0.5;
      var lat = top ? defaultLat+x*0.01 : defaultLat-x*0.01;
      var lon = left ? defaultLon-y*0.01 : defaultLon+y*0.01;
      latlng = L.marker([lat,lon]).getLatLng();
    }

/*
    var color;
    $(gnsUserFields.color).each(function(index, value){
      color = value;
    });
*/
    if (!color){
      color = "white";
    }
    var user = record.user;
    if (color && latlng)
    {
      if (user == null) {
        user = insertUserOnMap(color, latlng);
        if (user != null)
        {
          var radius;
          $(gnsUserFields.radius).each(function(index, value){
            radius = value;
          });
          setupNotificationRadius(user, color, radius);
          record.user = user;
          p_data[index] = record;
        }
      } else {
        var popup = user.getPopup();
        if (popup != null) {
          popup.setLatLng(latlng).update(); 
        }
        user.setLatLng(latlng).update();
        user.circle.setLatLng(latlng);
      }
    }
    
    /*usersGroup.eachLayer(function (layer) {
        layer.bindPopup('Hello');
    });*/
  });
  $.each(notifications, function(index, value)
  {
    notifyUsersNearby(value);
  });
  // polygonNotifications.eachLayer(function (layer)
  // {
  //   // notifyUsersInsidePolygon(layer);
  // });
}

/*SETUP MAPS DATA*/
function setupMapData(map) {
  function onEachBuilding(feature, layer) {
    // does this feature have a property named popupContent?
    if (feature.properties && feature.properties.name) {
        layer.bindPopup(feature.properties.name);
    }
    layer.on({
      // mouseover: highlightFeature,
      // mouseout: resetHighlight,
      click: zoomToFeatureAndToggle
    });
  }

  var geojson;

  $.getJSON('js/geojson_data/umass_data.json', function(data) {
    geojson = L.geoJSON(data, {
    onEachFeature: onEachBuilding,
    filter: function(feature, layer) {
          return feature.geometry.type == "Polygon" && (feature.properties.building == "university" || (feature.properties.building == "yes" && feature.properties.name));
      }
    }).addTo(map);
  });

  function zoomToFeatureAndToggle(e) {
    var layer = e.target;
    map.fitBounds(layer.getBounds());
    notificationFormID = 'polygon-notification-form';
    nameOfLayer = layer._popup._content;
    select2Id = "buildingSelection";
    leafletId = layer._leaflet_id;
    if(layer.options.color != grayColor){
      layer.setStyle({
        weight: 5,
        color: grayColor,
        dashArray: '',
        fillOpacity: 0.7
      });
      notificationsBuildings[layer._leaflet_id] = layer;
      addToSelect2InForm(notificationFormID, nameOfLayer, leafletId, select2Id);
    }
    else{
      removeFromSelect2InForm(notificationFormID, nameOfLayer, leafletId, select2Id);
      geojson.resetStyle(layer);
      delete notificationsBuildings[layer._leaflet_id]
    }
  }
}