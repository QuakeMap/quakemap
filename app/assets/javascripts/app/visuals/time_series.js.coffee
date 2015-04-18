define ["jquery","d3", "underscore", "backbone"], ($, d3, _, Backbone)->
  class TimeSeries
    full_height: 150
    margin:
      top: 30
      bottom: 30
      left: 65
      right: 25

    constructor: (@element, @collection)->
      _.extend(this, Backbone.Events)
      @collection.on "reset", @redraw

      $(window).on "resize", =>
        clearTimeout(@resize_timeout) if @resize_timeout?
        @resize_timeout = setTimeout @resize, 500

      @svg = d3.select(@element).append("svg")
        .attr("height", @full_height)

      @height = @full_height - @margin.top - @margin.bottom

      @grid = @svg.append("g")
        .attr("transform", "translate(#{@margin.left}, #{@margin.top})")

      @x_scale = d3.time.scale().nice()

      @y_scale = d3.scale.linear()
        .range([0, @height]).nice()

      @c_scale = @collection.mag_color_scale

      @x_major_axis = d3.svg.axis()
        .scale(@x_scale)
        .ticks(d3.time.hours, 24)
        .tickFormat(d3.time.format("%a %d"))
        .orient("bottom")

      @x_minor_axis = d3.svg.axis()
        .scale(@x_scale)
        .ticks(d3.time.hours, 6)
        .tickFormat("")
        .orient("bottom")

      @y_axis = d3.svg.axis()
        .scale(@y_scale)
        .orient("left")

      @svg.append("text")
        .attr("transform", "translate(#{@margin.left},#{@margin.top - 10})")
        .attr("class", "x_axis_label label")
        .text("Depth (km)")

      @svg.append("g")
        .attr("class", 'x_major_axis')
        .attr("transform", "translate(#{@margin.left},#{@height+@margin.top})")

      @svg.append("g")
        .attr("class", 'x_minor_axis')
        .attr("transform", "translate(#{@margin.left},#{@height+@margin.top})")

      @svg.append("g")
        .attr("class", 'y_axis')
        .attr("transform", "translate(#{@margin.left},#{@margin.top})")

      @grid = @svg.append("g")
        .attr("transform", "translate(#{@margin.left}, #{@margin.top})")

      @paper = @svg.append("g")
        .attr("transform", "translate(#{@margin.left}, #{@margin.top})")

    resize: =>
      @redraw()
      @resize_timeout = null

    redraw: =>
      @full_width = parseInt d3.select(@element).style("width")
      @svg.attr("width", @full_width)
      @width  = @full_width - @margin.left - @margin.right

      origin_times = @collection.map((d)-> new Date(d.get("origin_time")))
      @x_scale.range([0, @width]).domain( d3.extent(origin_times)).nice()
      @y_scale.domain([0, d3.max(@collection.pluck("depth"))]).nice()

      @svg.select("g.y_axis").call(@y_axis)
      @svg.select("g.x_major_axis").call(@x_major_axis)
      @svg.select("g.x_minor_axis").call(@x_minor_axis)

      even_ticks = _(@y_scale.ticks()).select (n, i)-> i % 2 == 0

      @depth_guides = @grid.selectAll(".depth_guide")
        .data(even_ticks)
      @depth_guides.enter()
        .append("line")
      @depth_guides.exit().remove()
      @depth_guides
        .attr("class", "depth_guide")
        .attr("y1",@y_scale)
        .attr("y2",@y_scale)
        .attr("x1", 0)
        .attr("x2", @width)
        .style("stroke-opacity", (d,i)-> 1/(i+1))


      @dots = @paper.selectAll(".quake_dots")
        .data(@collection.toArray(), (d)-> d.id )
      @dots.enter()
        .append("circle")
        .attr("class", "quake_dots")
        .attr("r", 2)
        .attr("cx", (d)=> @x_scale(new Date(d.get("origin_time"))))
        .attr("cy", (d)=> @y_scale(d.get("depth")))
        .style("fill", (d)=> @c_scale(d.roundedMagnitude()))

      @dots.exit().remove()

      @dots.transition()
        .attr("cx", (d)=> @x_scale(new Date(d.get("origin_time"))))
        .attr("cy", (d)=> @y_scale(d.get("depth")))
        .style("fill", (d)=> @c_scale(d.roundedMagnitude()))

      @dots.sort (a,b)-> a.roundedMagnitude() - b.roundedMagnitude()



