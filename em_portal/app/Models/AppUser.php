<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AppUser extends Model
{
    //
  protected $table = 'user';
  
  public $timestamps = false;

  protected $guarded = [];
  
  public function spotterReports(){
    return $this->hasMany('App\Models\Report', 'userID');
  }

  public function images(){
    return $this->hasManyThrough(
        'App\Models\Image', 'App\Models\Report',
        'userID', 'reportID', 'id'
    );
  }
}
