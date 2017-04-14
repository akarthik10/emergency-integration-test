/*******************************************************************************
INFORMAÇÕES DE IDENTIFICAÇÃO DA VERSÃO
Versão: 1.0                    Data: 14/06/2016 17:00
Objetivo/Manutenção: Realizar operações junto ao Auspice
Autor: Peron Rezende
*******************************************************************************/

// Só funciona no Internet Explorer
jQuery.support.cors = true; 
// IP 142.103.2.2
// var gns = "http://planetlab2.cs.ubc.ca:8080/GNS/";
//var gns = "http://localhost:8080/GNS/";
//var gns = "http://date.cs.umass.edu:8082/GNS/";
//var gns = "http://200.20.15.103:8080/GNS/";
var gns = "http://localhost:24703/GNS/";

// Devices planetlab2.cs.cornell.edu
// Mail planetlab1.cesnet.cz

/*******************************************************************************
' Nome........: selectRequest
' Objetivo....: Pesquisa GUIDs por campo
' 
' Entrada.....: response, field, value
' Observação..:
' Atualizações: [01]   Data: 14/06/2016 17:00   Autor: Peron Rezende
*******************************************************************************/
//TODO function selectRequest(selectResponse, field, value)
function selectRequest(response, field, value) {
  // Exemplo: http://localhost:8080/GNS/select?field=bairro&value=Leblon
    
  var params = new Object();
  params.field = field;
  params.value = value;
  
  $.get( gns+"select", params )
    .done(function( data, status ) {
      response( data, status );
    }
  );  
}




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
/*
  $.get( gns+"selectwithin", params )
    .done(function( data, status ) {
        //alert("data: " + data);
        response( data, status );
      }
    );
*/
}


function selectAllUsers(response) {
  // Exemplo: http://localhost:8080/GNS/select?field=bairro&value=Leblon
  console.log("select all users");

  var params = new Object();
  //params.query = "";
  console.log("AJAX GET: "+gns+"selectquery"+JSON.stringify(params));

  var url = gns+"selectquery?query=";
  request(url,params,'get',true,response);

/*
  $.get( gns+"selectquery?query=", params )
    .done(function( data, status ) {
      console.log("Select query status: "+status);
      //console.log("Select query: "+JSON.stringify(data));
      //alert("Select query: "+JSON.stringify(data));
      response( data, status );
      }
    );
*/
}

/*******************************************************************************
' Nome........: selectNearRequest
' Objetivo....: Pesquisa GUIDs por geolocalização
' 
' Entrada.....: response, field, near, maxDistance
' Observação..:
' Atualizações: [01]   Data: 14/06/2016 17:00   Autor: Peron Rezende
*******************************************************************************/
//TODO function selectNearRequest(response, field, near, maxDistance)
function selectNearRequest(response, field, near, maxDistance) {
  // Exemplo: http://localhost:8080/GNS/select?field=geoLocation&near=%5B-22.874631881713867,-43.76070022583008%5D&maxDistance=100000
  var params = new Object();
  params.field = field;
  params.near = near; // [LONG,LAT]
  params.maxDistance = maxDistance;

  var url = gns+"SelectNear";
  request(url,params,'get',true,response);

/*
  $.get( gns+"SelectNear", params )
    .done(function( data, status ) {
      alert("data: " + data);
      response( data, status );
    }
  );  
*/
}

/*******************************************************************************
' Nome........: readArrayRequest
' Objetivo....: Lê campo da GUID
' 
' Entrada.....: response, guid, field
' Observação..:
' Atualizações: [01]   Data: 16/06/2016 16:00   Autor: Peron Rezende
*******************************************************************************/
//TODO function readArrayRequest(selectResponse, guid, field)
function readArrayRequest(response, guid, field) {
  // Exemplo: http://localhost:8080/GNS/readArray?guid=3329813F3E81D966B0567024500FB1B60C96F980&field=geoLocation
  // Retorno: [-22.874631881713867,-43.76070022583008]
  // Exemplo: http://localhost:8080/GNS/readArray?guid=3329813F3E81D966B0567024500FB1B60C96F980&field=nome
  // Retorno: ["Pato Donald"]
  // Exemplo: http://localhost:8080/GNS/readArray?guid=3329813F3E81D966B0567024500FB1B60C96F980&field=+ALL+
  // Retorno: {"bairro":["Leblon"],"telefones":["(21) 8765-4321","(21) 9988-7766"],"geoLocation":[-22.874631881713867,-43.76070022583008],"nome":["Pato Donald"]}
  // Exemplo: Com os campos name ou nr_primary.
  // Retorno: +NO+ +GENERICERROR+
  // Exemplo: Com o campo SERVER_REG_ADDR (que retorna uma lista com IP e Porta do MServerSocket)
  // Retorno: +NO+ +GENERICERROR+
  var params = new Object();
  params.guid = guid;
  params.field = field;

  $.get( gns+"readArray", params )
    .done(function( data, status, jqXHR ) {
      response( data, status, jqXHR, guid );
    }
  );  
}


function readRequest(response, guid, field) {
  // Exemplo: http://localhost:8080/GNS/readArray?guid=3329813F3E81D966B0567024500FB1B60C96F980&field=geoLocation
  // Retorno: [-22.874631881713867,-43.76070022583008]
  // Exemplo: http://localhost:8080/GNS/readArray?guid=3329813F3E81D966B0567024500FB1B60C96F980&field=nome
  // Retorno: ["Pato Donald"]
  // Exemplo: http://localhost:8080/GNS/readArray?guid=3329813F3E81D966B0567024500FB1B60C96F980&field=+ALL+
  // Retorno: {"bairro":["Leblon"],"telefones":["(21) 8765-4321","(21) 9988-7766"],"geoLocation":[-22.874631881713867,-43.76070022583008],"nome":["Pato Donald"]}
  // Exemplo: Com os campos name ou nr_primary.
  // Retorno: +NO+ +GENERICERROR+
  // Exemplo: Com o campo SERVER_REG_ADDR (que retorna uma lista com IP e Porta do MServerSocket)
  // Retorno: +NO+ +GENERICERROR+
  var params = new Object();
  params.guid = guid;
  params.field = field;

  var url = gns+"readunsigned";
  request(url,params,'get',true,function( data, status, jqXHR ) {
    response( data, status, jqXHR, guid );
  });
/*
  $.get(url , params )
    .done(function( data, status, jqXHR ) {
        response( data, status, jqXHR, guid );
      }
    );
*/
}

/*******************************************************************************
' Nome........: sendTaskRequest
' Objetivo....: Envia tarefa a um dispositivo
' 
' Entrada.....: response, ip, port, id, taskName, content, csIp, csPort
' Observação..:
' Atualizações: [01]   Data: 19/06/2016 10:00   Autor: Peron Rezende
*******************************************************************************/
//TODO function sendTaskRequest(selectResponse, ip, port, id, taskName, content, csIp, csPort)
function sendTaskRequest(response, ip, port, id, taskName, content, csIp, csPort) {
  var params = new Object();
  params.id = id;
  params.taskName = taskName;
  params.content = content;
  params.csIp = csIp;
  params.csPort = csPort;

  $.post( "http://"+ip+":"+port, params )
    .done(function( data, status ) {
      response( data, status );
    }
  );

}


function request(url, params, method, proxy, response) {
  if(proxy){

    var proxyURL = url + "?" + jQuery.param(params,true);
    //proxyURL = decodeURIComponent(proxyURL);
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
        //alert( "error" + xhr.responseText );
        console.log("error: " + status);
        console.log("error: " + JSON.stringify(xhr));
        console.log("error: " + error);
        response( error, status );
      })
      .always(function() {
        //alert( "finished" );
        console.log("finished");
      });
  }else{
    if(method == 'get'){
      $.get(url, params )
        .done(function( data, status ) {
            response( data, status );
          }
        ).fail(function(xhr, status, error) {
          console.log("error: " + status);
          console.log("error: " + error);
          response( error, status );
        });
    }else{
      $.post(url, params )
        .done(function( data, status ) {
            response( data, status );
          }
        ).fail(function(xhr, status, error) {
        console.log("error: " + status);
        console.log("error: " + error);
        response( error, status );
      });
    }
  }

}
