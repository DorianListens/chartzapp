App = require 'application'

module.exports = App.module 'ArtistsApp',
(ArtistsApp, App, Backbone, Marionette, $, _) ->

  class ArtistsApp.Router extends Marionette.AppRouter
    appRoutes:
      "artist" : "showArtists"

  ArtistsApp.startWithParent = false
  ArtistsApp.Show = require 'modules/artists/show/show_controller'

  API =
    showArtists: ->
      new ArtistsApp.Show.Controller
        region: App.mainRegion
      $(document).foundation()

  App.addInitializer ->
    new ArtistsApp.Router
      controller: API
