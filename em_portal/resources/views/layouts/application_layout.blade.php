<!DOCTYPE html>
<html lang="en">
  <head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <!-- Tell the browser to be responsive to screen width -->
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
  <meta name="csrf-token" content="{!! Session::token() !!}">
  <!-- Bootstrap 3.3.7 -->
  <link rel="stylesheet" href="/vendor/bootstrap/css/bootstrap.min.css">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css">
  <!-- Ionicons -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/ionicons/2.0.1/css/ionicons.min.css">
  <!-- jvectormap -->
  <link rel="stylesheet" href="/vendor/admintheme/plugins/jvectormap/jquery-jvectormap-1.2.2.css">
  <!-- select2 -->
  <link rel="stylesheet" href="/vendor/select2/css/select2.min.css" />
  <!-- Theme style -->
  <link rel="stylesheet" href="/vendor/admintheme/dist/css/AdminLTE.min.css">
  <!-- AdminLTE Skins. Choose a skin from the css/skins
       folder instead of downloading all of them to reduce the load. -->
  <link rel="stylesheet" href="/vendor/admintheme/dist/css/skins/_all-skins.min.css">

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
  <!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->


    <!-- jQuery -->
    <script src="/vendor/jquery/jquery.min.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="/vendor/bootstrap/js/bootstrap.min.js"></script>


    <!-- TO DO REMOVAL OF ONE OF THE FOLLOWING REMOVES THE DROPDOWN MENU  -->
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

    <!-- Bootstrap 3.3.7 -->
    <script src="/vendor/bootstrap/js/bootstrap.min.js"></script>
    <!-- select2 -->
    <script src="/vendor/select2/js/select2.min.js"></script>


    <!-- LEAFLET ASSETS -->
    <link rel="stylesheet" href="/css/leaflet.css" />
    <link rel="stylesheet" href="/css/custom_map.css" />
    <link rel="stylesheet" href="/js/leaflet.draw/leaflet.draw.css" />
    
    <script src="/js/leaflet.js"></script>
    <!-- /* Leaflet AwesomeMarkers */ -->
    <link rel="stylesheet" href="/css/leaflet.awesome-markers.css">
    <script src="/js/leaflet.awesome-markers.js"></script>
    
    <link rel="stylesheet" href="/css/leaflet.awesome-markers.css">
    <link rel="stylesheet" href="/font-awesome/css/font-awesome.min.css">
    <link rel="stylesheet" href="/css/ionicons/1.5.2/ionicons.min.css">
    <link rel="stylesheet" href="/css/font-awesome-animation.min.css">

    
    <!-- /* Leaflet Draw */ -->
    <script src="/js/leaflet.draw/Leaflet.draw.js"></script>

    <script src="/js/leaflet.draw/edit/handler/Edit.Poly.js"></script>
    <script src="/js/leaflet.draw/edit/handler/Edit.SimpleShape.js"></script>
    <script src="/js/leaflet.draw/edit/handler/Edit.Circle.js"></script>
    <script src="/js/leaflet.draw/edit/handler/Edit.Rectangle.js"></script>

    <script src="/js/leaflet.draw/draw/handler/Draw.Feature.js"></script>
    <script src="/js/leaflet.draw/draw/handler/Draw.Polyline.js"></script>
    <script src="/js/leaflet.draw/draw/handler/Draw.Polygon.js"></script>
    <script src="/js/leaflet.draw/draw/handler/Draw.SimpleShape.js"></script>
    <script src="/js/leaflet.draw/draw/handler/Draw.Rectangle.js"></script>
    <script src="/js/leaflet.draw/draw/handler/Draw.Circle.js"></script>
    <script src="/js/leaflet.draw/draw/handler/Draw.Marker.js"></script>

    <script src="/js/leaflet.draw/ext/LatLngUtil.js"></script>
    <script src="/js/leaflet.draw/ext/GeometryUtil.js"></script>
    <script src="/js/leaflet.draw/ext/LineUtil.Intersect.js"></script>
    <script src="/js/leaflet.draw/ext/Polyline.Intersect.js"></script>
    <script src="/js/leaflet.draw/ext/Polygon.Intersect.js"></script>

    <script src="/js/leaflet.draw/Control.Draw.js"></script>
    <script src="/js/leaflet.draw/Leaflet.Draw.Event.js"></script>
    <script src="/js/leaflet.draw/Tooltip.js"></script>
    <script src="/js/leaflet.draw/Toolbar.js"></script>

    <script src="/js/leaflet.draw/draw/DrawToolbar.js"></script>
    <script src="/js/leaflet.draw/edit/EditToolbar.js"></script>
    <script src="/js/leaflet.draw/edit/handler/EditToolbar.Edit.js"></script>
    <script src="/js/leaflet.draw/edit/handler/EditToolbar.Delete.js"></script>

    <script src="/js/globalVariables.js"></script>

    @yield('assets')
    <title>EM Notification Panel - @yield('title')</title>
  </head>


<body class="hold-transition skin-blue sidebar-mini sidebar-collapse">
<div class="wrapper">

  <header class="main-header">

    <!-- Logo -->
    <a href="/" class="logo">
      <!-- mini logo for sidebar mini 50x50 pixels -->
      <span class="logo-mini"><b>EM</b></span>
      <!-- logo for regular state and mobile devices -->
      <span class="logo-lg"><b>EM</b>Portal</span>
    </a>

    <!-- Header Navbar: style can be found in header.less -->
    <nav class="navbar navbar-static-top">
      <!-- Sidebar toggle button-->
      <a href="#" class="sidebar-toggle" data-toggle="offcanvas" role="button">
        <span class="sr-only">Toggle navigation</span>
      </a>
      <!-- Navbar Right Menu -->
      <div class="navbar-custom-menu">
        <ul class="nav navbar-nav">

          <li class="dropdown">

              @if (Auth::guest())
                <li><a href="{{ url('/login') }}">Login</a></li>
                <li><a href="{{ url('/register') }}">Register</a></li>
              @else
                <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                  <span class="hidden-xs">{{ Auth::user()->name }} </span>
                  <span class="caret"></span>
                </a>

                  <ul class="dropdown-menu" role="menu">
                    <li>
                      <a href="{{ url('/logout') }}"
                          onclick="event.preventDefault();
                                   document.getElementById('logout-form').submit();">
                          Logout
                      </a>

                      <form id="logout-form" action="{{ url('/logout') }}" method="POST" style="display: none;">
                          {{ csrf_field() }}
                      </form>
                    </li>
                  </ul>
                </a>

              @endif
              
          </li>
        </ul>
      </div>

    </nav>
  </header>
  <!-- Left side column. contains the logo and sidebar -->
  <aside class="main-sidebar">
    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">
      <!-- Sidebar user panel -->
      @if (Auth::guest())
        <div></div>
      @else
        <div class="user-panel">
          <div class="pull-left image">
            <img src="/vendor/admintheme/dist/img/placeholder.png" class="img-circle" alt="User Image">
          </div>
          <div class="pull-left info">
            <p>{{ Auth::user()->name }}</p>
            <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
          </div>
        </div>
        <!-- sidebar menu: : style can be found in sidebar.less -->
        <ul class="sidebar-menu">
          <li class="header">MAIN NAVIGATION</li>
          <li class="active">
            <a href="/">
              <i class="fa fa-dashboard"></i> <span>Alert</span>
            </a>
          </li>
          <li class="">
            <a href="/spotterReports">
              <i class="fa fa-files-o"></i>
              <span>Spotter Reports</span>
            </a>
          </li>
        </ul>
      
        <div></div>
      @endif

    </section>
    <!-- /.sidebar -->
  </aside>

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        EM Portal
        <small>Version 0.5</small>
      </h1>
      @if (Auth::user())
        <ol class="breadcrumb">
          <li><a href="#"><i class="fa fa-dashboard"></i> Home</a></li>
          <li class="active">@yield('title')</li>
        </ol>
      @endif
    </section>

    <!-- Main content -->
    <section class="content">
        <div class='container'>
            @include('flash::message')
        </div>
        @yield('content')

    </section>
    <!-- /.content -->


  </div>
  <!-- /.content-wrapper -->

  <footer class="main-footer">
    <div class="pull-right hidden-xs">
      <b>Version</b> 0.5
    </div>
    
  </footer>

</div>
<!-- ./wrapper -->




<!-- FastClick -->
<script src="/vendor/admintheme/plugins/fastclick/fastclick.js"></script>
<!-- AdminLTE App -->
<script src="/vendor/admintheme/dist/js/app.min.js"></script>
<!-- Sparkline -->
<script src="/vendor/admintheme/plugins/sparkline/jquery.sparkline.min.js"></script>
<!-- jvectormap -->
<script src="/vendor/admintheme/plugins/jvectormap/jquery-jvectormap-1.2.2.min.js"></script>
<script src="/vendor/admintheme/plugins/jvectormap/jquery-jvectormap-world-mill-en.js"></script>
<!-- SlimScroll 1.3.0 -->
<script src="/vendor/admintheme/plugins/slimScroll/jquery.slimscroll.min.js"></script>
<!-- ChartJS 1.0.1 -->
<script src="/vendor/admintheme/plugins/chartjs/Chart.min.js"></script>

</body>
</html>