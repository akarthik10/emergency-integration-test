@extends('layouts.application_layout')

@section('content')
  <div class="">
    <div class="row">
      <div class="col-md-3">
          @yield('sidebar')
      </div>
      <div class="col-md-9">
          @yield('main_content')
      </div><!-- /.col-lg-12 -->
    </div><!-- /.row -->
  </div><!-- /#page-wrapper -->
@stop

