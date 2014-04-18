App = require 'application'

module.exports = App.module 'LabelApp',
(LabelApp, App, Backbone, Marionette, $, _) ->

  class LabelApp.Router extends Marionette.AppRouter
    appRoutes:
      "label(/)(:label)" : "showLabel"

  LabelApp.startWithParent = false
  LabelApp.Show = require 'modules/label/showLabel/showLabel_controller'

  API =
    showLabel: (label) ->
      console.log "showLabel"
      new LabelApp.Show.Controller
        region: App.mainRegion
        label: label if label
      $(document).foundation()

  App.addInitializer ->
    new LabelApp.Router
      controller: API
