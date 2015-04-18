define ["marionette", 'app/views/quake_item'], (Marionette, QuakeItem)->
  class QuakeList extends Marionette.CollectionView
    itemView: QuakeItem
    tagName: "ul"
    className: "list-unstyled"

