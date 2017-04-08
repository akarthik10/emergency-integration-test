<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Image extends Model
{
  
  public $timestamps = false; 
  protected $guarded = [];
  protected $table = 'image';

  public function report(){
      return $this->belongsTo('App\Models\Report', 'reportID');
  }

  public static function saveImage($reportID,$file){
    
    $tmpname = $file['tmp_name'];
    $type = $file['type'];
    $info = pathinfo($file['name']);
    $ext = $info['extension'];
    $created = date('Y-m-d H:i:s');

    // create image in db , created will get updated because it is a timestamp
    $image = Image::firstorCreate(['reportID' => $reportID, 'extension' => $ext, 'created' => $created, 'url' => '']);
    // move image to img folder
    $locn = 'images/reportImg/' .$image->id.".".$ext;
    $target = public_path($locn);
    $fileMoved = move_uploaded_file($tmpname, $target);
    // NEED TO VERIFY & CHECK -DANIEL <APACHE/NGINX>
    $url = $locn;

    Image::fixOrientation($target);

    $image->url = $url;
    $image->save();
    return $image;
  }
  
  private static function fixOrientation($path) {
    $image = imagecreatefromjpeg($path);
    $exif = @exif_read_data($path);

    if (empty($exif['Orientation']))
    {
        return false;
    }

    switch ($exif['Orientation'])
    {
        case 3:
            $image = imagerotate($image, 180, 0);
            break;
        case 6:
            $image = imagerotate($image, - 90, 0);
            break;
        case 8:
            $image = imagerotate($image, 90, 0);
            break;
    }

    imagejpeg($image, $path);

    return true;
  }
}
