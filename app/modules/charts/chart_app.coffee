App = require 'application'


module.exports = App.module 'ChartApp', (ChartApp, App, Backbone, Marionette, $, _) =>

    ChartApp.startWithParent = false
    ChartApp.List = require 'modules/chart/list/list_controller'

    API =
      listChart: ->
        ChartApp.List.Controller.listHeader()


    ChartApp.on 'start', ->
      console.log 'header_app Start'

      API.listHeader()
