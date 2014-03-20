App = require 'application'


module.exports = App.module 'HeaderApp', (HeaderApp, App, Backbone, Marionette, $, _) =>

    HeaderApp.startWithParent = false
    HeaderApp.List = require 'modules/header/list/list_controller'

    API =
      listHeader: ->
        HeaderApp.List.Controller.listHeader()


    HeaderApp.on 'start', ->
      API.listHeader()
