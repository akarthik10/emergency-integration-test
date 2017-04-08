<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Alert extends Model
{

  public $timestamps = false;
  protected $table = 'alert';

  public function alertBounds(){
    return $this->hasMany('App\Models\AlertBoundsGeometryCoordinates', 'alertID');
  }
  public function alertUsers(){
    return $this->hasMany('App\Models\AlertUser', 'alertID');
  }

  public static function loadUserAlertsAsArray($username){
    $alertUserRecords = \App\Models\AlertUser::loadAppUserAlerts($username);
    $alerts = array();
    foreach($alertUserRecords as $alertUserRecord){
      $alert = $alertUserRecord->Alert;
      $alerts[] = $alert;
      //$alert->loadCoordinates();
      // TO DO - CHECK THIS , How it is used
      //$alerts[] = $alert;
    }
    return $alerts;
  }
  
  public function getCoordinatesArray(){

    // $setOfBoundariesWithCoordinates = array();
    // foreach($this->alertBounds as $alertBound){
    //   $coordinates = array();
    //   foreach($alertBound->geometryCoordinates as $geometryCoordinate){
    //     $coordinate = array($geometryCoordinate->longitude,$geometryCoordinate->latitude);
    //     $coordinates[] = array($coordinate); // another array, because GeoJSON defines it
    //   }
    //    $setOfBoundariesWithCoordinates[] = ($coordinates);
    // }
    // return $setOfBoundariesWithCoordinates;
  }

  public static function loadAlertasArray($alertID){
    $alert = \App\Models\Alert::with('alertBounds.geometryCoordinates')->find($alertID);
    if(isset($alert)){
      $result = $alert->toArray();
      return $result;
    }
    return array("no Alert found");
  }

  public static function findBoundingLatitudeAndLongitude($boundariesAndCoordinatesJSON){
    $minBoundingLat = 50000;
    $maxBoundingLat = -50000;
    $minBoundingLong = 50000;
    $maxBoundingLong = -50000;
    $BoundariesAndCoordinatesArray = json_decode($boundariesAndCoordinatesJSON);
    for ($row = 0; $row < count($BoundariesAndCoordinatesArray); $row++){
      $boundary = $BoundariesAndCoordinatesArray[$row];
      for ($coordInd = 0; $coordInd < count($boundary); $coordInd++){
        //Latitude is lesser than minBoundlat, update it
        if($boundary[$coordInd][0] < $minBoundingLat){
          $minBoundingLat = $boundary[$coordInd][0];
        }
        elseif($boundary[$coordInd][0] > $maxBoundingLat){
          $maxBoundingLat = $boundary[$coordInd][0];
        }
        //Longitude is lesser than minBoundlong, update it
        if($boundary[$coordInd][1] < $minBoundingLong){
          $minBoundingLong = $boundary[$coordInd][1];
        }
        elseif($boundary[$coordInd][1] > $maxBoundingLong){
          $maxBoundingLong = $boundary[$coordInd][1];
        }
      }
    }
    return array($minBoundingLat,$maxBoundingLat,$minBoundingLong,$maxBoundingLong);
  }

  public static function saveAlert($hazardType,$startTime,$expiryTime,$title,$body,$boundariesAndCoordinates){
    $alert = new \App\Models\Alert;
    $alert->hazardType = $hazardType;
    $alert->startTime = $startTime;
    $alert->expiryTime = $expiryTime;
    $alert->title = $title;
    $alert->body = $body;
    $alert->Polygons = json_encode($boundariesAndCoordinates);
    $bounds = \App\Models\Alert::findBoundingLatitudeAndLongitude($boundariesAndCoordinates);
    $alert->boundingLatitudeMin = $bounds[0];
    $alert->boundingLatitudeMax = $bounds[1];
    $alert->boundingLongitudeMin = $bounds[2];
    $alert->boundingLongitudeMax = $bounds[3];
    $alert->save();
    return $alert;
  }
  
  public function addBoundariesAndCoordinates($BoundariesAndCoordinatesJSON){
    $boundariesID = array();
    // [ [-96.52,32.67] , [-96.52,32.67] , [-96.52,32.67] , [-96.52,32.67] ]
    $BoundariesAndCoordinatesArray = json_decode($BoundariesAndCoordinatesJSON);
    $alert = $this;
    $alertBoundaries = array();
    for($boundaryIndex = 0; $boundaryIndex < count($BoundariesAndCoordinatesArray); $boundaryIndex++) {
      $alertBound = new AlertBoundsGeometryCoordinates([]);
      array_push($alertBoundaries, $alertBound);
    }
    $alert->alertBounds()->saveMany($alertBoundaries);
    foreach($alert->alertBounds as $alertBound){
      array_push($boundariesID, $alertBound->id);
    }
    $geometryCoordinates = array();

    for($boundaryIndex = 0; $boundaryIndex < count($BoundariesAndCoordinatesArray); $boundaryIndex++) {
      $boundaryCoordinateArray = $BoundariesAndCoordinatesArray[$boundaryIndex];
      $alertBound = $alert->alertBounds[$boundaryIndex];
      foreach($boundaryCoordinateArray as $coordinates){
        $latitude = $coordinates[0];
        $longitude = $coordinates[1];
        array_push($geometryCoordinates, ['latitude'=>$latitude, 'longitude' => $longitude, 'alertBoundID' => $boundariesID[$boundaryIndex]]);
      }
    }
    AlertGeometryCoordinates::insert($geometryCoordinates);
    
  }

  public function addUsers($usernamesJSON){
    $alert = $this;
    $usernames = json_decode($usernamesJSON);
    $alertUsersArray = array();
    foreach($usernames as $name){
      array_push($alertUsersArray, new AlertUser(['username'=>$name]));
    }
    $alert->alertUsers()->saveMany($alertUsersArray);
  }

  public function toArray(){
    $json = array();
    $properties = array();
    $properties['alertID'] = "".$this->id;
    $properties['startTime'] = $this->startTime;
    $properties['expiryTime'] = $this->expiryTime;
    $properties['title'] = $this->title;
    $properties['body'] = $this->body;
    $properties['boundingLatitudeMin'] = $this->boundingLatitudeMin;
    $properties['boundingLatitudeMax'] = $this->boundingLatitudeMax;
    $properties['boundingLongitudeMin'] = $this->boundingLongitudeMin;
    $properties['boundingLongitudeMax'] = $this->boundingLongitudeMax;

    // $json['hazardType'] = $this->hazardType;
    $json['id'] = "".$this->id;
    // $json['type'] = "Feature";
    // $json['properties'] = $properties;

    // $json['complexGeometry'] = array("coordinates" => $this->getCoordinatesArray());
    $json['Polygons'] = array("Polygons" => $this->Polygons);
    $json['properties'] = $properties;
    return $json;
  }

}
