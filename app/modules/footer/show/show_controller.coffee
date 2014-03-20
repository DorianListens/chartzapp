# Show Controller
App = require 'application'
FooterApp = require 'modules/footer/footer_app'

module.exports = App.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) =>

  class Show.Footer extends Marionette.ItemView
    template: '/views/templates/footer'

  Show.Controller =
    showFooter: ->
      footerView = @getFooterView()
      App.footerRegion.show footerView

    getFooterView: ->
      new Show.Footer
