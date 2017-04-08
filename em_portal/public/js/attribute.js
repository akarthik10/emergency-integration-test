/**
 * Created by gmac on 25.11.16.
 */

var Attribute = function (obj) {
    this.name = "";
    this.title = "";
    this.selectCount = 1;
    this.selectType = "number";
    this.type = "number";
    this.options = [];
    this.optionsByName = {};

    for (var prop in obj) {
        if (obj.hasOwnProperty(prop)) {
            this[prop] = obj[prop];
        }
    }

    for (var option in this.options) {
        this.optionsByName[""+option.name] = option;
    }

    this.getAttributeIDName = function () {
        return "attribute-"+this.name;
    };

    this.getFormHTML = function () {

        var div = "<div class='form-group'></div>";
        var divObject = $('#polygon-notification-form').append(div);

        var label = "<label class='col-sm-3 control-label'>" + title + "</label>";
        var labelObject = divObject.html(label);

        var div2Object = labelObject.append("<div class='col-sm-3'></div>");

        // now add all options
        var optionsHTML = "";
        for (var j = 0; j < options.length; j++){

            var option = options[j];
            var inputType = "number";
            if(option.type == "number"){
                inputType = "number";
            } else if(option.type == "bool"){
                inputType = "checkbox";
            }
            var id = "attribute-"+attribute.name+"-"+option.name;
            optionsHTML = optionsHTML + "<input type='"+inputType+"' class='form-control' name='attribute-age-minimum' id="+id+" value='"+option.value+"' placeholder='"+option.title+"' min='1' max='100'/>"
        }
        div2Object.html(optionsHTML);
    };
}

Attribute.prototype.getOptionWithName = function(name){
    return this.optionsByName[""+name];
}

var AttributeOption = function (obj) {
    this.attribute;
    this.name = "";
    this.title = "";
    this.value = "";

    for (var prop in obj) {
        if (obj.hasOwnProperty(prop)) {
            this[prop] = obj[prop];
        }
    }
}


var AttributesList = function (obj) {
    this.attributes = [];
    this.attributesByName = {};

    for (var prop in obj) {
        if (obj.hasOwnProperty(prop)) {
            this[prop] = obj[prop];
        }
    }

    for(var i = 0; i < this.attributes.length; i++){
        var attribute = this.attributes[i];
        this.attributesByName[""+attribute.name] = attribute;
    }

}

AttributesList.prototype.push = function(object){
    this.attributes.push(object);
    this.attributesByName[""+object.name] = object;
}

AttributesList.prototype.pop = function(object){
    this.attributes.pop(object);
}

AttributesList.prototype.getAttributeOptionWithName = function(name){
    for (var attribute in this.attributesByName) {
        var option = attribute.getOptionWithName(name);
        if(option){
            return option;
        }
    }
    return null;
}

AttributesList.createAttributes = function(data){

    var attributesList = new AttributesList();
    for(var i = 0; i < data.length; i++){

        var object = data[i];
        // attribute
        var attribute = new Attribute(object);
        attributesList.push(attribute);
    }
    return attributesList;
}


var AttributeSelection = function (obj) {
    this.attribute = new Attribute();
    this.values = []; // AttributeOption[]

    for (var prop in obj) {
        if (obj.hasOwnProperty(prop)) {
            this[prop] = obj[prop];
        }
    }
}

AttributesList.createAttributesRequest = function(selections) {
    // create a GNS request string for the given selections of attribute fields
    // e.g. age between 20-30 and wheelchair-bound = true
    // result e.g.: ?field=attributesList.age>=20&

    for(var i = 0; i < selections.length; i++){

    }
}