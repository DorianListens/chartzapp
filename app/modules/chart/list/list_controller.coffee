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

    ui:
      'stationInput' : '#station_input'
      'dateInput' : '#date_input'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      stationVal = $.trim @ui.stationInput.val()
      dateVal = $.trim @ui.dateInput.val()
      @trigger 'click:submitter', stationVal, dateVal

  class List.Aside extends Marionette.ItemView
    template: "modules/chart/list/templates/aside"

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
    events:
      'click th' : 'clickHeader'

    sortUpIcon: "fi-arrow-up"
    sortDnIcon: "fi-arrow-down"

    onRender: ->
      @$("th")
      .append($("<i>"))
      .closest("th")
      .find("i")
      .addClass("fi-minus-circle size-18")
      # .end()
      .find("[column=\"" + @collection.sortAttr + "\"] i")
      .removeClass("fi-minus")
      .addClass @sortUpIcon

      @

    clickHeader: (e) =>
      $el = $(e.currentTarget)
      ns = $el.attr("column")
      cs = @collection.sortAttr

      # Toggle sort if the current column is sorted
      if ns is cs
        @collection.sortDir *= -1
      else
        @collection.sortDir = 1

      # Adjust the indicators.  Reset everything to hide the indicator
      $("th").find("i").attr "class", "fi-minus-circle size-18"
        # el.closest

      # Now show the correct icon on the correct column
      if @collection.sortDir is 1
        $el.find("i").removeClass("fi-minus-circle").addClass @sortUpIcon
      else
        $el.find("i").removeClass("fi-minus-circle").addClass @sortDnIcon

      # Now sort the collection
      @collection.sortCharts ns
      return



  class List.Controller extends App.Controllers.Base

    initialize: ->

      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        @showPanel()
        @showCharts()

      @show @layout,
        loading: true

    showCharts: (station, date) ->
      charts = App.request 'chart:entities', station, date

      App.execute "when:fetched", charts, =>
        console.log 'fetched'
      charts.sort()
      chartsView = @getChartsView charts
      asideView = @getAsideView charts

      # @listenTo charts, 'sort', =>
      #   # @show chartsView,
      #   #   region: @layout.tableRegion

      @show chartsView,
        region: @layout.tableRegion
        loading: true
      @show asideView,
        region: @layout.asideRegion
        loading: true


    getChartsView: (charts) ->
      new List.Charts
        collection: charts

    showPanel: (charts) ->
      panelView = @getPanelView charts
      @listenTo panelView, 'click:submitter', (station, date) =>
        @showCharts station, date

      @listenTo panelView, 'click:sort', =>
        @sortChart(charts)

      @show panelView,
        region: @layout.panelRegion
      $(document).foundation()

    getPanelView: (charts) ->
      new List.Panel
        collection: charts

    getLayoutView: ->
      new List.Layout

    getAsideView: (charts) ->
      new List.Aside
        collection: charts
