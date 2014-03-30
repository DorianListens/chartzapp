App = require 'application'

module.exports = App.module "FooterApp", (FooterApp, App, Backbone, Marionette, $, _) =>

    FooterApp.startWithParent = false;
    FooterApp.Show = require 'modules/footer/show/show_controller'

    API =
      showFooter: ->
        new FooterApp.Show.Controller
          region: App.footerRegion

    FooterApp.on "start", ->
      API.showFooter()
