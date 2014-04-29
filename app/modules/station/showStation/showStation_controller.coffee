App = require "application"
StationApp = require "modules/station/station_app"
Controllers = require "controllers/baseController"

module.exports = App.module 'StationApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @opts = opts
      @layout = @getLayoutView()
      station = App.request 'topx:entities', opts
      @stations = App.request 'stations:entities'

      @listenTo @layout, 'show', =>

        @mainView(station)

      @show @layout,
        loading: true

    mainView: (search = null) =>
      if search.station
        @showStation(search)
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
      App.execute "when:fetched", station, =>
        if station.length is 0
          @showEmpty @stations
        else
          stationView = @getStationView station
          topThreeView = @getTopThreeView station
          @showPanel()
          @showTitle(@opts)
          @show topThreeView,
            region: @layout.topRegion
            loading: true

          @show stationView,
            region: @layout.tableRegion
            loading: true


    showTitle: (opts) ->
      opts.station = "Pick a Station" unless opts.station
      stationTitle = new App.Entities.Station opts
      titleView = @getTitleView stationTitle
      @show titleView,
        region: @layout.titleRegion
        loading: true

    showPanel: ->
      panelView = @getPanelView()
      @show panelView,
        region: @layout.panelRegion

      @listenTo panelView, 'click:mostRecent', (station) =>
        @showRecent @opts.station
      @listenTo panelView, 'click:thisYear', (station) =>
        station = App.request "topx:entities", @opts
        @showStation station
      @listenTo panelView, 'click:other', (search) =>
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
      $(".chosen-select").chosen()

      @listenTo startView, 'pick:station', (search) ->
        App.navigate "station/#{search.station}", trigger: true


    getTopThreeView: (station) ->
      new Show.TopThree
        collection: station

    getTitleView: (station) ->
      new Show.Title
        model: station

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

    getLayoutView: ->
      new Show.Layout


# VIEW ######################################################################


  class Show.Layout extends Marionette.Layout
    template: "modules/station/showStation/templates/show_layout"

    regions:
      titleRegion: "#title-region"
      panelRegion: "#panel-region"
      topRegion: "#topthree-region"
      tableRegion: "#table-region"

  class Show.Panel extends Marionette.ItemView
    template: "modules/station/showStation/templates/panel"

    ui:
      'mostRecent' : '#mostRecent'
      'thisYear'   : '#thisYear'
      'other'      : '#submitOther'
      'startDate'  : '#startDate'
      'endDate'    : '#endDate'
    events:
      'click @ui.mostRecent' : 'mostRecent'
      'click @ui.thisYear'   : 'thisYear'
      'click @ui.other'      : 'other'

    mostRecent: (e) ->
      e.preventDefault()
      @trigger 'click:mostRecent'

    thisYear: (e) ->
      e.preventDefault()
      @trigger 'click:thisYear'

    other: (e) ->
      e.preventDefault()
      search = {}
      search.startDate = $.trim @ui.startDate.val()
      search.endDate = $.trim @ui.endDate.val()
      @trigger 'click:other', search

  class Show.Title extends Marionette.ItemView
    template: "modules/station/showStation/templates/title"
    className: "panel"

  class Show.TopItem extends Marionette.ItemView
    template: "modules/station/showStation/templates/topItem"
    className: "large-4 columns top-three-item radius"
    attributes:
      "data-equalizer-watch" : ''
    events:
      'click a' : 'clickArtist'

    clickArtist: (e) ->
      App.navigate "artist/#{e.target.text}", trigger: true

  class Show.TopThree extends Marionette.CompositeView
    template: "modules/station/showStation/templates/topthree"
    itemView: Show.TopItem
    itemViewContainer: "#topthree"
    className: "small-12 columns"
    onBeforeRender: ->
      @collection = @collection.clone()
      @collection.models = @collection.models.slice(0,3)

  class Show.Empty extends Marionette.ItemView
    template: "modules/station/showStation/templates/empty"
    tagName: 'tr'

  class Show.EmptyView extends Marionette.ItemView
    template: "modules/station/showStation/templates/emptyview"
    ui:
      'stationPicker' : '#station-select'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      search = {}
      search.station = $.trim @ui.stationPicker.val()
      @trigger 'pick:station', search

  class Show.StartView extends Marionette.ItemView
    template: "modules/station/showStation/templates/start"
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
      App.navigate "artist/#{e.target.text}", trigger: true

  class Show.Chart extends Marionette.CompositeView
    template: "modules/station/showStation/templates/chart"
    className: "small-12 columns"
    itemView: Show.ChartItem
    emptyView: Show.Empty
    itemViewContainer: "#thechart"

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
