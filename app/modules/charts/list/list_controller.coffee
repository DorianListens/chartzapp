@App.module "ChartsApp.List", (List, App, Backbone, Marionette, $, _) ->

  List.Controller =

    listCharts: ->

      charts = App.request 'chart:entites'

      @layout = @getLayoutView()

      @layout.on 'show', =>
        @showPanel charts
        @listCharts charts

      App.mainRegion.show @layout

    listCharts: (charts) ->
      chartsView = @getChartsView charts
      chartsView.on 'itemview:click:chartItem', (iv, chartItem) ->
        App.vent.trigger 'click:chartItem', chartItem
      @layout.tableRegion.show chartsView

    getChartsView: (charts) ->
      new List.Charts
        collection: charts

    showPanel: (charts) ->
      panelView = @getPanelVIew charts
      @layout.panelRegion.show panelView

    getPanelView: (charts) ->
      new List.Charts
        collection: charts

    getLayoutView: ->
      new List.Layout
