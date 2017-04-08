<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/


Route::post('backend', 'MobileApiController@backend');

Route::group(['middleware' => 'web'], function(){
  Route::get('/', 'AlertsController@create');

// Route::get('spotter_reports', 'SpotterReportsController@index');
  Route::resource('spotterReports', 'SpotterReportsController');

// Route::get('spotter_reports', 'SpotterReportsController@index');
  Route::resource('Alerts', 'AlertsController');

  Route::post('sendPushNotifications', 'MobileApiController@sendPushNotifications');
  Auth::routes();

});