<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Report;
use App\Models\AppUser;
use App\Models\Alert;
use DB;
use Lang;
class AlertsController extends Controller
{
  public function __construct()
  {
      flash(Lang::get('flashMessages.loginRequired'), 'warning');
      $this->middleware('auth');
  }
  /**
   * Display a listing of the resource.
   *
   * @return Response
   */
  /**
   * Display a listing of the resource.
   *
   * @return Response
   */
  public function index(Request $request){
    
  }

  /**
   * Show the form for creating a new resource.
   *
   * @return Response
   */
  public function create()
  {
      //
    return view('alerts/alert');
  }

  /**
   * Store a newly created resource in storage.
   *
   * @return Response
   */
  public function store(Request $request)
  {
      //
    
    if( ($request->input('boundariesAndCoordinates')) && ($request->input('hazardType')) && ($request->input('headline')) ){
      // TO-DO add Transaction
      // DB::transaction(function() use ($request) {
        $alert = Alert::saveAlert($request->input('hazardType'), $request->input('effective'), $request->input('expires'), $request->input('headline'), $request->input('longDescription'), $request->input('boundariesAndCoordinates'));  
        // https://laravel.com/docs/5.3/eloquent-relationships#inserting-and-updating-related-models
        // $alert->addBoundariesAndCoordinates($request->input('boundariesAndCoordinates'));
        $alert->addUsers($request->input('users'));
        return ($alert->toArray());
      // });
    }
  }

  /**
   * Display the specified resource.
   *
   * @param  int  $id
   * @return Response
   */
  public function show($id)
  {
      //
  }

  /**
   * Show the form for editing the specified resource.
   *
   * @param  int  $id
   * @return Response
   */
  public function edit($id)
  {
      //
  }

  /**
   * Update the specified resource in storage.
   *
   * @param  int  $id
   * @return Response
   */
  public function update($id)
  {
      //
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param  int  $id
   * @return Response
   */
  public function destroy($id)
  {
  }
}
