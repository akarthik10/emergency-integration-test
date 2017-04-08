/*******************************************************************************
INFORMAÇÕES DE IDENTIFICAÇÃO DA VERSÃO
Versão: 1.0                    Data: 27/06/2016 13:10
Objetivo/Manutenção: 
Autor: Paulo Mann
*******************************************************************************/

/*******************************************************************************
' Nome........: drawPolygon
' Objetivo....: 
' 
' Entrada.....: polygon
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Görkem Güclü
*******************************************************************************/
function createPolygon()
{
  drawControl.setDrawingOptions(
    {
      polygon:
      {
        shapeOptions: 
        {
          color: polygonColor
        }
      }
    });
}



/*******************************************************************************
' Nome........: setupPolygonEvents
' Objetivo....: 
' 
' Entrada.....: polygon
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function setupPolygonEvents(polygon)
{
  polygon.on('mouseover', function(e)
  {
    e.target.setStyle({opacity:0.6, fillOpacity:0.5});
    //info.update(e.target);
  });
  polygon.on('mouseout', function(e)
  {
    e.target.setStyle({opacity:0.5, fillOpacity:0.2});
    //info.update();
  });
}

/*******************************************************************************
' Nome........: onDragEndPolygon
' Objetivo....: 
' 
' Entrada.....: e
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function onDragEndPolygon(e)
{

}

/*******************************************************************************
' Nome........: onRightClickPolygon
' Objetivo....: 
' 
' Entrada.....: e
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function onRightClickPolygon(e)
{
  var polygon = e.target;
  $("#polygon-notification-modal").modal();
  editingPolygon = polygon;
}

/*******************************************************************************
' Nome........: broadcastPolygonChanges
' Objetivo....: 
' 
' Entrada.....: polygon
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function broadcastPolygonChanges(polygon)
{
  var receivers = polygon.receivers;
  var receiversToRemove = [];   
  for(var i = 0; i < receivers.length; i++)
  {
    if(!matchColors(polygon.messageColor, receivers[i].messageColor))
    {
      receiversToRemove.push(receivers[i]);
    }
  }
  for(var i = 0; i < receiversToRemove.length; i++)
  {
    receiversToRemove[i].polygonNotifications.splice(receiversToRemove[i].polygonNotifications.indexOf(polygon), 1);
    polygon.receivers.splice(polygon.receivers.indexOf(receiversToRemove[i]), 1);
    if(!hasNotification(receiversToRemove[i]))
      resetUser(receiversToRemove[i]);  
  }
}

/*******************************************************************************
' Nome........: getPolygonVertices
' Objetivo....: 
' 
' Entrada.....: polygonMarkers
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function getPolygonVertices(polygonMarkers)
{
  var vertices = [];
  for(var i = 0; i < polygonMarkers.length; i++)
  {
    var latlng = polygonMarkers[i].getLatLng();
    vertices.push([Number(latlng.lat), Number(latlng.lng)]);
  }
  return vertices;
}

/*******************************************************************************
' Nome........: getPolygonVerticesFromLatLngs
' Objetivo....: 
' 
' Entrada.....: polygonLatLngs
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function getPolygonVerticesFromLatLngs(multipolygonLatLngs)
{
  var polygonLatLngs = multipolygonLatLngs[0];
  var vertices = [];
  for(var i = 0; i < polygonLatLngs.length; i++)
  {
    var latlng = polygonLatLngs[i];
    vertices.push([Number(latlng.lat), Number(latlng.lng)]);
  }
  return vertices;  
}

/*******************************************************************************
' Nome........: checkUserInsidePolygon
' Objetivo....: 
' 
' Entrada.....: user, vertices
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Wm. Randolph Franklin
*******************************************************************************/

function checkUserInsidePolygon(user, vertices)
{
  //Ray casting algorithm to verify if a point is inside a polygon
  var i, j, c = 0;
  var x = Number(user.getLatLng().lat);
  var y = Number(user.getLatLng().lng)
  var inside = false;
  for(i = 0, j = vertices.length - 1; i < vertices.length; j = i++)
  {
    var xi = vertices[i][0], yi = vertices[i][1];
    var xj = vertices[j][0], yj = vertices[j][1];

    var intersect = ((yi>y) != (yj>y) && (x < (xj - xi)*(y - yi)/(yj - yi) + xi))
    if(intersect) inside = !inside;
  }

  return inside;
}

/*******************************************************************************
' Nome........: removePolygon
' Objetivo....: 
' 
' Entrada.....: polygon
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function removePolygon(polygon)
{
  var receivers = polygon.receivers.slice();
  for(var i = 0; i < receivers.length; i++)
  {
    polygon.receivers.splice(polygon.receivers.indexOf(receivers[i]), 1);
    receivers[i].polygonNotifications.splice(receivers[i].polygonNotifications.indexOf(polygon), 1);
    if(!hasNotification(receivers[i]))
      resetUser(receivers[i]);
  }
  if(polygonNotifications.hasLayer(polygon))
    polygonNotifications.removeLayer(polygon);
}

/*******************************************************************************
' Nome........: addPolygonsEditOptionEvent
' Objetivo....: 
' 
' Entrada.....: 
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function addPolygonsEditOptionEvent()
{
  polygonNotifications.eachLayer(function (layer)
  {
    layer.on('contextmenu', onRightClickPolygon);
  });
}

/*******************************************************************************
' Nome........: removePolygonsEditOptionEvent
' Objetivo....: 
' 
' Entrada.....: 
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function removePolygonsEditOptionEvent()
{
  polygonNotifications.eachLayer(function (layer)
  {
    layer.off('contextmenu', onRightClickPolygon);
  });
}

/*******************************************************************************
' Nome........: removePolygonsDragOptionEvent
' Objetivo....: 
' 
' Entrada.....: 
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function removePolygonsDragOptionEvent()
{
  polygonNotifications.eachLayer(function (layer)
  {
    layer.options.draggable = false;
  });
}

/*******************************************************************************
' Nome........: addPolygonsDragOptionEvent
' Objetivo....: 
' 
' Entrada.....: 
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/


function addPolygonsDragOptionEvent()
{
  polygonNotifications.eachLayer(function (layer)
  {
    layer.on('dragend', onDragEndPolygon);
  });
}

/*******************************************************************************
' Nome........: removeLines
' Objetivo....: 
' 
' Entrada.....: 
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function removeLines()
{
  for(var i = 0; i < polygonLines.length; i++)
  {
    map.removeLayer(polygonLines[i]);
  }
  polygonLines = [];
}

/*******************************************************************************
' Name........: removeSelectedPolygon
' Objective....: 
' 
' Author: Daniel Sam Pete Thiyagu
*******************************************************************************/

function removeSelectedPolygon(polygonLayer, map)
{
  map.removeLayer(polygonLayer);
}

