define ["marionette"], (Marionette)->
  class QuakeItem extends Marionette.ItemView
    tagName: "li"
    template: '#quake_item_tmpl'

    initialize: ->
      @model.on "highlight", => @highlight()
      @model.on "unhighlight", => @unhighlight()

    templateHelpers: ->
      color: =>  @model.color()
      formattedMagnitude: =>  @model.formattedMagnitude()
      formattedTime: =>  @model.formattedTime()
      formattedDepth: =>  @model.formattedDepth()

    events:
      "click": -> @model.highlight()

    highlight: ->
      $(@el).addClass("selected")
      $(@el).children("div.quake-wrapper").css({"background-color":@model.color()})
      if Modernizr.textshadow
        $(@el).find("div.quake-mag").css({"color":"#decc73"})
      else
        $(@el).find("div.quake-mag").css({"color":"#222222"})

    unhighlight: ->
      $(@el).removeClass("selected")
      $(@el).find("div.quake-wrapper").css({"background-color":"transparent"})
      $(@el).find("div.quake-mag").css({"color":@model.color()})
