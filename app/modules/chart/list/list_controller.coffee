App = require 'application'
ChartApp = require 'modules/chart/chart_app'
Controllers = require 'controllers/baseController'


module.exports = App.module "ChartApp.List", (List, App, Backbone, Marionette, $, _) =>

  class List.Layout extends Marionette.Layout
    template: "modules/chart/list/templates/list_layout"

    regions:
      panelRegion: "#panel-region"
      asideRegion: "#aside-region"
      tableRegion: "#table-region"

  class List.Panel extends Marionette.ItemView
    template: "modules/chart/list/templates/panel"
    events:
      'submit' : (e) ->
        e.preventDefault()
        @trigger 'click:submitter'
      'click button#sort' : (e) ->
        e.preventDefault()
        @trigger 'click:sort'

  class List.ChartItem extends Marionette.ItemView
    template: "modules/chart/list/templates/chartItem"
    tagName: 'tr'

  class List.Empty extends Marionette.ItemView
    template: "modules/chart/list/templates/empty"
    tagName: 'tr'

  class List.Charts extends Marionette.CompositeView
    template: "modules/chart/list/templates/charts"
    itemView: List.ChartItem
    emptyView: List.Empty
    itemViewContainer: "#thecharts"


  class List.Controller extends App.Controllers.Base

    # listCharts: ->
    initialize: ->

      # rentals = App.request "movie:rental:entities"
      #
			# App.execute "when:fetched", rentals, =>
			# 	## perform aggregates / sorting / nesting here
			# 	## this is helpful when you want to perform operations but only after
			# 	## all the required dependencies have been fetched and are available
			# 	rentals.reset rentals.sortBy "runtime"
      #
			# @layout = @getLayoutView()
      #
			# @listenTo @layout, "show", =>
			# 	@resultsView rentals
			# 	@rentalsView rentals
			# 	@paginationView rentals
      #
			# @show @layout,
			# 	loading:
			# 		entities: rentals

      station = 'ckut'
      # url = '/api/db/wholething'
      charts = App.request 'chart:entities', '/api/db/wholething'
      App.execute "when:fetched", charts, =>
        console.log 'fetched'

      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        # charts.sort()
        @showPanel charts
        @showCharts charts

      # App.mainRegion.show @layout
      @show @layout,
        loading:
          entities: charts

    showCharts: (charts) ->
      charts.sort()
      chartsView = @getChartsView charts
      @layout.tableRegion.show chartsView

    getChartsView: (charts) ->
      new List.Charts
        collection: charts

    showPanel: (charts) ->
      panelView = @getPanelView charts
      panelView.on 'click:submitter', =>
        @changeChart(charts)
      panelView.on 'click:sort', =>
        @sortChart(charts)
      @layout.panelRegion.show panelView
      $(document).foundation()

    sortChart: (charts) =>
      console.log "clicked"
      # charts.comparator = "points"
      charts.sort()
      @showCharts charts

    changeChart: (charts) ->
      newStation = document.getElementById("station_input").value
      newDate = document.getElementById("date_input").value
      if newDate is ''
        charts.url = 'api/chart/'+newStation
      else
        charts.url = 'api/chart/'+newStation+'/'+newDate
      charts.fetch
        success: (collection) =>
          @showPanel charts
          charts.sort()
          @showCharts charts


      # charts = App.request 'chart:entities', chartsUrl
      # App.execute "when:fetched", charts, =>
      #
      # @show @layout,
      #   loading:
      #     entities: charts

    getPanelView: (charts) ->
      new List.Panel
        collection: charts

    getLayoutView: ->
      new List.Layout
