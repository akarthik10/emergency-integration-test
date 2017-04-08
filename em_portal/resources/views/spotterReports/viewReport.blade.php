@extends('layouts.application_layout')

@section('assets')
  <link rel="stylesheet" href="style.css">
  <script src="main.js"></script>
  <script src="assets/dist/lang.dist.js"></script>
  <script src="js/spotterReports/spotterReports.js"></script>
@stop


@section('content')
  <?php
    if(!is_null($report)){
        $title = $report->title;
        $description = $report->description;
        $latLon = $report->lat.", ".$report->lon;
        $images = $report->images;
        $videos = $report->videos;

        ?>

      <div class="row">

        <div class="col-md-12">

          <h2><?php echo $title; ?></h2>
          
        </div>
        
        <div class="col-md-12">
          
          <?php
          
          foreach($videos as $video){
            
            ?>
            <div class="video" class="col-xs-6 col-sm-3"><video width="400" height="400" controls autobuffer><source src="<?php echo $video->url; ?>" type="video/mp4"><video /></div>
            
            <?php
            
          }
            
            
          ?>
          
        </div>
        
        <div class="col-md-12">
          
          <?php
          
          foreach($images as $image){
            
            ?>
            <div class="col-xs-6 col-sm-3"><img class="img-responsive" src="<?php echo $image->url; ?>" /></div>

            
            
            <?php
            
          }
            
            
          ?>
          
        </div>

        <div class="col-md-12">
          <p>
          {{ Form::open(array('url' => 'spotterReports/' . $report->id, 'class' => 'pull-right', 'onsubmit' => 'return ConfirmSpotterReportDelete()')) }}
            {{ Form::hidden('_method', 'DELETE') }}
            {{ Form::submit('Delete Report', array('class' => 'btn btn-warning')) }}
          {{ Form::close() }}
          
          </p>
        </div>
      </div>
        
        <?php

      }
    else{
      // no report given or
      // report is null
      ?>
      
      <h2>Report not found</h2>
      
      <?php

    }
    
    
  ?>
@stop
