App = require "application"
Controllers = require "controllers/baseController"

module.exports = App.module 'AboutApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @layout = @getLayoutView()
      # stations = App.request "stations:entities"
      #
      # @listenTo @layout, 'show', =>
      #   @showChart()
      #   @showList(stations)
      #   # @showSearch(stations)
      #
      # @listenTo @layout, 'change:time', (time) =>
      #   search = {}
      #   search.request = time
      #   @showChart(search)
      #
      # @listenTo @layout, 'change:range', (time) =>
      #   search = {}
      #   search.request = 1
      #   search.startDate = time.date1
      #   search.endDate = time.date2
      #   @showChart(search)

      @show @layout,
        loading: true
      $(document).foundation()

    getLayoutView: ->
      new Show.Layout

# VIEW ##########################################################

  class Show.Layout extends Marionette.Layout
    template: "modules/about/showAbout/templates/show_layout"
    id: "about-page"
