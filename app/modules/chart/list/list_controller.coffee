App = require 'application'
ChartApp = require 'modules/chart/chart_app'


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
      'click a#submit' : -> @trigger 'click:submitter'


  class List.ChartItem extends Marionette.ItemView
    template: "modules/chart/list/templates/chartItem"
    tagName: 'tr'
    events:
      'click' : -> @trigger 'click:chartItem', @model

  class List.Charts extends Marionette.CompositeView
    template: "modules/chart/list/templates/charts"
    itemView: List.ChartItem
    itemViewContainer: "#thecharts"


  List.Controller =

    listCharts: ->

      station = 'ckut'
      charts = App.request 'chart:entities'
      charts.url = 'api/chart/'+station
      charts.fetch()


      @layout = @getLayoutView()

      @layout.on 'show', =>
        @showPanel charts
        @showCharts charts

      App.mainRegion.show @layout


    showCharts: (charts) ->
      chartsView = @getChartsView charts
      chartsView.on 'itemview:click:chartItem', (iv, chartItem) ->
        App.vent.trigger 'click:chartItem', chartItem
      @layout.tableRegion.show chartsView

    getChartsView: (charts) ->
      new List.Charts
        collection: charts

    showPanel: (charts) ->
      panelView = @getPanelView charts
      panelView.on 'click:submitter', ->
        List.Controller.changeChart(charts)
      @layout.panelRegion.show panelView

    changeChart: (charts) ->
      newStation = document.getElementById("station_input").value
      newDate = document.getElementById("date_input").value
      if newDate is ''
        charts.url = 'api/chart/'+newStation
      else
        charts.url = 'api/chart/'+newStation+'/'+newDate
      charts.fetch()

    getPanelView: (charts) ->
      new List.Panel
        collection: charts

    getLayoutView: ->
      new List.Layout
