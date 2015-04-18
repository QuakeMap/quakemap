define [
  "d3", "marionette", "crossfilter", "leaflet",
  'app/collections/quakes', 'app/views/quakes_list', 'app/visuals/magnitude_scale', 'app/visuals/time_series'
  "leaflet_providers", "leaflet_bing"
], (d3, Marionette, crossfilter, L, QuakesCollection, QuakesList, MagnitudeScale, TimeSeries)->
  App = new Marionette.Application()

  App.addRegions
    quake_list_region: "#quakes"

  App.addInitializer ->
    $(window).resize ->
      $(".content").height(($(window).height()-50)+"px")
    $(window).resize()

  App.addInitializer ->
    @map = L.map('map',{zoomControl:false}).fitBounds [
      [-47.54687159892238, 164.9267578125],
      [-34.34343606848293, 182.50488281249997]
    ]
    maptypes =
      "Map": new L.tileLayer.provider('Stamen.TonerLite',{detectRetina: true})
      "Hybrid" : L.layerGroup [
          new L.BingLayer("AioX_SQM_XDp5BfH1I-OCboEHatcZYoa1XizAOcmUORnnFQr1jAzTF8sQIAfZBzy",{type:"Aerial"})
          new L.tileLayer.provider('Stamen.TonerHybrid',{detectRetina: true})
        ]
    @map.addLayer(maptypes["Map"])
    @map.addControl(new L.Control.Layers(maptypes,{}))


  App.addInitializer ->
    @quakes = new QuakesCollection()
    @quake_list = new QuakesList(collection: @quakes)
    @quake_list_region.show @quake_list
    if Modernizr.svg
      @scale = new MagnitudeScale(document.getElementById("scale"), @quakes)
      @time_series = new TimeSeries(document.getElementById("time_series"), @quakes)

    @quakes.on "reset", (collection, options)=>
      @quake_list.render()
      options.previousModels?.forEach (model)=>
        @map.removeLayer(model.marker())
      collection.forEach (model)=>
        @map.addLayer(model.marker())
        model.on "highlight", =>
          @map.panTo(model.position())

  App.addInitializer ->
    @cf = crossfilter()
    @dimensions =
      felt: @cf.dimension (d)-> d.felt
      time: @cf.dimension (d)-> d.origin_time
    $.get "/recent.json", (data)=>
      @cf.add data.quakes
      @filterFelt()

  App.addInitializer ->
    $("#view_felt").click =>
      @filterFelt()
      false

    $("#view_all").click =>
      @filterAll()
      false

  App.addInitializer ->
    $("#zoom_in").click =>
      @map?.zoomIn()
      false
    $("#zoom_out").click =>
      @map?.zoomOut()
      false

    $("#latest_quake").click =>
      quake = @quakes?.first()
      quake?.highlight()
      false

    $("#strongest_quake").click =>
      quake = @quakes?.max (quake)-> quake.get("magnitude")
      quake?.highlight()
      false


  App.resetQuakes = ->
    @quakes.reset(@dimensions.time.top(Infinity))

  App.filterFelt = ->
    @dimensions.felt.filter(true)
    @resetQuakes()
    $("#view_toggle a").removeClass("selected")
    $("#view_felt").addClass("selected")

  App.filterAll = ->
    @dimensions.felt.filterAll()
    @resetQuakes()
    $("#view_toggle a").removeClass("selected")
    $("#view_all").addClass("selected")


  return App

