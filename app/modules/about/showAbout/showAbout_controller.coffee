App = require "application"
Controllers = require "controllers/baseController"

module.exports = App.module 'AboutApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @layout = @getLayoutView()

      @show @layout,
        loading: true
      $(document).foundation()

    getLayoutView: ->
      new Show.Layout

# VIEW ##########################################################

  class Show.Layout extends Marionette.Layout
    template: "modules/about/showAbout/templates/show_layout"
    id: "about-page"
