<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AlertUser extends Model
{
    //username, alertID
  protected $table = 'alert_user';
  //https://laravel.com/docs/5.3/eloquent#mass-assignment
  protected $guarded = [];

  public $timestamps = false;
  
  public function Alert(){
    return $this->belongsTo('App\Models\Alert', 'alertID');
  }

  public static function loadAppUserAlerts($username){
    return \App\Models\AlertUser::with('Alert')->where('username', '=', $username)->get();
  }
  
}
