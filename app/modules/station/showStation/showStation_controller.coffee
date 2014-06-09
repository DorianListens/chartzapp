App = require "application"
StationApp = require "modules/station/station_app"
Controllers = require "controllers/baseController"
colorList = require 'colorList'

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
        # console.log @stations

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
      startTitle = @getStartTitle stations

      startPanel = @getStartPanel stations
      graphView = @getGraphView stations
      @show graphView,
        region: @layout.graphRegion
        loading: true
      # graphView.map()
      @show startTitle,
        region: @layout.titleRegion
        loading: true

      @show startPanel,
        region: @layout.panelRegion
        loading: true
      startView = @getStartView stations
      @show startView,
        region: @layout.tableRegion
        loading: true
      $(".chosen-select").chosen()

      @listenTo startView, 'pick:station', (search) ->
        App.navigate "station/#{search.station}", trigger: true

      @listenTo startView, 'itemview:pick:station', (item, search) ->
        App.navigate "station/#{search}", trigger: true


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

    getStartPanel: (stations) ->
      new Show.StartPanel
        collection: stations

    getStartTitle: (stations) ->
      new Show.StartTitle
        collection: stations

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
    buildMap: require 'modules/station/showStation/stationMap'

    graph: ->
      d3.select("svg").remove()
      @buildGraph(@el, @collection, @)

    mapGraph: ->
      @buildMap(@el, @collection, @)

    id: "graph"
    initialize: ->
      @collection.on 'filter', =>
        @render()
    onRender: ->
      # console.log @collection
      if @collection.station
        @graph()
      else
        @mapGraph()



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

  class Show.StartTitle extends Marionette.ItemView
    template: "modules/station/showStation/templates/startTitle"
    onRender: ->
      @collection.on "filter", =>
        @render()

  class Show.StartPanel extends Marionette.ItemView
    template: "modules/station/showStation/templates/startPanel"
    onRender: ->
      @collection.on 'filter', =>
        @updateFilters _.last @collection.filters
      list = @collection.getFilterLists()
      _.each list, (filters, facet) =>
        _.each filters, (filter) =>
          @$el.find("##{facet}").append("""
          <option value="#{filter}">#{filter}</option>
          """)
      @$el.find(".chosen-select").chosen().trigger('chosen:updated')
    events:
      'change .chosen-select' : 'submit'
      'click #clearFilters' : 'clearFilters'
    submit: (e, params) ->
      e.preventDefault()
      filter = {}
      facet = e.target.id
      value = if params.selected then params.selected else params.deselected
      filter[facet] = value
      if params.selected then @addFilter filter else @removeFilter filter
    addFilter: (filter) ->
      @collection.addFilter filter
      # @updateFilters filter
    removeFilter: (filter) ->
      @collection.removeFilter filter
      # @updateFilters filter
    updateFilters: (filter) ->
      if filter
        filterFacet = Object.keys filter
        @$el.find("option").attr("disabled", true)
        @$el.find("option[value='#{filter[filterFacet]}']").attr("selected", true)
        newList = @collection.getUpdatedFilterLists(filterFacet)
        _.each newList, (filters, facet) =>
          _.each filters, (value) =>
            @$el.find("option[value='#{value}']").attr("disabled", false)
        @$el.find(".chosen-select").chosen().trigger('chosen:updated')
    clearFilters: (e) ->
      e.preventDefault()
      @collection.resetFilters()
      @$el.find("option").attr("disabled", false)
      @$el.find('option').attr("selected", false)
      @$el.find(".chosen-select").val('[]').trigger('chosen:updated')
    # initialize: ->




  class Show.SingleStation extends Marionette.ItemView
    template: "modules/station/showStation/templates/singleStation"
    # tagName: "li"
    events:
      "click" : "nav"
      "mouseover" : "hover"
      "mouseout" : "mouseout"
    mouseout: ->
      $(".panel").css("opacity", 1)
    hover: (e) ->
      $(".panel").css("opacity", 0.5)
      e.preventDefault()
      $(e.target).closest(".panel").css("opacity", 1)
    nav: (e) ->
      e.preventDefault()
      @trigger 'pick:station', @model.get 'name'
    onRender: ->
      color = colorList @model.get 'name'
      @$el.find('.panel').css('background', color)

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
