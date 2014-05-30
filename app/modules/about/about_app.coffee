App = require 'application'

module.exports = App.module 'AboutApp',
(AboutApp, App, Backbone, Marionette, $, _) ->

  class AboutApp.Router extends Marionette.AppRouter
    appRoutes:
      "faq" : "about"

  AboutApp.startWithParent = false
  AboutApp.Show = require 'modules/about/showAbout/showAbout_controller'

  API =
    about: ->
      new AboutApp.Show.Controller
        region: App.mainRegion
      $(document).foundation()

  App.addInitializer ->
    new AboutApp.Router
      controller: API
