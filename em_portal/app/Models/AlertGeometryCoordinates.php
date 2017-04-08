<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AlertGeometryCoordinates extends Model
{
    //id, latitude, longitude, alertBoundID
  protected $table = 'alert_geometry_coordinates';
  
  public $timestamps = false;
  //https://laravel.com/docs/5.3/eloquent#mass-assignment
  protected $guarded = [];

}
