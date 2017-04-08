/*******************************************************************************
INFORMA��ES DE IDENTIFICA��O DA VERS�O
Vers�o: 1.0         Data: 27/06/2016 13:00
Objetivo/Manuten��o: Separar vari�veis globais
Autor: Paulo Mann
*******************************************************************************/

  /* variables */
  var notificationColor = "blue";
  var userColor = "blue";
  var polygonColor = "blue";

  var hideMarkersColors = false;
  var hideMarkers = false;
  var editingPolygon = null;
  var markerType = 'notification';

  var file = null;

  var users = [];
  var usersGroup = null;
  var circles = [];
  var circlesGroup = null;
  var notifications = [];
  var notificationsBuildings = {};
  var polygonNotifications = new L.FeatureGroup();

  var notification = null;

  var timerMap = [];

  var attributesList;
  var attributesURL = "http://emergencyportal.herokuapp.com/data/attributes.json";

  /*Markers type */
  var redUser = L.AwesomeMarkers.icon({
    icon: 'user',
    prefix: 'fa',
    markerColor: 'red'
  });
  var blueUser = L.AwesomeMarkers.icon({
    icon: 'user',
    prefix: 'fa',
    markerColor: 'blue'
  });
  var greenUser = L.AwesomeMarkers.icon({
    icon: 'user',
    prefix: 'fa',
    markerColor: 'green'
  });
  var purpleUser = L.AwesomeMarkers.icon({
    icon: 'user',
    prefix: 'fa',
    markerColor: 'purple'
  })
  var whiteUser = L.AwesomeMarkers.icon({
    icon: 'user',
    iconColor: 'black',
    prefix: 'fa',
    markerColor: 'white'
  })
  var lightblueUser = L.AwesomeMarkers.icon({
    icon: 'user',
    prefix: 'fa',
    markerColor: 'lightblue'
  })
  var orangeUser = L.AwesomeMarkers.icon({
    icon: 'user',
    prefix: 'fa',
    markerColor: 'orange'
  })

  
  //These variables must be changed in orther to add more colors
  var colorsIconMap = {'red':redUser, 'blue':blueUser, 'green':greenUser, 'purple':purpleUser, 'white':whiteUser, 'lightblue': lightblueUser, 'orange':orangeUser};
  var mixedToMainColorsMap = {'red':'red', 'blue':'blue', 'green':'green', 'purple':'blue_red', 'white':'blue_red_green', 'lightblue':'blue_green', 'orange': 'green_red'};
  var colors = ['red', 'blue', 'green', 'purple', 'white', 'lightblue', 'orange'];

  // Niteroi
  // var latitude = -22.9029100;
  // var longitude = -43.1105500;
  // UMass
  var latitude = 42.3895100;
  var longitude = -72.5264470;

  // Berlin
  //var latitude = 52.553216;
  //var longitude = 13.376948;

  // APNs com submodulos
  // var apn = require ("../apn/index.js");

  var proxy = true;

  $.fn.serializeAndEncode = function() {
    return $.map(this.serializeArray(), function(val) {
      //return [val.name, encodeURIComponent(val.value)].join('=');
      return [val.name, val.value].join('=');
    }).join('&');
  };
  var drawControlOptions = {
    position: 'bottomright',
    draw: 
    {
      polyline: false,
      marker: false,
      polygon:
      {
        allowIntersection: false,
        showArea: true,
        drawError: 
        {
          color: '#e1e100', // Color the shape will turn when intersects
          message: 'You can\'t draw that!' // Message that will show when intersect
        },
        shapeOptions: 
        {
          color: '#000000'
        }
      },
      circle: false,
      rectangle: false
    }
  }
  var drawControl = new L.Control.Draw(drawControlOptions);


  var polygonsDrawn = {};
