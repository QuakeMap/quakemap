define ['d3', "underscore", "backbone", "leaflet"], (d3, _, Backbone, L)->
  class Quake extends Backbone.Model
    idAttribute: "public_id"

    roundedMagnitude: ->
      d3.round(@get("magnitude"),1)

    formattedTime:->
      parser = d3.time.format.iso
      formatter = d3.time.format("%H:%M:%S %a %d %b %Y")
      formatter parser.parse(@get("origin_time"))

    formattedMagnitude: ->
      formatter = d3.format(".1f")
      formatter @get("magnitude")

    formattedDepth: ->
      formatter = d3.format(".1f")
      formatter @get("depth")

    color: ->
      @collection?.mag_color_scale(@roundedMagnitude())

    position: ->
      lat = @get("coordinates").lat
      lng = @get("coordinates").lng
      lng += 360 if lng < 0
      L.latLng(lat, lng)

    radius: ->
      @collection?.mag_size_scale(Math.pow(10,@roundedMagnitude()))

    marker: ->
      return @_marker if @_marker?
      @_marker = L.circleMarker @position(),
        radius: @radius()
        stroke: true
        color: @color()
        weight: 2
        opacity: 1
        fillColor: @color()
        fillOpacity: 0.5
      @_marker.bindPopup(@popup())
      @_marker.on "click", => @highlight()

    popup: ->
      tmpl = _.template($("#quake_item_tmpl").text())
      y_offset = (parseInt(@radius()) * -1) + 10
      L.popup({offset: L.point(0, y_offset)})
        .setContent(tmpl(@))



    highlight: ->
      @collection?.current_selection?.unhighlight()
      @collection?.current_selection = @
      @_marker?.openPopup()
      @trigger("highlight")

    unhighlight: ->
      @collection?.current_selection = null
      @trigger("unhighlight")
