QuakeMap.Views.Quakes ||= {}

class QuakeMap.Views.Quakes.QuakeView extends Backbone.View
  template: JST["backbone/templates/quakes/quake"]

  tagName: "li"

  events:
    "click" : -> @model.highlight()

  render: ->
    $(@el).html(@template({quake:@model}))
    @model.view = @
    @

  highlight: ->
    @$el.addClass("selected")
    @$el.children("div.quake-wrapper").css({"background-color":@model.color()})
    if Modernizr.textshadow
      @$el.find("div.quake-mag").css({"color":"#decc73"})
    else
      @$el.find("div.quake-mag").css({"color":"#222222"})

  unhighlight: ->
    @$el.removeClass("selected")
    @$el.find("div.quake-wrapper").css({"background-color":"transparent"})
    @$el.find("div.quake-mag").css({"color":@model.color()})
