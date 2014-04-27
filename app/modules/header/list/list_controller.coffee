App = require 'application'
HeaderApp = require 'modules/header/header_app'

module.exports = App.module 'HeaderApp.List',
(List, App, Backbone, Marionette, $, _) ->


  class List.Header extends Marionette.ItemView
    template: "modules/header/list/templates/header"
    tagName: "li"
    events:
      'click' : 'nav'
    nav: (e) ->
      e.preventDefault()
      route = @model.get('path')
      App.navigate(route, trigger: true)


  class List.Headers extends Marionette.CompositeView
    template: 'modules/header/list/templates/headers'
    itemView: List.Header
    itemViewContainer: "ul.links"
    events:
      "click a#home" : "home"
    home: (e) ->
      e.preventDefault()
      route = "home"
      App.navigate route, trigger: true

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @listHeader()

    listHeader: ->
      links = App.request "header:entities"
      window.links = links

      headerView = @getHeaderView links
      @show headerView

    getHeaderView: (links) ->
      new List.Headers
        collection: links
