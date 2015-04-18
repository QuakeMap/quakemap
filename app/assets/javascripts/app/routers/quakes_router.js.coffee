class QuakeMap.Routers.QuakesRouter extends Backbone.Router
  initialize: (options) ->
    QuakeMap.quakes = new QuakeMap.Collections.QuakesCollection()
    QuakeMap.quakes.reset options.quakes if options?.quakes

  routes:
    ""                  : "index"
    "quakes/search?*qs" : "search"

  index: ->
    QuakeMap.quakes.params = null
    @update()


  search: (qs)->
    QuakeMap.quakes.params = qs
    @update()

  update: ->
    QuakeMap.quakes.purge()
    QuakeMap.quakes.fetch
      success: (collection, response)=>
        QuakeMap.current_state.set("mag_floor", response.mag_floor)
        QuakeMap.current_state.set("mag_ceil", response.mag_ceil)
        @view = new QuakeMap.Views.Quakes.IndexView(collection: QuakeMap.quakes)

        $("#quakes").html(@view.render().el)
