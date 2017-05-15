/**
 * This file is for Loading GNS Data onto the Alerts Map
 */

// This variable p_data stores GUIDS and the user records and their details
var p_data = {};
var gns = "http://localhost:24703/GNS/";
var users = [];
var pdataMarkers = {}
/**
 * [responseNearRequest inserts Persons Data which reads data from GNS Server and plots it onto the map]
 * @param  {[type]} data   [description]
 * @param  {[type]} status [description]
 * @return {[type]}        [description]
 */
function responseNearRequest(data, status) {  
  if (status == "success") {
    listGuid = jQuery.parseJSON(data);
    insertPdata(listGuid);
  }
}

/**
 * [insertPdata Gets all the data for the list of GUID's]
 * @param  {[type]} count [description]
 * @return {[type]}       [description]
 */
function insertPdata(listGuid) { 
  var i = 0;
  $(listGuid).each(function(index, value){
    if (i<listGuid.length) {
      readRequest(responseAllFields, value, "+ALL+");
    }
    i++;
  });
}

/**
 * [responseAllFields Gets Data and plots it onto the map]
 * @param  {[type]} data   [description]
 * @param  {[type]} status [description]
 * @param  {[type]} jqXHR  [description]
 * @param  {[type]} guid   [description]
 * @return {[type]}        [description]
 */
function responseAllFields(data, status, jqXHR, guid) { 
  if (status == "success") {
    var gnsUserFields;
    try {
      gnsUserFields = jQuery.parseJSON(data);
      console.log("Data read: "+guid);
    } catch (e) {
      // error
      console.log("ERROR Data: "+ JSON.stringify(guid));
      delete p_data[guid];
      return;
    }
    var record = p_data[guid];
    if (record == null) {
      record = {};
    }
    record.gnsUserFields = gnsUserFields;
    p_data[guid] = record;
    plotData(p_data[guid], guid);
  }
}

/**
 * [readRequest Given a Read Request for a given GUID it returns the corresponding  data for the GUID]
 * @param  {[type]} response [description]
 * @param  {[type]} guid     [description]
 * @param  {[type]} field    [description]
 * @return {[type]}          [description]
 */
function readRequest(response, guid, field) {

  var params = new Object();
  params.guid = guid;
  params.field = field;

  var url = gns+"readunsigned";
  request(url,params,'get',true,function( data, status, jqXHR ) {
    response( data, status, jqXHR, guid );
  });

}


/**
 * [selectWithinRequest Issues a select within request to the GNS server to gather all GUID's ]
 * @param  {[type]} response  [description]
 * @param  {[type]} field     [description]
 * @param  {[type]} southWest [description]
 * @param  {[type]} northEast [description]
 * @return {[type]}           [description]
 */
function selectWithinRequest(response, field, southWest, northEast) {
  // http://hazard.hpcc.umass.edu:8080/GNS/selectwithin?field=geoLocationCurrent.coordinates&within=[[-72.939451,42.095098],[-72.164915,42.624798]]
  var within = [];
  within.push(southWest); // [LONG,LAT]
  within.push(northEast); // [LONG,LAT]

  var params = new Object();
  params.field = field;
  params.within = JSON.stringify(within); // [LONG,LAT]
  var url = gns+"selectwithin";
  console.log("AJAX GET: "+gns+"selectwithin"+JSON.stringify(params));
  request(url,params,'get',true,response);

}

/**
 * [request This function is for sending a request ]
 * @param  {[type]} url      [description]
 * @param  {[type]} params   [description]
 * @param  {[type]} method   [description]
 * @param  {[type]} proxy    [Set to True if it is getting through cross domain request]
 * @param  {[type]} response [description]
 * @return {[type]}          [description]
 */
function request(url, params, method, proxy, response) {
  if(proxy){

    var proxyURL = url + "?" + jQuery.param(params,true);
    proxyURL = url + "?" + encodeURIComponent(jQuery.param(params,true));
    var proxyParams = {};
    proxyParams.proxy = proxyURL;

    $.post("/proxy.php", proxyParams )
      .done(function( data, status ) {
          console.log("Proxy Response Data: " + data);
          response( data, status );
        }
      )
      .fail(function(xhr, status, error) {
        console.log("status: " + status);
        console.log("xhr: " + JSON.stringify(xhr));
        console.log("error: " + error);
        response( error, status );
      })
      .always(function() {
        console.log("finished");
      });
  }else{
    if(method == 'get'){
      $.get(url, params )
        .done(function( data, status ) {
            response( data, status );
          }
        ).fail(function(xhr, status, error) {
          console.log("status: " + status);
          console.log("error: " + error);
          response( error, status );
        });
    }else{
      $.post(url, params )
        .done(function( data, status ) {
            response( data, status );
          }
        ).fail(function(xhr, status, error) {
        console.log("status: " + status);
        console.log("error: " + error);
        response( error, status );
      });
    }
  }

}


/**
 * [plotData description]
 * @param  {[type]} personsData [description]
 * @return {[type]}             [description]
 */
function plotData(personsData, guid)
{
  var GNSData = personsData.gnsUserFields;
  if(GNSData){
    var latlng = GNSData.geoLocationCurrent.coordinates.reverse();
    var marker;
    latlng = L.marker([latlng[0], latlng[1]]).getLatLng();
    if(guid in pdataMarkers){
      marker = pdataMarkers[guid];
      marker.setLatLng(latlng).update();
    }
    else{
      
      marker = insertUserOnMap(latlng, alertMap)
      marker.record = GNSData;
      users.push(marker);
      pdataMarkers[guid] = marker;
    }
    marker.record = GNSData;
  }
}

/**
 * [updatePdata updates all the persons data and plots it on the map]
 * @return {[type]} [description]
 */
function updatePdata() {  
  $.each(p_data, function(index, personsData){
    readRequest(responseAllFields, index, "+ALL+");
  });

}

/**
 * [loadPdata Gets data within the given boundaries]
 * @return {[type]} [description]
 */
function loadPdata() {  

  var southWest = alertMap.getBounds().getSouthWest(); // LatLng
  var northEast = alertMap.getBounds().getNorthEast(); // LatLng

  selectWithinRequest(responseNearRequest, "geoLocationCurrent.coordinates", [southWest.lng,southWest.lat], [northEast.lng,northEast.lat]);

}

