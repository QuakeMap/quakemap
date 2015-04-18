QuakeMap.Views.Quakes ||= {}

class QuakeMap.Views.Quakes.IndexView extends Backbone.View
  tagName: "ul"
  className: "list-unstyled"

  addAll: () =>
    @collection.each(@addOne)
    @addScale() if @collection.length > 0 and QuakeMap.scale_paper?

  addOne: (quake) =>
    view = new QuakeMap.Views.Quakes.QuakeView({model : quake})
    $(@el).append(view.render().el)
    quake.elem = view.el
    quake.addMarker()

  render: =>
    $(@el).html()
    @addAll()
    @

  addScale: ->
    color_scale = QuakeMap.current_state.mag_color_scale
    size_scale = QuakeMap.current_state.mag_size_scale
    domain = color_scale.domain()
    y = d3.scale.linear().range([0,185]).domain(domain)


    area = d3.svg.area()
    .y((d)=>y(d))
    .x0((d)=> 70 - size_scale(Math.pow(10,d)))
    .x1((d)=> 70 + size_scale(Math.pow(10,d)))
    QuakeMap.scale_paper.selectAll("g").remove()
    g = QuakeMap.scale_paper.append("svg:g").attr("transform","translate(0,5)")

    ticks = color_scale.ticks(4)
    g.selectAll(".majorline")
    .data(ticks)
    .enter()
    .append("line")
    .attr("class","majorline")
    .attr("y1",y)
    .attr("y2",y)
    .attr("x1",10)
    .attr("x2",140)

    g.selectAll(".majortick")
    .data(ticks)
    .enter()
    .append("text")
    .attr("class","majortick")
    .attr("x",0)
    .attr("y",y)
    .text((d) => d)

    data = d3.range(domain[0],domain[1],0.1)
    g.selectAll(".scale_graph")
    .data(data)
    .enter()
    .append("path")
    .attr("class","scale_graph")
    .attr("d",(d)=>area([d, d+0.1]))
    .attr("fill",(d)=>color_scale(d))
    .attr("stroke",(d)=>color_scale(d))

    return

