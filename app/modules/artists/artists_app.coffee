App = require 'application'

module.exports = App.module 'ArtistsApp',
(ArtistsApp, App, Backbone, Marionette, $, _) ->

  class ArtistsApp.Router extends Marionette.AppRouter
    appRoutes:
      "artist(/)(:artist)" : "showArtists"

  ArtistsApp.startWithParent = false
  ArtistsApp.Show = require 'modules/artists/show/show_controller'

  API =
    showArtists: (artist) ->
      new ArtistsApp.Show.Controller
        region: App.mainRegion
        artist: artist if artist
      $(document).foundation()

  App.addInitializer ->
    new ArtistsApp.Router
      controller: API
