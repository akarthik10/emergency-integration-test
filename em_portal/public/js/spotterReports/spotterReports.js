function ConfirmSpotterReportDelete(){
  var message = Lang.get('spotterReports.delete');

  var x = confirm(message);
  if (x)
    return true;
  else
    return false;
}