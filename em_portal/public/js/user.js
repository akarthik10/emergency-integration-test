
/*******************************************************************************
' Nome........: insertUserOnMap
' Objetivo....: 
' 
' Entrada.....: color, latlng
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function insertUserOnMap(color, latlng)
{
  var user = null;
  user = L.marker(latlng, {icon: colorsIconMap[color], draggable:'true'}).addTo(map);
  user = setupUserEvents(user,color);
  return user;
}

/*******************************************************************************
' Nome........: setupUserEvents
' Objetivo....: 
' 
' Entrada.....: user, color
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function setupUserEvents(user, color)
{
  if(user != null)
  {
    user.on('dragend', function(event){
      var userMarker = event.target;
      var position = userMarker.getLatLng();
      userMarker.setLatLng(position).update();
      userMarker.circle.setLatLng(position);
      var i = getIndexUser(userMarker);
      var record = getPdataValue(i);  
      var value = record.gnsUserFields;
      notifyIfNotificationsAreNearby(userMarker, value);
      removeNotificationsIfOutOfRadius(userMarker);
      removePolygonNotificationIfOutside(userMarker);
    });
    user.on('drag', function(event){
      var userMarker = event.target;
      var position = userMarker.getLatLng();
      userMarker.circle.setLatLng(position);
    });
    user.on('click', function(event){
      var userMarker = event.target;
      var i = getIndexUser(userMarker);
      var record = getPdataValue(i);
      var gnsUserFields = record.gnsUserFields;
      if(!userMarker.getPopup()) {
        var deviceID = gnsUserFields.deviceID;
        var username = gnsUserFields.username;
        var appID = gnsUserFields.accountID;
        var appVersion = gnsUserFields.appVersion;
        var appBuild = gnsUserFields.appBuild;
        var attributes = gnsUserFields.attributes;
        var popup = L.popup({minWidth:24, maxWidth:500, minHeight:24, maxHeight:500});
        popup.setLatLng(userMarker.getLatLng());
        popup.setContent('<h4>User Record</h4><p>App: '+appID+' '+appVersion+' ('+appBuild+')'+'<br/>DeviceID: '+deviceID+'<br/>Username: '+username+'<br/>Attributes: '+JSON.stringify(attributes)+'</p>');
        userMarker.bindPopup(popup).openPopup();
        popup.on('close', function(e) {
          //e.target.unbindPopup();
          userMarker.unbindPopup();
        });
      }else{
        userMarker.closePopup();
        userMarker.unbindPopup();
      }
    });
    user.messageColor = color;
    user.oldIcon = user.options.icon;
  }
  return user;
}

/*******************************************************************************
' Nome........: getIndexUser
' Objetivo....: 
' 
' Entrada.....: user
' Observação..:
' Atualizações: [01]   Data: 06/07/2016 21:10   Autor: Peron Rezende
*******************************************************************************/

function getIndexUser(user)
{
  var result = -1;
  for(var i = 0; i < users.length; i++)
  {
    if (user == users[i]) 
    {
      result = i;
      break;
    }
  }
  return result;
}

/*******************************************************************************
' Nome........: addPopUp
' Objetivo....: 
' 
' Entrada.....: user, gnsUserFields, notification
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function addPopUp(user, gnsUserFields, notification)
{
  var ui = users.indexOf(user);
  var popup = L.popup({minWidth:10, maxWidth:24, minHeight:10, maxHeight:24});
  popup.setLatLng(user.getLatLng());
  popup.setContent('<a href="#" onclick="openNotificationsModal(this)"><i class="fa fa-bell faa-ring animated" style="font-size:24px;"></i><input type="hidden" name="user" value="' + ui + '"></a>');
  //Care about changing this html code, openNotificationsModal depends on this html

  if(!user.getPopup()) 
  {
    user.bindPopup(popup).openPopup();
  }
  else{
    user.openPopup();
  }
}

  
/*******************************************************************************
' Nome........: matchColors
' Objetivo....: 
' 
' Entrada.....: notificationColor, userColor
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function matchColors(notificationColor, userColor)
{
  var mainUserColors = mixedToMainColorsMap[userColor].split("_");
  var mainNotificationColors = mixedToMainColorsMap[notificationColor].split("_");

  for(var i = 0; i < mainUserColors.length; i++)
  {
    for(var j = 0; j < mainNotificationColors.length; j++)
    {
      if(mainUserColors[i].localeCompare(mainNotificationColors[j]) == 0)
        return true;
    }
  }
  return false;
}


/*******************************************************************************
' Nome........: changeUserState
' Objetivo....: 
' 
' Entrada.....: user (marker), demoState (False = original user state or True = 
'               demo user state)
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function changeUserState(user, demoState)
{
  var blackIcon = L.AwesomeMarkers.icon({
    icon: 'user',
    prefix: 'fa',
    markerColor: 'black'
  });
  if(hideMarkersColors)
  {
    if(demoState)
    {
      user.setIcon(blackIcon);
      user.circle.setStyle(
      {
        color: 'black',
        fillColor: 'black',
        fillOpacity: 0.3
      });
    }
    else
    {
      user.setIcon(user.oldIcon);
      user.circle.setStyle(
      {
        color: user.messageColor,
        fillColor: user.messageColor,
        fillOpacity: 0.3
      });
    }
  }
  else if(hideMarkers)
  {
    if(demoState)
      map.removeLayer(user);
    else
      map.addLayer(user);
  }
}
/*******************************************************************************
' Nome........: getUsersArray
' Objetivo....: 
' 
' Entrada.....: notification
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function getUsersArray(notification)
{
  //This function will return an array of users that match notification's color.

  var notificationColor = notification.messageColor;
  var mainNotificationColors = mixedToMainColorsMap[notificationColor].split("_");
  var usersArray = [];

  for(var i = 0; i < users.length; i++)
  {
    var mainUserColors = mixedToMainColorsMap[users[i].messageColor].split("_");
    var match = false;
    for(var j = 0; j < mainnotificationColors.length; j++)
    {
      for(var k = 0; k < mainUserColors.length; k++)
      {
        if(mainUserColors[k].localeCompare(mainNotificationColors[j]) == 0)
        { 
          usersArray.push(users[i]);
          match = true;
        }
      }
      if(match) break;
    }
  }
  return usersArray;
}

/*******************************************************************************
' Nome........: removePopUp
' Objetivo....: 
' 
' Entrada.....: user
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function removePopUp(user)
{
  user.closePopup();
  user.unbindPopup();
}

/*******************************************************************************
' Nome........: resetUser
' Objetivo....: 
' 
' Entrada.....: user
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function resetUser(user)
{
  removePopUp(user);
  changeUserState(user, true);
  map.removeLayer(user.circle);
}