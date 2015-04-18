define ["d3", "backbone", 'app/models/quake'], (d3, Backbone, Quake)->
  class QuakesCollection extends Backbone.Collection
    model: Quake
    url: ->
      if @params
        "/quakes/search.json?#{@params}"
      else
        '/recent.json'

    initialize: ->
      @mag_color_scale = d3.scale.linear()
        .range(["#FFd42a","#800026"])

      @mag_size_scale = d3.scale.linear()
        .range([3,30])

      @on "reset", (collection, options)=>
        extent = d3.extent collection.collect((d)-> d.roundedMagnitude())
        @mag_color_scale.domain(extent)
        @mag_size_scale.domain([Math.pow(10,extent[0]),Math.pow(10,extent[1])])


    parse: (response)->
      response.quakes

    magFloor:->
      @mag_floor || @min((quake)-> quake.get("magnitude")).get("magnitude")

    magCeil:->
      @mag_ceil || @max((quake)-> quake.get("magnitude")).get("magnitude")

    purge: ->
      @remove(@models)

    viewportFilter: ->
      @forEach (quake)->
        $(quake.elem).toggle(quake.shouldShow())
        quake.marker.setVisible(quake.shouldShow())

