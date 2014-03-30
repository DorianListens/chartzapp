App = require 'application'


module.exports = App.module 'ChartApp', (ChartApp, App, Backbone, Marionette, $, _) =>

    class ChartApp.Router extends Marionette.AppRouter
      appRoutes:
        "listchart" : "listChart"

    ChartApp.startWithParent = false
    ChartApp.List = require 'modules/chart/list/list_controller'

    API =
      listChart: ->
        new ChartApp.List.Controller
          region: App.mainRegion
        $(document).foundation()

    App.addInitializer ->
      new ChartApp.Router
        controller: API
