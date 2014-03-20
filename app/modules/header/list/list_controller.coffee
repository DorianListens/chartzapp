App = require 'application'
HeaderApp = require 'modules/header/header_app'

module.exports = App.module 'HeaderApp.List', (List, App, Backbone, Marionette, $, _) ->


  class List.Header extends Marionette.ItemView
    template: "modules/header/list/templates/header"
    tagName: "li"

  class List.Headers extends Marionette.CompositeView
    template: 'modules/header/list/templates/headers'
    itemView: List.Header
    itemViewContainer: "ul.links"

  List.Controller =

    listHeader: ->
      links = App.request "header:entities"
      window.links = links

      headerView = @getHeaderView links
      App.headerRegion.show headerView

    getHeaderView: (links) ->
      new List.Headers
        collection: links
