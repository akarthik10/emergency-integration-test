<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Route;
use App\Models\Report;
use App\Models\AppUser;
use App\Models\Alert;
use App\Models\Image;
use App\Models\Video;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;
use PushNotification;


class MobileApiController extends Controller
{
    //
  public function sendPushNotifications(Request $request){
    $token = $request->input('token');
    $message = $request->input('message');
    // $data = $request->input('data');

    if(isset($message) && isset($token)){
      $deviceTokens = explode(',', $token);
      // $data = json_decode($data);
    }else{
      // Doesnt have required parameters
      return ;
    }

  // Put your private key's passphrase here:
  $passphrase = 'UMassEmergency2016';

  echo "Message: ".$message. PHP_EOL;
  echo "Sending push notification to:". PHP_EOL;


  print_r($deviceTokens);

  foreach($deviceTokens as $deviceToken){

    $deviceToken = str_replace(' ', '', $deviceToken);
    echo $deviceToken.": ";

    if($deviceToken == ""){
      continue;
    }

    $data;
    if(isset($_REQUEST['data'])){
      $data = json_decode($_REQUEST['data']);
    }

    ////////////////////////////////////////////////////////////////////////////////
    $ctx = stream_context_create();
    stream_context_set_option($ctx, 'ssl', 'local_cert', storage_path().'/CertFiles/iPhone/ck.pem');
    stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
    stream_context_set_option($ctx, 'ssl', 'cafile', storage_path().'/CertFiles/iPhone/entrust_2048_ca.cer');
    
    // Open a connection to the APNS server
    $host = 'ssl://gateway.push.apple.com:2195';
    $debug = false;
    if(isset($_REQUEST['debug'])){
      $debug = $_REQUEST['debug'];
    }

    if($debug){
      $host = 'ssl://gateway.sandbox.push.apple.com:2195';
    }
    $fp = stream_socket_client($host, $err,$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
    
    if (!$fp){
      exit("Failed to connect: $err $errstr" . PHP_EOL);
    }
    
    echo 'Connected to APNS' . PHP_EOL;

    // Create the payload body
    $body['aps'] = array(
      'alert' => $message,
      'sound' => 'default',
    );
    
    if(isset($data)){
      $body['data'] = $data;
      //echo 'Data added '. print_r($body,true) . PHP_EOL;
    }

    echo 'Body: '. json_encode($body) . PHP_EOL;
      
    // Encode the payload as JSON
    $payload = json_encode($body);
    
    // Build the binary notification
    $msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
    
    // Send it to the server
    $result = fwrite($fp, $msg, strlen($msg));
    
    if (!$result)
      echo 'Message not delivered' . PHP_EOL;
    else
      echo 'Message successfully delivered' . '('.$result.')' . PHP_EOL;
    
    // Close the connection to the server
    fclose($fp);
      
    usleep(50);
    }
    // $devices = array();
    // foreach($deviceTokens as $deviceToken){

    //   $deviceToken = str_replace(' ', '', $deviceToken);
    //   echo $deviceToken.": ";

    //   if($deviceToken == ""){
    //     continue;
    //   }
    //   else{
    //     array_push($devices, PushNotification::Device($deviceToken));
    //   }

    // }
    // $pushNotificationdevices = PushNotification::DeviceCollection($devices);
    // $pushNotificationMessage = PushNotification::Message($message,array(
    //   'alert' => $message,
    //   'sound' => 'default'
    // ));

    // $collection = PushNotification::app('emergencyAppIOS')->to($pushNotificationdevices)->send($pushNotificationMessage);

    // // get response for each device push
    // foreach ($collection->pushManager as $push) {
    //     $response = $push->getAdapter()->getResponse();
    // }
  }

  public function backend(Request $request){
    // Log::error($exception . ' - ' . Request::url());
    // Log::warning('[DEBUG] [Input] ' . implode(' / ', Request::all()));
    // if(Route::current())
        Log::warning(json_encode($request->all()));
        Log::warning(json_encode($_FILES));
        Log::warning('[DEBUG] [Route] ' . Route::current()->uri() . ' - ' . implode(' / ', Route::current()->parameters()));


    $method = $request->input('method');
    $alerts = $request->input('alerts');
    $alert = $request->input('alert');
    if(isset($method)){
      switch ($method) {
        case "saveReport":
          $appUser = AppUser::firstOrCreate(['deviceID' => $request->input('deviceID')]);
          $latitude = floatval($_REQUEST['latitude']);
          $longitude = floatval($_REQUEST['longitude']);
          $title = $_REQUEST['title']."";
          $description = $_REQUEST['desc']."";
          $report = Report::firstOrCreate($userID,$latitude,$longitude,$title,$description);
          
          if(!is_null($report)){
            $reportID = $report->id;
            // save images/videos with reportIDs
            foreach($_FILES as $file){
              
              // print_r($file);
              if(strpos($file['type'],'image') !== false){
                $image = Image::saveImage($reportID,$file);
                // print_r($image);
                // echo "<br>";
                
              }elseif(strpos($file['type'],'video') !== false){
                $video = Video::saveVideo($reportID,$file);
              }
              // print_r($report);
              // echo "<br>";
            }
          }
          return ;
          break;
        case "deleteReport":
          // DANIEL - CHECK If ON DELETE CASCADE IS PRESENT , ELSE ADD IN EVENTS
          Report::destroy($request->input('report'));
          return ;
          break;
        case "updateReport":
          ini_set('max_execution_time', 300); //300 seconds = 5 minutes
          ini_set('upload_max_filesize', '10M');
          $sessionID = $request->input('sessionID');
          $reportID = $request->input('reportID');
          $deviceID = $request->input('deviceID');
          
          if(isset($reportID)){
            $report = Report::find($reportID);
          }

          if(!isset($report) && isset($sessionID)){
            $report = Report::where('sessionID', '=', $sessionID)->first();
            
            if(!isset($report)){
              //  echo "report for session does not exist<br>";
              if(!is_null($request->input('deviceID'))){
                // echo "create report, needs user deviceID<br>";
                $user = AppUser::where('deviceID', $deviceID)->first();
                if(is_null($user)){
                  $user = AppUser::create(['deviceID'=> $deviceID, 'created' =>Carbon::now() , 'apnToken' =>'']);
                }
                if(is_null($user)){
                  die("die because no user available");
                }
                $userID = $user->id;
              }

              $report = Report::create(['userID'=>$userID, 'lat'=>0.0, 'lon'=>0.0, "title"=> "", 'description' => "", "sessionID"=> $sessionID, 'created'=>Carbon::now()]);
              $report->sessionID = $sessionID;
            }
          }

          $updated = false;
          if(isset($report)){

            if(isset($_REQUEST['latitude'])){
              $latitude = floatval($_REQUEST['latitude']);
              $report->lat = ($latitude);
            }
            if(isset($_REQUEST['longitude'])){
              $longitude = floatval($_REQUEST['longitude']);
              $report->lon = ($longitude);
            }
            if(isset($_REQUEST['title'])){
              $title = $_REQUEST['title']."";
              $report->title = ($title);
            }
            if(isset($_REQUEST['desc'])){
              $description = $_REQUEST['desc']."";
              $report->description = ($description);
            }
            
            $reportID = $report->id;
            if(isset($reportID)){
              foreach($_FILES as $file){
                if(strpos($file['type'],'image') !== false){
                  $image = Image::saveImage($reportID,$file);
                }elseif(strpos($file['type'],'video') !== false){
                  $video = Video::saveVideo($reportID,$file);
                }
              }
            }
            $updated = $report->save();
            $report->load('images');
            $report->load('videos');
          }

          $data = array();
          $data['success'] = $updated;
          if(isset($report)){
            $data['data'] = $report->toArray();
          }
          return ($data);
          
          break;
      }
    }
    else if(isset($alerts)){
      $username = $request->input('username');
      if( isset($username) ){
        $alerts = Alert::loadUserAlertsAsArray($username);
        return $alerts;
      }
    }
    else if(isset($alert)){
      $alertID = $request->input('alertID');
      if( isset($alertID) ){
        $alert = Alert::loadAlertasArray($alertID);
        return $alert;
      }
    }
  }
}
