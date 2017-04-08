<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Video extends Model
{
    //
  protected $table = 'video';
  
  public $timestamps = false;
  protected $guarded = [];

  public function report(){
    return $this->belongsTo('App\Models\Report', 'reportID');
  }

  public static function saveVideo($reportID,$file){
        
    $tmpname = $file['tmp_name'];
    $type = $file['type'];
    $info = pathinfo($file['name']);
    $ext = $info['extension'];
    // create image in db to get imageID
    $created = date('Y-m-d H:i:s');

    // create image in db , created will get updated because it is a timestamp
    $video = Video::firstorCreate(['reportID' => $reportID, 'extension' => $ext, 'created' => $created, 'url' => '', 'width' => 100, 'height' => 100]);
    // move image to img folder
    $locn = 'videos/reportVid/' .$video->id.".".$ext;
    $target = public_path($locn);
    $fileMoved = move_uploaded_file($tmpname, $target);
    // NEED TO VERIFY & CHECK -DANIEL <APACHE/NGINX>
    $url = $locn;
    $video->url = $url;
    $video->save();   

    // $video = \App\Models\Video::create(['extension' => $ext, 'reportID' => $reportID, 'created' => $created, 'url' => '', 'width' => 100, 'height' => 100]);
    // if($video){
    //   echo "videoID: ".$video->id."<br>";
    //   // move video to videos folder
    //   $target = 'videos/reportVid/'.$video->id.".".$ext;
    //   move_uploaded_file($tmpname, $target);

         
    
    // }      
    return $video;
    
  }
}
