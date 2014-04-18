App = require 'application'

module.exports = App.module 'TopxApp',
(TopxApp, App, Backbone, Marionette, $, _) ->

  class TopxApp.Router extends Marionette.AppRouter
    appRoutes:
      "topx(/)(:station)" : "showTopx"

  TopxApp.startWithParent = false
  TopxApp.Show = require 'modules/topx/showTopx/showTopx_controller'

  API =
    showTopx: (station) ->
      new TopxApp.Show.Controller
        region: App.mainRegion
        station: station if station
      $(document).foundation()

  App.addInitializer ->
    new TopxApp.Router
      controller: API
