<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
  // Table Name in the database
  protected $table = 'report';

  public $timestamps = false;
  
  // Mass assignable attributes : https://laravel.com/docs/5.3/eloquent#mass-assignment
  protected $guarded = [
  ];

  public function images() {
      return $this->hasMany('App\Models\Image', 'reportID');
  }  

  public function videos() {
      return $this->hasMany('App\Models\Video', 'reportID');
  }  

  public function getCreatedPrettyString(){
    if(!is_null($this->created)){
      return date('l, F jS Y h:i A',strtotime($this->created));
    }
    return $this->created;
  }
  
}
