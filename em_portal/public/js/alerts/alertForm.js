function addToSelect2InForm(formId, buildingName, optionValue, select2ID){
  select2 = $('#'+select2ID);
  var newBuildingValue = optionValue;
  optionsChosen = select2.val();
  if(optionsChosen == null)
    optionsChosen = []
  if(jQuery.inArray( newBuildingValue.toString(), optionsChosen ) != -1){
    return ;
  }
  optionsChosen.push(newBuildingValue);
  // Set the value, creating a new option if necessary
  if ($(select2).find("option[value='" + newBuildingValue + "']").length) {
    $(select2).val(optionsChosen).trigger("change");
  } else { 
    // Create the DOM option that is pre-selected by default
    var newBuilding = new Option(buildingName, newBuildingValue, true, true);
    // Append it to the select
    $(select2).append(newBuilding);
    $(select2).val(optionsChosen).trigger("change");
  } 
}

function removeFromSelect2InForm(formId, buildingName, optionValue, select2ID){
  select2 = $('#'+select2ID);
  var removeBuildingValue = optionValue;
  optionsChosen = select2.val();
  if(jQuery.inArray( removeBuildingValue.toString(), optionsChosen ) == -1){
    return ;
  }
  $("#"+select2ID+" option[value='"+removeBuildingValue+"']").remove();
}