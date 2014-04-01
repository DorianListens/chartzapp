App = require 'application'


module.exports = App.module 'HeaderApp',
(HeaderApp, App, Backbone, Marionette, $, _) ->

  HeaderApp.startWithParent = false
  HeaderApp.List = require 'modules/header/list/list_controller'

  API =
    listHeader: ->
      listController = new HeaderApp.List.Controller
        region: App.headerRegion

  HeaderApp.on 'start', ->
    console.log 'HeaderApp start'
    API.listHeader()
