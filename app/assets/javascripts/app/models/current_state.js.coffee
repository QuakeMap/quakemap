class QuakeMap.Models.CurrentState extends Backbone.Model
  defaults:
    showing: "visible"

  initialize: ->
    @on("change:mag_floor change:mag_ceil", @resetScales)

  resetScales: ->
    if @get("mag_floor") and @get("mag_ceil")
      @mag_color_scale = d3.scale.linear()
      .range(["#FFd42a","#800026"])
      .domain([@get("mag_floor"), @get("mag_ceil")])
      .nice()
      formatter = d3.format(".1f")
      floor = formatter(@mag_color_scale.domain()[0])
      ceiling = formatter(@mag_color_scale.domain()[1])

      $("#mag_range").html("#{floor} to #{ceiling}")

      @mag_size_scale = d3.scale.linear()
      .range([3,30])
      .domain([Math.pow(10,@get("mag_floor")),Math.pow(10,@get("mag_ceil"))])
      .nice()

