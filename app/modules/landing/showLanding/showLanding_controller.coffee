App = require "application"
TopxApp = require "modules/landing/landing_app"
Controllers = require "controllers/baseController"

module.exports = App.module 'LandingApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @layout = @getLayoutView()
      stations = App.request "stations:entities"

      @listenTo @layout, 'show', =>
        @showChart()
        @showList(stations)
        @showSearch(stations)

      @show @layout,
        loading: true

    showChart: ->
      search = {}
      topCharts = App.request 'topx:entities', search

      chartView = @getChartView topCharts

      @show chartView,
        region: @layout.tableRegion
        loading: true
      App.execute "when:fetched", topCharts, ->
        topCharts.sort()
        $(document).foundation()

    getChartView: (topCharts) ->
      new Show.Chart
        collection: topCharts

    showSearch: (stations) ->
      console.log stations
      searchView = @getSearchView stations
      @listenTo searchView, 'click:search', (newSearch) ->
        App.vent.trigger "new:search", newSearch

      @show searchView,
        region: @layout.searchRegion
        loading: true
      $(document).foundation()
      # $(".chosen-select").chosen()

    showList: (stations) ->
      listView = @getListView stations

      @show listView,
        region: @layout.listRegion
        loading: true


    getSearchView: (stations) ->
      new Show.Search
        collection: stations

    getLayoutView: ->
      new Show.Layout

    getListView: (stations) ->
      new Show.StationList
        collection: stations


# VIEW ######################################################################


  class Show.Layout extends Marionette.Layout
    template: "modules/landing/showLanding/templates/show_layout"

    regions:
      titleRegion: "#title_region"
      blurbRegion: "#blurb_region"
      searchRegion: "#search_region"
      tableRegion: "#table_region"
      listRegion: "#list_region"

  class Show.Search extends Marionette.ItemView
    template: "modules/landing/showLanding/templates/search"

    ui:
      'searchInput' : '#search_input'
      'kind'        : '#kind_input'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      search = {}
      search.keyword = $.trim @ui.searchInput.val()
      search.kind = $.trim @ui.kind.val()
      @trigger 'click:search', search

  class Show.StationList extends Marionette.ItemView
    template: "modules/landing/showLanding/templates/stationList"
    className: "panel small-12 columns"

  class Show.ChartItem extends Marionette.ItemView
    template: "modules/landing/showLanding/templates/chartItem"
    tagName: 'tr'
    initialize: ->
      @model = @model.set index: @options.index

  class Show.Empty extends Marionette.ItemView
    template: "modules/topx/showTopx/templates/empty"
    tagName: 'tr'

  class Show.Chart extends Marionette.CompositeView
    template: "modules/landing/showLanding/templates/chart"
    itemView: Show.ChartItem
    emptyView: Show.Empty
    itemViewContainer: "#thecharts"
    itemViewOptions: (model) ->
      index: @collection.indexOf(model) + 1

    events:
      'click th' : 'clickHeader'

    sortUpIcon: "fi-arrow-down"
    sortDnIcon: "fi-arrow-up"

    onRender: ->
      @$("th")
      .append($("<i>"))
      .closest("th")
      .find("i")
      .addClass("fi-minus-circle size-18")
      @$("[column='#{@collection.sortAttr}']")
      .find("i")
      .removeClass("fi-minus-circle")
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

      # Now show the correct icon on the correct column
      if @collection.sortDir is 1
        $el.find("i").removeClass("fi-minus-circle").addClass @sortUpIcon
      else
        $el.find("i").removeClass("fi-minus-circle").addClass @sortDnIcon

      # Now sort the collection
      @collection.sortCharts ns
      return
