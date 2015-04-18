define ["jquery", "d3"], ($, d3)->
  class MagnitudeScale
    full_height: 150
    margin:
      top: 30
      left: 25
      right: 25
      bottom: 30
    constructor: (@element, @collection)->
      @collection.on "reset", @redraw

      $(window).on "resize", =>
        clearTimeout(@resize_timeout) if @resize_timeout?
        @resize_timeout = setTimeout @resize, 500

      @svg = d3.select(@element).append("svg")
        .attr("height",@full_height)

      @height = @full_height - @margin.top - @margin.bottom

      @grid   = @svg.append("g").attr("transform", "translate(#{@margin.left}, #{@margin.top})")
      @paper  = @svg.append("g").attr("transform", "translate(#{@margin.left}, #{@margin.top})")

      @x_scale = d3.scale.linear()
      @y_scale = @collection.mag_size_scale
      @color_scale = @collection.mag_color_scale

      @x_axis = d3.svg.axis()
        .scale(@x_scale)
        .ticks(4)
        .orient("bottom")

      @svg.append("g")
        .attr("class", 'x_axis')
        .attr("transform", "translate(#{@margin.left},#{@height+@margin.top})")

      @svg.append("text")
        .attr("class", "title label")
        .text("Magnitude Scale")

      @area = d3.svg.area()
        .x(@x_scale)
        .y0((d)=> (@height/2.0) - @y_scale(Math.pow(10,d)))
        .y1((d)=> (@height/2.0) + @y_scale(Math.pow(10,d)))


    resize: =>
      @redraw()
      @resize_timeout = null


    redraw: =>
      @full_width = parseInt( d3.select(@element).style("width"), 10)
      @svg.attr("width",@full_width)
      @width = @full_width - @margin.left - @margin.right
      d3.select("text.title").attr("transform", "translate(#{@full_width/2},#{@margin.top - 10})")

      domain = d3.extent @collection.collect((d)-> d.roundedMagnitude())
      @x_scale.range([0,@width]).domain(domain)

      @svg.select("g.x_axis").call(@x_axis)
      ticks = @x_scale.ticks(4)
      majorline = @grid.selectAll(".majorline")
        .data(ticks)
      majorline.enter()
        .append("line")
      majorline.exit().remove()
      majorline.attr("class","majorline")
        .attr("y1",0)
        .attr("y2",@height)
        .attr("x1",@x_scale)
        .attr("x2",@x_scale)

      data = d3.range(@x_scale.domain()[0], @x_scale.domain()[1], 0.1)
      scalegraph = @paper.selectAll(".scale_graph")
        .data(data)
      scalegraph.enter()
        .append("path")
      scalegraph.exit().remove()
      scalegraph.attr("class","scale_graph")
        .attr("d",(d)=> @area([d, d+0.1]))
        .attr("fill",(d)=> @color_scale(d))
        .attr("stroke",(d)=> @color_scale(d))

