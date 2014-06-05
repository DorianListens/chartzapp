App = require "application"
StationApp = require "modules/station/station_app"
Controllers = require "controllers/baseController"

module.exports = App.module 'StationApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @opts = opts
      @opts.loadingType = "spinner"
      @layout = @getLayoutView()
      @initStation = App.request 'topx:entities', opts
      station = App.request 'topx:entities', opts
      @stations = App.request 'stations:entities'
      App.execute "when:fetched", @stations, =>
        @stations.initializeFilters()

      @listenTo @layout, 'show', =>

        @mainView(station)

      @show @layout,
        loading: true

    mainView: (search = null) =>
      if search.station
        @showStation search
      else
        @showStart @stations

    showRecent: (search) =>
      stationName = search
      search = {}
      search.station = stationName
      d = new Date
      search.startDate = d.yyyymmdd()
      search.endDate = search.startDate
      station = App.request 'topx:entities', search
      @showStation station

    showStation: (station) ->

      # App.execute "when:fetched", station, =>
      #   # console.log station
      #   if station.length is 0
      #     @showEmpty @stations
      #     @showTitle @initStation
          # console.log @initStation

      stationView = @getStationView station
      @showPanel()
      @showGraph station
      # if station.length is 0 then @showTitle(@initStation) else @showTitle(station)
      @showTitle station
      App.execute "when:fetched", station, =>
        if station.length is 0
          @showTitle @initStation

      @show stationView,
        region: @layout.tableRegion
        loading:
          loadingType: @opts.loadingType

      @listenTo stationView, 'click:week', (req) =>
        @opts.loadingType = "opacity"
        currentWeek = moment(req.week)
        now = moment()
        switch req.dir
          when "next"
            reqWeek = currentWeek.day(9)
            if reqWeek > now
              reqWeek = now
          when "prev"
            reqWeek = currentWeek.day(-5)
          else
            reqWeek = currentWeek
        search =
          station : @opts.station
          startDate : reqWeek.format("YYYY-MM-DD")
          endDate : reqWeek.format('YYYY-MM-DD')
        newWeek = App.request 'topx:entities', search
        @showStation newWeek


    showTitle: (station) ->
      # opts.station = "Pick a Station" unless opts.station
      # stationTitle = new App.Entities.Station opts
      titleView = @getTitleView station#stationTitle
      @show titleView,
        region: @layout.titleRegion
        loading:
          loadingType: @opts.loadingType


    showGraph: (station) ->
      graphView = @getGraphView station
      @listenTo graphView, 'click:album:circle', (d) ->
        App.navigate "/artist/#{encodeURIComponent d}", trigger: true

      @show graphView,
        region: @layout.graphRegion
        loading:
          loadingType: @opts.loadingType

    showPanel: ->
      panelView = @getPanelView()
      @show panelView,
        region: @layout.panelRegion

      @listenTo panelView, 'click:mostRecent', (station) =>
        @opts.loadingType = "opacity"
        @showRecent @opts.station
      @listenTo panelView, 'click:thisYear', (station) =>
        @opts.loadingType = "opacity"
        station = App.request "topx:entities", @opts
        @showStation station
      @listenTo panelView, 'click:other', (search) =>
        @opts.loadingType = "opacity"
        search.station = @opts.station
        station = App.request 'topx:entities', search
        @showStation station

    showEmpty: (stations) ->
      emptyView = @getEmptyView stations
      @show emptyView,
        region: @layout.tableRegion
      $(".chosen-select").chosen()

      @listenTo emptyView, 'pick:station', (search) ->
        App.navigate "station/#{search.station}", trigger: true

    showStart: (stations) ->
      startView = @getStartView stations
      @show startView,
        region: @layout.tableRegion
        loading: true
      $(".chosen-select").chosen()

      @listenTo startView, 'pick:station', (search) ->
        App.navigate "station/#{search.station}", trigger: true


    # getTopThreeView: (station) ->
    #   new Show.TopThree
    #     collection: station

    getTitleView: (station) ->
      new Show.Title
        collection: station

    getEmptyView: (stations) ->
      new Show.EmptyView
        collection: stations

    getStartView: (stations) ->
      new Show.StartView
        collection: stations

    getStationView: (station) ->
      new Show.Chart
        collection: station
        model: new App.Entities.Station station

    getPanelView: ->
      new Show.Panel

    getGraphView: (station) ->
      new Show.Graph
        collection: station

    getLayoutView: ->
      new Show.Layout


# VIEW ######################################################################


  class Show.Layout extends Marionette.Layout
    template: "modules/station/showStation/templates/show_layout"

    regions:
      titleRegion: "#title-region"
      graphRegion: "#graph-region"
      panelRegion: "#panel-region"
      topRegion: "#topthree-region"
      tableRegion: "#table-region"

  class Show.Panel extends Marionette.ItemView
    template: "modules/station/showStation/templates/panel"

    ui:
      'mostRecent' : '#mostRecent'
      'thisYear'   : '#thisYear'
      'startDate'  : '#startDate'
      'endDate'    : '#endDate'
      'range'      : '#dateRange'

    events:
      'click @ui.mostRecent' : 'mostRecent'
      'click @ui.thisYear'   : 'thisYear'

    onRender: ->
      @ui.range.dateRangePicker(
        startDate: "2014-01-01"
        endDate: moment()
        shortcuts:
          'prev' : ['week','month','year']
          'prev-days': [7, 14]
          'next-days': false
          'next' : false
        ).bind 'datepicker-change', (event, obj) =>
          search = {}
          search.startDate = obj.date1
          search.endDate = obj.date2
          @trigger 'click:other', search

    mostRecent: (e) ->
      e.preventDefault()
      @trigger 'click:mostRecent'

    thisYear: (e) ->
      e.preventDefault()
      @trigger 'click:thisYear'

    # other: (e) ->
    #   e.preventDefault()
    #   search = {}
    #   search.startDate = $.trim @ui.startDate.val()
    #   search.endDate = $.trim @ui.endDate.val()
    #   @trigger 'click:other', search

  class Show.Title extends Marionette.ItemView
    template: "modules/station/showStation/templates/title"
    # className: "panel"

  class Show.Graph extends Marionette.ItemView
    template: "modules/station/showStation/templates/graph"
    # className: 'panel'
    buildGraph: require "modules/station/showStation/stationGraph"

    graph: ->
      d3.select("svg").remove()
      @buildGraph(@el, @collection, @)

    id: "graph"
    onRender: ->
      @graph()


  # class Show.TopItem extends Marionette.ItemView
  #   template: "modules/station/showStation/templates/topItem"
  #   className: "large-4 columns top-three-item radius"
  #   attributes:
  #     "data-equalizer-watch" : ''
  #   events:
  #     'click a' : 'clickArtist'
  #
  #   clickArtist: (e) ->
  #     App.navigate "artist/#{e.target.text}", trigger: true
  #
  # class Show.TopThree extends Marionette.CompositeView
  #   template: "modules/station/showStation/templates/topthree"
  #   itemView: Show.TopItem
  #   itemViewContainer: "#topthree"
  #   className: "small-12 columns"
  #   onBeforeRender: ->
  #     @collection = @collection.clone()
  #     @collection.models = @collection.models.slice(0,3)

  class Show.Empty extends Marionette.ItemView
    template: "modules/station/showStation/templates/empty"
    tagName: 'tr'

  class Show.EmptyView extends Marionette.ItemView
    template: "modules/station/showStation/templates/emptyview"
    className: "small-12 columns"
    ui:
      'stationPicker' : '#station-select'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      search = {}
      search.station = $.trim @ui.stationPicker.val()
      @trigger 'pick:station', search

  class Show.SingleStation extends Marionette.ItemView
    template: "modules/station/showStation/templates/singleStation"
    className: "row"
    events:
      "click" : "nav"
    nav: (e) ->
      e.preventDefault()
      @trigger 'pick:station', @model.get 'name'

  class Show.StartView extends Marionette.CompositeView
    itemView: Show.SingleStation
    template: "modules/station/showStation/templates/start"
    itemViewContainer: "#stations"
    ui:
      'stationPicker' : '#station-select'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      search = {}
      search.station = $.trim @ui.stationPicker.val()
      @trigger 'pick:station', search

  class Show.ChartItem extends Marionette.ItemView
    template: "modules/station/showStation/templates/chartItem"
    tagName: 'tr'
    events:
      'click a' : 'clickArtist'
    clickArtist: (e) ->
      artist = encodeURIComponent(e.target.text)
      App.navigate "artist/#{artist}", trigger: true

  class Show.Chart extends Marionette.CompositeView
    template: "modules/station/showStation/templates/chart"
    className: "small-12 columns"
    itemView: Show.ChartItem
    emptyView: Show.Empty
    itemViewContainer: "#thechart"

    events:
      'click th' : 'clickHeader'
      'click .next' : 'clickNext'

    clickNext: (e) ->
      e.preventDefault()
      request =
        week : $(e.target).data("week")
        dir : e.target.id
      @trigger 'click:week', request

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
