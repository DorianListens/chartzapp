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

    onRender: ->
      $(document).on 'open', '#feedback', =>
        $("a#clear").on("click", (e) ->
          $("input, textarea").val('')
          $("form div").removeClass("error")
          $("form label").removeClass("error")
          $("form")[0].reset())
        $("#feedback-form").on("invalid", ->
          invalid_fields = $(this).find("[data-invalid]")
        ).on "valid", Foundation.utils.debounce((e) =>
          @send(e)
        , 300, true)
      $(document).on 'close', '#feedback', ->
        $("div#alert-container").fadeOut()
        $("form div").removeClass("error")
        $("form label").removeClass("error")
        $("form")[0].reset()

    send: (e) ->
      e.preventDefault()
      $.post "/api/feedback", $("#feedback-form").serialize(), (data) ->
        $("input, textarea").val('')
        $("div#alert-container").fadeIn('slow').removeClass("hide")

    home: (e) ->
      e.preventDefault()
      route = "home"
      App.navigate route, trigger: true

    clear: (e) ->
      e.preventDefault()
      console.log "clicked"

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @listHeader()
      $(document).foundation()

    listHeader: ->
      links = App.request "header:entities"
      window.links = links

      headerView = @getHeaderView links

      @show headerView

    getHeaderView: (links) ->
      new List.Headers
        collection: links
