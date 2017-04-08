/*******************************************************************************
INFORMAÇÕES DE IDENTIFICAÇÃO DA VERSÃO
Versão: 1.0                    Data: 28/06/2016 21:50
Objetivo/Manutenção: Primeira carga de usuários
Autor: Peron Rezende
*******************************************************************************/

var p_data = {};
var listGuid = ["9FB0598B53C9686B256953CA1DB2F6859F9DD2E2"];
var LOAD_USERS = 50;

function randomIntFromInterval(min,max)
{
  return Math.floor(Math.random()*(max-min+1)+min);
}

/*******************************************************************************
' Nome........: responseAllFields
' Objetivo....: Trata resposta do Auspice
' 
' Entrada.....:
' Observação..:
' Atualizações: [01]   Data: 17/06/2016 22:15   Autor: Peron Rezende
*******************************************************************************/


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
    plotData();
  }
}

/*******************************************************************************
' Nome........: insertPdata
' Objetivo....: Insere device no p_data
' 
' Entrada.....:
' Observação..:
' Atualizações: [01]   Data: 29/06/2016 22:30:45   Autor: Peron Rezende
*******************************************************************************/

function insertPdata(count) { 
  var i = 0;
  $(listGuid).each(function(index, value){
    if (i<count) {
      //readArrayRequest(responseAllFields, value, "+ALL+");
      readRequest(responseAllFields, value, "+ALL+");
      //removeOfListGuid(value);
    }
    i++;
  });
}


/*******************************************************************************
' Nome........: updatePdata
' Objetivo....: Atualiza o p_data
' 
' Entrada.....:
' Observação..:
' Atualizações: [01]   Data: 29/06/2016 22:30:45   Autor: Peron Rezende
*******************************************************************************/

function updatePdata() {  
  $.each(p_data, function(index, value){
    //readArrayRequest(responseAllFields, index, "+ALL+");
    readRequest(responseAllFields, index, "+ALL+");
  });
  plotData();
}


/*******************************************************************************
' Nome........: responseNearRequest
' Objetivo....: Trata resposta do Auspice
' 
' Entrada.....:
' Observação..:
' Atualizações: [01]   Data: 28/06/2016 21:50:45   Autor: Peron Rezende
*******************************************************************************/

function responseNearRequest(data, status) {  
  if (status == "success") {
    listGuid = jQuery.parseJSON(data);
    insertPdata(listGuid.length);
/*
    if (listGuid.length > LOAD_USERS) {
      insertPdata(LOAD_USERS);
    } else {
      insertPdata(listGuid.length);
    }
*/
  }
}


/*******************************************************************************
' Nome........: loadPdata
' Objetivo....: Realiza a carga no p_data
' 
' Entrada.....:
' Observação..:
' Atualizações: [01]   Data: 29/06/2016 22:30:45   Autor: Peron Rezende
*******************************************************************************/

function loadPdata() {  

  // create fake data for demo purposes
  var count = 40;
  for(var i = 0; i<count; i++) {

    var defaultLat = 42.38;
    var defaultLon = -72.52;

    var x = Math.random();
    var y = Math.random();
    var left = Math.random() > 0.5;
    var top = Math.random() > 0.5;
    var lat = top ? defaultLat+x*0.01 : defaultLat-x*0.01;
    var lon = left ? defaultLon-y*0.01 : defaultLon+y*0.01;

    var guid = ''+x+'';

    var record = p_data[guid];
    if (record == null) {
      record = {};
      record.gnsUserFields = {}
      record.gnsUserFields.attributes = {};
    }
    //record.gnsUserFields = gnsUserFields;
    record.gnsUserFields.geoLocation = [lat,lon];
    record.gnsUserFields.geoLocationCurrent = { "coordinates": [lat,lon], "type": "Point" };
    record.gnsUserFields.color = ["blue"];
    record.gnsUserFields.attributes.age = randomIntFromInterval(16,50);
    record.gnsUserFields.random = x;

    if(x >= 0 && x <= 0.3){
      record.gnsUserFields.attributes.wheelchair = 1;
    }else if(x > 0.3 && x <= 0.6){
      record.gnsUserFields.attributes.hearingImpaired = 1;
    }else if(x > 0.6 && x <= 1){
      record.gnsUserFields.attributes.visuallyImpaired = 1;
    }
    //console.log(JSON.stringify(record.gnsUserFields.attributesList));

    if("hearingImpaired" in record.gnsUserFields.attributes){
      record.gnsUserFields.deviceID = '81da8cbc252f400098a61b82da62d72719fab671ee14333659d219b2b1f219cf'; // ARUN
      record.gnsUserFields.color = ["blue"];
    }
    if("visuallyImpaired" in record.gnsUserFields.attributes){
      record.gnsUserFields.deviceID = '0e9af3f1afba9075f758e398ff9ff64e73839f97ae16119fe8036c1705815a95'; // ARUN iPad
      record.gnsUserFields.color = ["orange"];
    }
    if("wheelchair" in record.gnsUserFields.attributes){
      record.gnsUserFields.deviceID = '08c7dbf0feba96bf5915df09e96686e02f6f9a7e4b51324f45c8cdf56d5a3edc'; // Görkem iPhone
      record.gnsUserFields.color = ["green"];
    }

    //p_data[guid] = record;
  }

  //selectNearRequest(responseNearRequest, "geoLocationCurrent", "["+longitude+","+latitude+"]", "10000");
  //selectAllUsers(responseNearRequest);

  var southWest = map.getBounds().getSouthWest(); // LatLng
  var northEast = map.getBounds().getNorthEast(); // LatLng

  // test bounds
  //southWest = L.marker([42.095098,-72.939451]).getLatLng();
  //northEast = L.marker([42.624798,-72.164915]).getLatLng();

  selectWithinRequest(responseNearRequest, "geoLocationCurrent.coordinates", [southWest.lng,southWest.lat], [northEast.lng,northEast.lat]);

}
/*******************************************************************************
' Nome........: getPdataValue
' Objetivo....: 
' 
' Entrada.....: i
' Observação..:
' Atualizações: [01]   Data: 06/07/2016 22:30:45   Autor: Peron Rezende
*******************************************************************************/

function getPdataValue(i) { 
  var j = 0;
  var result = "";
  $.each(p_data, function(index, value){
    if (j == i) {
      result = value;
    }
    j++;
  });
  return result;
}
