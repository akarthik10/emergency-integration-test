<?php

return array(

    'emergencyAppIOS'     => array(
        'environment' =>'production',
        'certificate' =>public_path().'/ck.pem',
        'passPhrase'  =>'UMassEmergency2016',
        'service'     =>'apns'
    ),
    'appNameAndroid' => array(
        'environment' =>'production',
        'apiKey'      =>'yourAPIKey',
        'service'     =>'gcm'
    )

);