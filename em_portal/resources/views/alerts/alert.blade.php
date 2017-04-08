
@extends('layouts.sidebar_layout')

@section('assets')
  <script src="js/moment.js"></script>
  <script src="js/colorVariables.js"></script>
  <script src="js/user.js"></script>
  
  <script src="js/polygon.js"></script>
  <script src="js/circle.js"></script>
  <script src="js/util.js"></script>
  <script src="js/init.js"></script>

  <script src="js/notification.js"></script>
  <script src="js/data.js"></script>
  <script src="js/setup.js"></script>
  <script src="js/auspice.js"></script>
  <script src="js/attribute.js"></script>
  <script src="js/alerts/alertForm.js"></script>

  <link href="/css/Alert.css" rel="stylesheet">
@stop


@section('title', 'Alert')

@section('sidebar')
  <div class="">
    <h3 class="">Create Alert</h3>
        <form id="polygon-notification-form" class="" role="form">
          <div class="m-l-2 form-group">
            <label class="control-label"
                 for="polygon-notification-summary">Title</label>
            <div class="">
              <input type="text" maxlength="60" class="form-control" name="polygon-notification-title" id="polygon-notification-summary" placeholder="Title of notification"  />
            </div>
          </div>

          <div class="form-group">
            <label class="control-label"
                 for="polygon-notification-body">Body</label>
            <div class="">
              <textarea type="text" maxlength="60" class="form-control" name="polygon-notification-body" id="polygon-notification-body" placeholder="" ></textarea>
            </div>
          </div>

          <div class="form-group">
            <label class="control-label"
                 for="polygon-notification-buildings">Buildings</label>
            <div class="">

              <select class="multiple-select" id='buildingSelection' multiple="multiple">
                
              </select>
            </div>
            <script type="text/javascript">
              $("#buildingSelection").select2({
                tags: true,
              });
              $("#buildingSelection").prop("disabled", true);
            </script>

          </div>
          
          <div class="form-group">
            <label class=" control-label" for="polygon-duration">Warning duration (m)</label>
            <div class="">
              <input type="number" class="form-control" name="polygon-notification-duration" id="polygon-duration" value="5" />
            </div>
          </div>

          
        </form>

        <button type="button" class="btn btn-primary" onclick="sendNotificationToUsersInsideNotificationPolygon()">
          Send
        </button>
  </div>
@stop



@section('main_content')
  <div id="map"></div>
  <script type="text/javascript">
    jQuery(document).ready(function(){
      initAlertPortal();
    });
  </script>
      
@endsection