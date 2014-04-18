App = require 'application'

module.exports = App.module 'StationApp',
(StationApp, App, Backbone, Marionette, $, _) ->

  class StationApp.Router extends Marionette.AppRouter
    appRoutes:
      "station(/)(:station)" : "showStation"

  StationApp.startWithParent = false
  StationApp.Show = require 'modules/station/showStation/showStation_controller'

  API =
    showStation: (station) ->
      new StationApp.Show.Controller
        region: App.mainRegion
        station: station if station
      $(document).foundation()

  App.addInitializer ->
    new StationApp.Router
      controller: API
