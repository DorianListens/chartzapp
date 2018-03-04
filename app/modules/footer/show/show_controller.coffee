App = require 'application'
FooterApp = require 'modules/footer/footer_app'
Controllers = require 'controllers/baseController'

module.exports = App.module "FooterApp.Show",
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Footer extends Marionette.ItemView
    template: 'views/templates/footer'

  class Show.Controller extends App.Controllers.Base
    initialize: ->
      footerView = @getFooterView()
      @show footerView

    getFooterView: ->
      new Show.Footer
