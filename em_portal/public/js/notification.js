/*******************************************************************************
INFORMAÇÕES DE IDENTIFICAÇÃO DA VERSÃO
Versão: 1.0                    Data: 27/06/2016 13:10
Objetivo/Manutenção: 
Autor: Paulo Mann
*******************************************************************************/

/*******************************************************************************
' Nome........: setupNotificationRadius
' Objetivo....: 
' 
' Entrada.....: user, color, radius
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function setupNotificationRadius(user, color, radius)
{
  var circle = createCircle(radius, color, user);
  updateVariables(user, circle);
}

/*******************************************************************************
' Nome........: updateVariables
' Objetivo....: 
' 
' Entrada.....: user, circle
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function updateVariables(user, circle)
{
  user.circle = circle;
  user.notifications = [];
  user.polygonNotifications = []
  user.lines = [];
  users.push(user);
  usersGroup.addLayer(user);
  circlesGroup.addLayer(circle);
  circles.push(circle);

  setupNotificationRadiusEvents(user, circle);
}

/*******************************************************************************
' Nome........: setupNotificationRadiusEvents
' Objetivo....: 
' 
' Entrada.....: user, circle
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function setupNotificationRadiusEvents(user, circle)
{
  user.on('click', function(e)
  {
    var currentCircle = e.target.circle;
    if(currentCircle != null)
    {
      if(map.hasLayer(currentCircle))
        map.removeLayer(currentCircle);
      else
        currentCircle.addTo(map)
    }
  });
  circle.on('click', function(e)
  {
    if(e.target != null)
      map.removeLayer(e.target);
  });
}

/*******************************************************************************
' Nome........: removeNotificationsIfOutOfRadius
' Objetivo....: 
' 
' Entrada.....: user
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function removeNotificationsIfOutOfRadius(user)
{
  var notificationsToRemove = [];
  for(var i = 0; i < user.notifications.length; i++)
  {
    var notificationLatLng = user.notifications[i].getLatLng();
    var userLatLng = user.getLatLng();
    var radius = user.circle.getRadius();
    if(notificationLatLng.distanceTo(userLatLng) > radius)
      notificationsToRemove.push(user.notifications[i]);
  }
  for(var i = 0; i < notificationsToRemove.length; i++)
  {
    var removedNotification = user.notifications[user.notifications.indexOf(notificationsToRemove[i])];
    //removeEdge(removedNotification, user);
    user.notifications.splice(user.notifications.indexOf(notificationsToRemove[i]), 1);
    notificationsToRemove[i].receivers.splice(notificationsToRemove[i].receivers.indexOf(user), 1);
  }
  if(!hasNotification(user) && notificationsToRemove.length >= 1)
    resetUser(user);
}

/*******************************************************************************
' Nome........: createNotification
' Objetivo....: 
' 
' Entrada.....: notification
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function createNotification(notification)
{
  setupNotification(notification);
  notifyUsersNearby(notification);

  var time = $("#time").val();

  notification.on('dragend', function(event)
  {
      var notificationMarker = event.target;
      var position = notificationMarker.getLatLng();
      notificationMarker.setLatLng(position).update();
      notifyUsersNearby(notificationMarker);
      removeUsersIfOutOfRadius(notificationMarker);
  });
  
}

/*******************************************************************************
' Nome........: setupNotification
' Objetivo....: 
' 
' Entrada.....: notification
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function setupNotification(notification)
{
  $("#notification-modal").modal('hide');
  var summary = $("#point-notification-summary").val();
  var time = $("#time").val();
  var details = $("#point-notification-details").val();;
  notification.messageColor = notificationColor;
  notification.summary = summary;
  notification.time = time;
  notification.details = details;
  notification.receivers = [];
  notification.lines = [];
  notification.bindPopup("<b>" + "Summary : "  + "</b>" + summary + "<br>" + "<b>" + "Details : " + "</b>" + details + "<br>" + "<b>"  + "Notification time : " + "</b>" + "<label id='notification-time'>" + time + "s" +"</label>").addTo(map); //+ "<br><b>" + "Time left : " + "</b>" + "<label id='time-left'>" + time  +"</label>").addTo(map);
  notifications.push(notification);
}

/*******************************************************************************
' Nome........: notifyUsersNearby
' Objetivo....: 
' 
' Entrada.....: notification
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function notifyUsersNearby(notification)
{
  var notificationType = notification.messageColor;
  var users = getUsersArray(notification);
  for(var i = 0; i < users.length; i++)
  {
    var radius = users[i].circle.getRadius();
    var userLatLng = users[i].getLatLng();
    if(notification.getLatLng().distanceTo(userLatLng) <= radius)
    {
      if(notification.receivers.indexOf(users[i]) < 0)
      {
        notification.receivers.push(users[i]);
        users[i].oldPopup = users[i].getPopup();
        //users[i].bindPopup("Received the message!").openPopup();
        var record = getPdataValue(i);  
        var gnsUserFields = record.gnsUserFields;
        addPopUp(users[i], gnsUserFields, notification);
        changeUserState(users[i], false);
        //connectLine(notification, users[i]);
        users[i].notifications.push(notification);
      }
    }
  }
}

/*******************************************************************************
' Nome........: notifyIfNotificationsAreNearby
' Objetivo....: 
' 
' Entrada.....: user, gnsUserFields
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function notifyIfNotificationsAreNearby(user, gnsUserFields)
{
  var notified = false;
  for(var i = 0; i < notifications.length; i++)
  {
    var radius = user.circle.getRadius();
    var userLatLng = user.getLatLng();
    var notificationLatLng = notifications[i].getLatLng();
    var notificationType = notifications[i].messageColor;
    var userColor = user.messageColor;
    if(notificationLatLng.distanceTo(userLatLng) <= radius && matchColors(notifications[i].messageColor, user.messageColor))
    {
      if(user.notifications.indexOf(notifications[i]) < 0)
      {
        user.oldPopup = user.getPopup();
        notifyUser(user, gnsUserFields, notifications[i]);
        user.notifications.push(notifications[i]);
        //connectLine(notifications[i], user);
        notifications[i].receivers.push(user);
        notified = true;
      }
    }
  }
  polyNotifications = polygonNotifications.getLayers();
  for(var i = 0; i < polyNotifications.length; i++)
  {
    var vertices = getPolygonVerticesFromLatLngs(polyNotifications[i].getLatLngs());
    if(checkUserInsidePolygon(user, vertices) && matchColors(polyNotifications[i].messageColor, user.messageColor))
    {
      if(user.polygonNotifications.indexOf(polyNotifications[i]) < 0)
      {
        user.polygonNotifications.push(polyNotifications[i]);
        polyNotifications[i].receivers.push(user);
        notifyUser(user, gnsUserFields, polyNotifications[i]);
        notified = true;
      }
    }
  }
  return notified;
}

/*******************************************************************************
' Nome........: removeNotifications
' Objetivo....: 
' 
' Entrada.....: 
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function removeNotifications()
{
  for(var i = 0; i < notifications.length; i++)
  {
    for(var j = 0; j < notifications[i].receivers.length; j++)
    {
      //notifications[i].receivers[j].unbindPopup();
      removePopUp(notifications[i].receivers[j]);
      for(var k = 0; k < notifications[i].receivers[j].lines.length; k++)
      {
        map.removeLayer(notifications[i].receivers[j].lines[k]);
      }
      notifications[i].receivers[j].lines = [];
      changeUserState(notifications[i].receivers[j], true);
    }
    map.removeLayer(notifications[i]);
  }
  notifications = [];

  for(var i = 0; i < users.length; i++)
  {
    users[i].notifications = [];
  }
}

/*******************************************************************************
' Nome........: changeNotificationColor
' Objetivo....: 
' 
' Entrada.....: 
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/


function changeNotificationColor()
{
  $("#notification-modal").modal('hide');
  var notificationMarker = L.AwesomeMarkers.icon(
  {
    icon: 'bell',
    iconColor: 'black',
    prefix: 'fa',
    markerColor: notificationColor
  });
  drawControl.setDrawingOptions(
  {
    marker:
    {
      icon: notificationMarker
    }
  });
}

/*******************************************************************************
' Nome........: openNotificationsModal
' Objetivo....: 
' 
' Entrada.....: DOMPopup
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function openNotificationsModal(DOMPopup)
{
  var html = $(DOMPopup).html();
  var jqueryObj = $('<a></a>').html( html ).children();
  var index = jqueryObj.filter('input').val();
  var user = users[index];

  var modalDOM = "<ol>";
  for(i in user.notifications)
  {
    modalDOM += "<li>" + user.notifications[i].summary.replace(/\"/g,"") + "</li>";
    var userFile = user.notifications[i].file;
    if(user.notifications[i].file)
    {
      if(userFile.tagName.localeCompare("IMG") == 0)
      {
        modalDOM += "<img src='" + userFile.src + "' style='width:100%;'/>";
      }
      else
      {
        modalDOM += "<video style='width:100%;' controls autoplay> <source src='" + userFile.src + "'" + "'> Your browser does not support HTML5 video. </video>";
      }
    }
  }
  for(i in user.polygonNotifications)
  {
    modalDOM += "<li>" + user.polygonNotifications[i].summary.replace(/\"/g,"") + "</li>";
    var userFile = user.polygonNotifications[i].file;
    if(userFile)
    {
      if(userFile.tagName.localeCompare("IMG") == 0)
      {
        modalDOM += "<img src='" + userFile.src + "' style='width:100%;'/>";
      }
      else
      {
        modalDOM += "<video style='width:100%;' controls autoplay> <source src='" + userFile.src + "'" + "'> Your browser does not support HTML5 video. </video>";
      }
    }
  }
  modalDOM += "</ol>"
  var modalBody = $('#show-notifications-modal').children().find(".modal-body");
  $(modalBody).empty();
  $(modalBody).append(modalDOM);
  $("#show-notifications-modal").modal();
}

/*******************************************************************************
' Nome........: createNotificationPolygon
' Objetivo....: 
' 
' Entrada.....: 
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function createNotificationPolygon(polygon)
{
  editingPolygon = polygon;
  // DANIEL - COMMENTING OUT BELOW
  // $("#polygon-notification-modal").modal({backdrop: 'static'});
}

/*******************************************************************************
' Nome........: setupNotificationTimeOutEvent
' Objetivo....: 
' 
' Entrada.....: notification
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function setupNotificationTimeOutEvent(notification)
{
  // var time = notification.time;
  // var timeId = setTimeout(function () 
  // {
  //   var notification = timerMap[timeId];
  //   for(var i = 0; i < notification.receivers.length; i++)
  //   {
  //     //removeEdge(notification, notification.receivers[i]);
  //     if(notification.receivers[i].notifications.length <= 1 && notification.receivers[i].polygonNotifications.length <= 0)
  //     {
  //       //notification.receivers[i].unbindPopup();
  //       resetUser(notification.receivers[i])
  //       notification.receivers[i].notifications = [];
  //     }
  //     else if(notification.receivers[i].notifications.length <= 0 && notification.receivers[i].polygonNotifications.length <= 1)
  //     {
  //       resetUser(notification.receivers[i])
  //       notification.receivers[i].polygonNotifications = [];
  //     }
  //     else
  //     {
  //       var index = notification.receivers[i].notifications.indexOf(notification);
  //       if(index > -1)
  //         notification.receivers[i].notifications.splice(index, 1);
  //     }
  //   }
  //   if(polygonNotifications.hasLayer(notification))
  //     polygonNotifications.removeLayer(notification);

  //   var index = notifications.indexOf(notification);
  //   if(index > -1)
  //     notifications.splice(index, 1);
  //   map.removeLayer(notification);
  // }, time*1000);

  // timerMap[timeId] = notification;
}

String.prototype.beginsWith = function (string) {
  return(this.indexOf(string) === 0);
};

function getBoundaries(polygons){
  var setOfBoundaries = [];
  var polygonKeys = Object.keys(polygons)
  if(polygonKeys.length != 0){
    // Store Vertices of Polygons
    for(var polygonsIndex=0; polygonsIndex<polygonKeys.length; polygonsIndex++){
      var vertices = getPolygonVerticesFromLatLngs(polygons[polygonKeys[polygonsIndex]].getLatLngs());
      setOfBoundaries.push(vertices);
    }
  }
  return setOfBoundaries;
}

function sendNotificationToUsersInsideNotificationPolygon()
{
  usersInsidePolygon = [];
  var eligibleUsers = [];
  //TO DO DANIEL- ADD COMMENT
  var polygon = {};
  
  
  var formArray = {};
  var formString = $("#polygon-notification-form").serializeAndEncode();
  var formStringSplit = formString.split('&');
  $.each(formStringSplit,function(index, value){
    var keyValuePair = value.split('=');
    formArray[''+keyValuePair[0]] = keyValuePair[1];
  });
  var title = formArray['polygon-notification-title'];
  var description = formArray['polygon-notification-title'];
  // var time = formArray['polygon-notification-time'];
  var duration = formArray['polygon-notification-duration'];

  // age attribute-age-minimum attribute-age-maximum
  var minAge = formArray['attribute-age-minimum'];
  var maxAge = formArray['attribute-age-maximum'];
  if(minAge == ""){
    minAge = 0;
  }
  if(maxAge == ""){
    maxAge = 100;
  }
  delete formArray['attribute-age-minimum'];
  delete formArray['attribute-age-maximum'];
  delete formArray['polygon-notification-title'];
  delete formArray['polygon-notification-duration'];
  // delete formArray['polygon-notification-time'];
  delete formArray['polygon-notification-body'];

  console.log(JSON.stringify(formArray));

  var tokens = [];
  var usernames = [];
  var setOfBoundaries = jQuery.merge( getBoundaries(polygonsDrawn), getBoundaries(notificationsBuildings) );
  if(setOfBoundaries.length ==0){
    return ;
  }
  // var polygon = editingPolygon;
  var boundariesAndCoordinates = [];
  // var setOfBoundaries = getBoundaries(polygonsDrawn);
  for(var boundaryIndex=0; boundaryIndex < setOfBoundaries.length; boundaryIndex++){
    vertices = setOfBoundaries[boundaryIndex];
    boundariesAndCoordinates.push(vertices);
    for(var i = 0; i < users.length; i++)
    {
      if(checkUserInsidePolygon(users[i], vertices) && users[i].polygonNotifications.indexOf(polygon) < 0)
      {
        var user = users[i];
        var record = getPdataValue(i);
        var gnsUserFields = record.gnsUserFields;
        var attributes = gnsUserFields.attributes;
        var userEligible = true;

        if(!attributes){
          continue;
        }
        var age = attributes.age;
        if(age < minAge && maxAge < age){
          // age not in range
          continue;
        }

        $.each(formArray, function(index, value) {
          if(!(index in attributes)){
            // attribute not in there, so the user will not receive push notification
            userEligible = false;
            return false; // aka break
          }
        });

        if(userEligible){
          // user.polygonNotifications.push(polygon);
          // polygon.receivers.push(user);
          // eligibleUsers.push(user);
          if(gnsUserFields.deviceID !==  undefined){
            if(tokens.indexOf(gnsUserFields.deviceID) < 0){
              tokens.push(gnsUserFields.deviceID);
            }
          }
          if(gnsUserFields.username){
            if(usernames.indexOf(gnsUserFields.username) < 0){
              usernames.push(gnsUserFields.username);
            }
          }
          addPopUp(users[i], gnsUserFields, polygonNotifications);
          changeUserState(users[i], false);
        }
      }
    }
  }
  sendPushNotification(title,tokens);

  storeAlerts(title,description,duration,boundariesAndCoordinates,usernames, function (data, status) {
    // sendPushNotification(title,tokens,data,false,function (data, status) {
      //alert("success");
    // });
  });

}

/*******************************************************************************
' Nome........: removePolygonNotificationIfOutside
' Objetivo....: 
' 
' Entrada.....: user
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function removePolygonNotificationIfOutside(user)
{
  pNotifications = user.polygonNotifications;
  var notificationsToRemove = [];
  for(var i = 0; i < pNotifications.length; i++)
  {
    if(!checkUserInsidePolygon(user, getPolygonVerticesFromLatLngs(pNotifications[i].getLatLngs())))
    {
      notificationsToRemove.push(pNotifications[i]);
    }
  }
  for(var i = 0; i < notificationsToRemove.length; i++)
  {
    notificationsToRemove[i].receivers.splice(notificationsToRemove[i].receivers.indexOf(user), 1);
    user.polygonNotifications.splice(user.polygonNotifications.indexOf(notificationsToRemove[i]), 1);
  }
  if(!hasNotification(user) && notificationsToRemove.length >= 1)
    resetUser(user);
}

/*******************************************************************************
' Nome........: hasNotification
' Objetivo....: 
' 
' Entrada.....: user
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function hasNotification(user)
{
  return user.notifications.length > 0 || user.polygonNotifications.length > 0;
}

/*******************************************************************************
' Nome........: notifyUser
' Objetivo....: 
' 
' Entrada.....: user, gnsUserFields, notification
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function notifyUser(user, gnsUserFields, notification)
{
  addPopUp(user, gnsUserFields, notification);
  changeUserState(user, false);
}

function sendPushNotification(message, userTokens, debug=false)
{
  // send push notification
  var params = new Object();
  params.message = message;
  params.token = userTokens.toString();
  // params.data = createPayload(payload);
  if(debug){
    params.debug = debug;
  }

  $.post("/sendPushNotifications", params )
    .done(function( data, status ) {
      //alert(status);
      // response(data,status);
    }
  );
}

function createPayload(payload){
  var params = new Object();
  if("hazardType" in payload){
    params.hazardType = payload['hazardType'];
  }
  if("geometry" in payload){
    params.geometry = payload['geometry'];
  }
  if("complexGeometry" in payload){
    params.complexGeometry = payload['complexGeometry'];
  }
  if("id" in payload){
    params.id = payload['id'];
  }
  if("type" in payload){
    params.type = payload['type'];
  }
  return JSON.stringify(params);
}

function storeAlerts(message, description, duration, boundariesAndCoordinates, usernames, response)
{
  //var date = new Date();
  //date.setUTCHours(date.getUTCHours() - 6);
  //var effective = date.toISOString();
  var m = moment().utcOffset(-6);
  var effective = m.format();

  //date.setMinutes(date.getMinutes() + 5);
  //var expires = date.toISOString();
  var later = m.add(duration,'minutes');
  var expires = later.format();

  // store alert in database
  var params = new Object();
  params.method = "saveAlert";
  params.hazardType = "warning";
  params.effective = effective;
  params.validAt = effective;
  params.expires = expires;
  params.headline = message;
  params.longDescription = description;
  params.summary = description;
  params.boundariesAndCoordinates = JSON.stringify(boundariesAndCoordinates);
  params.users = JSON.stringify(usernames);
  params._token = jQuery('meta[name=csrf-token]').attr('content')

  $.post("/Alerts", params )
    .done(function( data, status ) {
        //alert(status);
      response(data,status);
      }
    );
}

function isoDate(date){
  return date.getUTCFullYear() + '-' + (date.getUTCMonth() + 1) + '-' + date.getUTCDate() + 'T'
    + date.getUTCHours() + ':' + date.getUTCMinutes() + ':' + date.getUTCSeconds() + "-" + date.getUTCHours();
}

