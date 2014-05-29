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
        # @showSearch(stations)

      @listenTo @layout, 'change:time', (time) =>
        search = {}
        search.request = time
        @showChart(search)

      @listenTo @layout, 'change:range', (time) =>
        search = {}
        search.request = 1
        search.startDate = time.date1
        search.endDate = time.date2
        @showChart(search)

      @show @layout,
        loading: true
      $(document).foundation()

    showChart: (search = {}) ->

      topCharts = App.request 'topx:entities', search

      chartView = @getChartView topCharts
      @showGraph topCharts
      if search.request
        @show chartView,
          region: @layout.tableRegion
          loading:
            loadingType: "opacity"
      else
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
      searchView = @getSearchView stations
      @listenTo searchView, 'click:search', (newSearch) ->
        switch newSearch.kind
          when "artist"
            App.navigate "/artist/#{newSearch.keyword}", trigger: true
          when "station"
            App.navigate "/station/#{newSearch.keyword}", trigger: true

      @show searchView,
        region: @layout.searchRegion
        loading: true
      $(document).foundation()
      # $(".chosen-select").chosen()

    showGraph: (topCharts) ->
      graphView = @getGraphView topCharts
      @listenTo graphView, 'click:album:circle', (d) ->
        App.navigate "/artist/#{encodeURIComponent d}", trigger: true
      @show graphView,
        region: @layout.graphRegion
        loading: true

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

    getGraphView: (topCharts) ->
      new Show.Graph
        collection: topCharts

    getListView: (stations) ->
      new Show.StationList
        collection: stations


# VIEW ######################################################################


  class Show.Layout extends Marionette.Layout
    template: "modules/landing/showLanding/templates/show_layout"
    id: "landing-page"
    ui:
      "timeSelect" : "#time-select"
      "range" : "#custom-range"
    events:
      "change @ui.timeSelect" : "select"
    select: (e) ->
      @trigger 'change:time', @ui.timeSelect.val()

    regions:
      titleRegion: "#title_region"
      blurbRegion: "#blurb_region"
      searchRegion: "#search_region"
      graphRegion: "#graph-region"
      tableRegion: "#table_region"
      listRegion: "#list_region"

    onRender: ->
      @ui.range.dateRangePicker(
        startDate: "2014-01-01"
        endDate: moment()
        shortcuts:
          'prev' : ['week','month','year']
          'prev-days': [7, 14]
          'next-days': false
          'next' : false
        ).bind 'datepicker-change', (event,obj) =>
          console.log "datepicker-change"
          @trigger 'change:range', obj


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

  class Show.Graph extends Marionette.ItemView
    template: "modules/landing/showLanding/templates/graph"
    # className: 'panel'
    buildGraph: require "modules/landing/showLanding/landingGraph"

    graph: ->
      d3.select("svg").remove()
      @buildGraph(@el, @collection, @)

    id: "graph"
    onRender: ->
      @graph()

  class Show.StationList extends Marionette.ItemView
    template: "modules/landing/showLanding/templates/stationList"
    className: " small-12 columns"
    events:
      'click a' : 'clickStation'
    clickStation: (e) ->
      e.preventDefault()
      App.navigate "station/#{e.target.text}",
        trigger:true

  class Show.ChartItem extends Marionette.ItemView
    template: "modules/landing/showLanding/templates/chartItem"
    tagName: 'tr'
    initialize: ->
      @model = @model.set index: @options.index
    events:
      'click a' : 'clickItem'
    clickItem: (e) ->
      e.preventDefault()
      artist = encodeURIComponent(e.target.text)
      App.navigate "artist/#{artist}",
        trigger: true

  class Show.Empty extends Marionette.ItemView
    template: "modules/landing/showLanding/templates/empty"
    tagName: 'tr'

  class Show.Chart extends Marionette.CompositeView
    template: "modules/landing/showLanding/templates/chart"
    itemView: Show.ChartItem
    emptyView: Show.Empty
    className: "small-12 columns"
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
