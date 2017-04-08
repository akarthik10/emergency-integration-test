<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AlertBoundsGeometryCoordinates extends Model
{
    //id, alertID
  protected $table = 'alert_bounds_geometry_coordinates';
  
  public $timestamps = false;
  //https://laravel.com/docs/5.3/eloquent#mass-assignment
  protected $guarded = [];

  public function geometryCoordinates(){
    return $this->hasMany('App\Models\AlertGeometryCoordinates', 'alertBoundID');
  }

}
