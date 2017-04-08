<?php

if(isset($_REQUEST['token'])){
  $deviceTokens = explode(',', $_REQUEST['token']);
}else{
  die("no token given");
}

if(isset($_REQUEST['message'])){
  $message = $_REQUEST['message'];
}else{
  die("no message given");
}

$debug = false;
if(isset($_REQUEST['debug'])){
  $debug = $_REQUEST['debug'];
}

$data;
if(isset($_REQUEST['data'])){
  $data = json_decode($_REQUEST['data']);
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

  ////////////////////////////////////////////////////////////////////////////////
  $ctx = stream_context_create();
  stream_context_set_option($ctx, 'ssl', 'local_cert', 'ck.pem');
  stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
  stream_context_set_option($ctx, 'ssl', 'cafile', 'entrust_2048_ca.cer');
  
  // Open a connection to the APNS server
  $host = 'ssl://gateway.push.apple.com:2195';
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

