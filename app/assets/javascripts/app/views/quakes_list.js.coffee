define ["marionette", 'app/views/quake_item'], (Marionette, QuakeItem)->
  class QuakeList extends Marionette.CollectionView
    options:
      itemView: QuakeItem
    tagName: "ul"
    className: "list-unstyled"
