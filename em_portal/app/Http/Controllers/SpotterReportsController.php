<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Report;
use App\Models\AppUser;
use Lang;
class SpotterReportsController extends Controller
{
  public function __construct()
  { 
      flash(Lang::get('flashMessages.loginRequired'), 'danger');
      $this->middleware('auth');
  }
  /**
   * Display a listing of the resource.
   *
   * @return Response
   */
  public function index(Request $request){

    $reportID = $request->input('report');
    $userID = $request->input('user');
    if($reportID){
      // Eager Loading the images and videos associated for one of the reports
      $report = Report::with(array('images', 'videos'))->find($reportID);
      return view('spotterReports.viewReport', compact('report'));
    }
    else if($userID){
      $appUser = AppUser::with('spotterReports')->find($userID);
      $title = Lang::get('spotterReports.userSpotterReportsTitle', ['name' => $appUser->id ]);
      $reports = array();
      if(!is_null($appUser)){
        $ids = $appUser->spotterReports()->pluck('id')->toArray();
        $title = Lang::get('spotterReports.userSpotterReportsTitle', ['name' => $appUser->id ]);
        $reports = Report::with('images','videos')->whereIn('id', $ids)->orderBy('created', 'desc')->get();
      }
      return view('spotterReports.index', compact('reports','title'));
    }
    else{
      // Eager Loading the images and videos associated with each of the reports
      $title = Lang::get('spotterReports.title');
      $reports = Report::with('images','videos')->orderBy('created', 'desc')->get();
      return view('spotterReports.index', compact('reports','title'));  
    }
    
  }

  /**
   * Show the form for creating a new resource.
   *
   * @return Response
   */
  public function create()
  {
      //
  }

  /**
   * Store a newly created resource in storage.
   *
   * @return Response
   */
  public function store()
  {
      //
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
      //
    $report = Report::find($id);
    if(!is_null($report)){
      $deleted = Report::destroy($id);
      // $data = array();
      // $data['success'] = $deleted;
      // $data['data'] = "Report deleted";
      if($deleted)
        $flashMessage = "Report deleted";
      else
        $flashMessage = "There was an error";
    }
    else{
      $flashMessage = "There was an error";
    }
    flash($flashMessage)->important();
    return redirect()->route('spotterReports.index');

  }
}
