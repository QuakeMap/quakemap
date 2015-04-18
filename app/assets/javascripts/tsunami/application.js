
var App = {
  Views:{},
  Controllers:{},
  init:function(){
    new App.Controllers.Tsunami();
    Backbone.history.start();
  },
  koordinates_api:"0fc30d226d474a16a746ffd6be129d63",
  current_regions : ["047","039","044"]
};


$(document).ready(function(){
af_initialise(document.getElementById("ac_me"), show_address,{manualStyle:true,search_type:"combined_address",coords:'require'});
  var geocoder = new google.maps.Geocoder();
  $("#address_search").submit(function(){
    geocoder.geocode({'address':$("#ac_me").val(),'region':"nz"},function(results,status){
      if (status == google.maps.GeocoderStatus.OK){
        var result = results[0];
        document.location = "#!/"+result.geometry.location.lat()+"/"+result.geometry.location.lng()+"/"+escape(result.formatted_address);
      } else {
        alert("Sorry we were unable to find the address you entered.");
      }
    });
    return false;
  });

	var latlng = new google.maps.LatLng(-40.88445234514708, 175.16090224609377);
	    var myOptions = {
	      zoom: 8,
	      center: latlng,
	      mapTypeId: google.maps.MapTypeId.TERRAIN
	    };
	    App.map = new google.maps.Map(document.getElementById("map-canvas"), myOptions);

			//var tsu_layer = new google.maps.FusionTablesLayer(481788,{clickable:false,suppressInfoWindows:true});
			//tsu_layer.setMap(App.map);

			var overlayOptions = {
			  getTileUrl:function(coord,zoom){
			   return "http://tiles.quakemap.co.nz/tilecache.cgi/1.0.0/tsunami/"+zoom+"/"+coord.x+"/"+coord.y+".png?type=google"
			  },
			  tileSize: new google.maps.Size(256,256),
			  isPng:true
			}
			var tsunamiOverlay = new google.maps.ImageMapType(overlayOptions);
			App.map.overlayMapTypes.insertAt(0,tsunamiOverlay);
			App.init();
})
function show_address(item) {
	document.location = "#!/"+item.y+"/"+item.x+"/"+escape(item.a);
}

App.Controllers.Tsunami = Backbone.Router.extend({
 routes:{
   "!/:lat/:lng/:q" :   "search_point",
   ""               :   "index"
 },
 search_point:function(lat,lng,q){
   App.overlay = new App.Views.Checking();
   var search = new Search({lat:lat,lng:lng,q:unescape(q)});
   search.bind("ready",function(){
     if (_(App.current_regions).include(search.council.get("TA_NO"))){
       search.fetch({success:function(){
         new App.Views.SearchPoint({search:search});
       }});
     } else {
       new App.Views.NoRegion({search:search});
     }

   });

 },
 index:function(){

 }
});

App.Views.SearchPoint = Backbone.View.extend({
  initialize:function(){
    var result = this.options.search;
    if (App.marker) App.marker.setMap(null);

    App.marker = new google.maps.Marker({position:result.getLatLng(),map:App.map});
    App.map.setCenter(result.getLatLng());
    App.map.setZoom(16);
    $("#description").html(JST['tsunami/description']({result:result}));
    $("#ac_me").val(result.get("q"));
    if (App.overlay) App.overlay.remove();
  }
});
App.Views.NoRegion = Backbone.View.extend({
  initialize:function(){
    var result = this.options.search;
    if (App.marker) App.marker.setMap(null);
      App.marker = new google.maps.Marker({position:result.getLatLng(),map:App.map});
      App.map.setCenter(result.getLatLng());
      App.map.setZoom(16);
    $("#description").html(JST['tsunami/no_region']())
    if (App.overlay) App.overlay.remove();
  }
});
App.Views.Checking = Backbone.View.extend({
  className:"modal_background",
  initialize:function(){
    this.render();
    $("body").append(this.el);
  },
  render:function(){
    var checking_div = $("<div>").text("Checking...").addClass("checking").appendTo($("body"));
    $(this.el).append(checking_div);
    return this;
  }
});

var Council = Backbone.Model.extend({
  url:function(){
    var options = { key:App.koordinates_api,
      x:this.get("lng"),
      y:this.get("lat"),
      radius:0,
      layer:"1247"
    };
    return "http://api.koordinates.com/api/vectorQuery.json?callback=?&"+$.param(options);
  },
  save:function(){},
  parse:function(response){
    if (response.vectorQuery && response.vectorQuery.layers && response.vectorQuery.layers["1247"] && response.vectorQuery.layers["1247"].features[0]){
      return response.vectorQuery.layers["1247"].features[0].properties;
    } else {
      return {};
    }
  }
});

var Search = Backbone.Model.extend({

  url:function(){
      var options = {
        key:App.koordinates_api,
        x:this.get("lng"),
        y:this.get("lat"),
        radius:0,
        layer: this.query_layer()
      };
      return "http://api.koordinates.com/api/vectorQuery.json?callback=?&"+$.param(options);

  },
  initialize:function(){
    var self = this;
    this.council = new Council({lat:this.get("lat"),lng:this.get("lng")});
    this.council.fetch({success:function(model){
      self.trigger("ready");
    }});
  },
  query_layer:function(){
    var layer = false;
    if (this.council){
      switch(this.council.get("TA_NO")){
        case "047":
          layer = "1701";
          break;
        case "039":
          layer = "3171";
          break;
        case "044":
          layer = "3997";
          break;
      }
    }
    return layer;
  },
  parse:function(response){
    var layer = this.query_layer();
    if (response.vectorQuery && response.vectorQuery.layers && response.vectorQuery.layers[layer] && response.vectorQuery.layers[layer].features[0]){
      return response.vectorQuery.layers[layer].features[0].properties;
    } else {
      return {};
    }
  },
  zoneClass:function(){
    return this.get("ZONE_CLASS") || this.get("Zone_Class");
  },
  getLatLng:function(){
    return new google.maps.LatLng(this.get("lat"),this.get("lng"));
  }

});
