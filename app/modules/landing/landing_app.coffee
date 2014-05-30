App = require 'application'

module.exports = App.module 'LandingApp',
(LandingApp, App, Backbone, Marionette, $, _) ->

  class LandingApp.Router extends Marionette.AppRouter
    appRoutes:
      "home" : "landing"

  LandingApp.startWithParent = false
  LandingApp.Show = require 'modules/landing/showLanding/showLanding_controller'

  API =
    landing: ->
      new LandingApp.Show.Controller
        region: App.mainRegion
      $(document).foundation()

  App.addInitializer ->
    new LandingApp.Router
      controller: API
