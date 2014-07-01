App = require "application"
Controllers = require "controllers/baseController"

module.exports = App.module 'LandingApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @layout = @getLayoutView()
      stations = App.request "stations:entities"
      @startDate = ''
      @endDate = ''
      @request = ''
      @number = 30

      @listenTo @layout, 'show', =>
        @showChart()
        @showList(stations)
        # @showSearch(stations)

      @listenTo @layout, 'change:time', (time) =>
        search = {}
        search.request = time
        @request = time
        @showChart(search)

      @listenTo @layout, 'change:range', (time) =>
        search = {}
        search.request = 1
        @request = ''
        search.number = @number
        search.startDate = moment time.date1
        @startDate = search.startDate
        search.endDate = moment time.date2
        @endDate = search.endDate
        # console.log search
        string = "#{search.startDate.format 'YYYY-MM-DD'} - #{search.endDate.format 'YYYY-MM-DD'}"
        ga 'send', 'event', 'change:date', string
        @showChart(search)
      @listenTo @layout, 'change:number', (number) =>

        # search.request = 1
        # search.request = @request if @request
        @number = number
        topCharts.trigger "filter"
        # search.number = number
        # search.startDate = @startDate
        # search.endDate = @endDate
        # ga 'send', 'event', 'change:number', "#{search.number}"
        @showChart(number)


      @show @layout,
        loading: true
      $(document).foundation()

    showChart: (search = {}) ->
      startDate = moment()
      if startDate.day() is 2
        startDate.day(-5)
        search.endDate = startDate
      # console.log startDate
      search.startDate = startDate unless search.startDate

      topCharts = App.request 'topx:entities', search
      lCharts = topCharts.clone()


      chartView = @getChartView lCharts
      @showGraph topCharts
      @showInfo topCharts
      if search.request
        @show chartView,
          region: @layout.tableRegion
          loading:
            loadingType: "opacity"
      else
        @show chartView,
          region: @layout.tableRegion
          loading: true

      App.execute "when:fetched", topCharts, =>
        topCharts.initializeFilters()
        topCharts.sort()
        # lCharts = topCharts.clone()
        lCharts.initializeFilters()
        lCharts.set(topCharts.first(@number))
        $(document).foundation()

      topCharts.on "filter", ->
        lCharts.reset(topCharts.first(@number))
        # lCharts.sort()
      # topCharts.on "reset", ->
      #   lCharts.sort()


    showInfo: (topCharts) ->
      infoView = @getInfoView topCharts

      @listenTo infoView, 'change:range', (time) =>
        search = {}
        search.request = 1
        @request = ''
        search.number = @number
        search.startDate = moment time.date1
        @startDate = search.startDate
        search.endDate = moment time.date2
        @endDate = search.endDate
        # console.log search
        string = "#{search.startDate.format 'YYYY-MM-DD'} - #{search.endDate.format 'YYYY-MM-DD'}"
        ga 'send', 'event', 'change:date', string
        @showChart(search)

      @listenTo infoView, 'click:week', (req) =>
        # @opts.loadingType = "opacity"
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
          startDate : reqWeek.format("YYYY-MM-DD")
          endDate : reqWeek.format('YYYY-MM-DD')
        # newWeek = App.request 'topx:entities', search
        @showChart search

      @show infoView,
        region: @layout.infoRegion
        loading: true

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
      circlesView = @getCirclesView topCharts
      @listenTo graphView, 'click:album:circle', (d) ->
        App.navigate "/artist/#{encodeURIComponent d}", trigger: true
      @listenTo circlesView, 'switch:debuts', (d) ->
        topCharts.resetFilters()
        newFilters = []
        if topCharts.potentialA.length > 1
          _.each topCharts.potentialA, (week) ->
            newFilters.push
              firstWeek: week
          topCharts.addFilters newFilters
        else
          topCharts.addFilter
            firstWeek: topCharts.potentialA[0]
      @listenTo circlesView, 'switch:all', ->
        topCharts.resetFilters()

      @show graphView,
        region: @layout.graphRegion
        loading: true
      @show circlesView,
        region: @layout.circlesRegion
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

    getCirclesView: (topCharts) ->
      new Show.Circles
        collection: topCharts

    getListView: (stations) ->
      new Show.StationList
        collection: stations

    getInfoView: (topCharts) ->
      new Show.Info
        model: new Backbone.Model topCharts

    getChartView: (topCharts) ->
      new Show.Chart
        collection: topCharts


# VIEW ######################################################################


  class Show.Layout extends Marionette.Layout
    template: "modules/landing/showLanding/templates/show_layout"
    id: "landing-page"
    ui:
      "timeSelect" : "#time-select"
      "range" : "input#custom-range"
      "icon" : "i#custom-range"
      "number" : "#number"
    events:
      "change @ui.timeSelect" : "select"
      "change @ui.number" : "changeNumber"

    changeNumber: (e) ->
      @trigger 'change:number', @ui.number.val()

    select: (e) ->
      @trigger 'change:time', @ui.timeSelect.val()

    regions:
      titleRegion: "#title_region"
      blurbRegion: "#blurb_region"
      infoRegion: "#info-region"
      graphRegion: "#graph-region"
      circlesRegion: "#circles-region"
      tableRegion: "#table_region"
      listRegion: "#list_region"


  class Show.Info extends Marionette.ItemView
    template: "modules/landing/showLanding/templates/info"
    ui:
      "timeSelect" : "#time-select"
      "range" : "input#custom-range"
      "icon" : "i#custom-range"
      "number" : "#number"
      "text" : "#text"
    events:
      'click .next' : 'clickNext'

    clickNext: (e) ->
      e.preventDefault()
      request =
        week : $(e.target).data("week")
        dir : e.target.id
      @trigger 'click:week', request

    onRender: ->

      @ui.text.on "click", (e) =>
        e.stopPropagation()
        @ui.icon.click()
        # @ui.range.focus()
      @ui.icon.dateRangePicker(
        startDate: "2014-01-01"
        endDate: moment()
        batchMode: false
        shortcuts:
          'prev' : ['week','month','year']
          'prev-days': [7, 14]
          'next-days': false
          'next' : false
        ).bind 'datepicker-change', (event,obj) =>

          @trigger 'change:range', obj
          # $(@ui.icon).data("dateRangePicker").close()



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
    buildGraph: require "modules/landing/showLanding/landingGraph" #landingGraph"


    graph: ->
      # d3.select("svg").remove()
      @buildGraph(@el, @collection, @)

    id: "graph"
    initialize: ->
      @collection.on "filter", @render

    onRender: ->
      if matchMedia(Foundation.media_queries['medium']).matches
        @graph()

  class Show.Circles extends Marionette.ItemView
    template: "modules/landing/showLanding/templates/circles"
    newAlbums: require 'modules/landing/showLanding/newAlbumsGraph'
    labelsGraph: require 'modules/landing/showLanding/labelsGraph'
    reportingGraph: require 'modules/landing/showLanding/reportingGraph'
    className: "text-center"
    id: "circles"
    labels: ->
      @$el.find("#labels").find("svg").remove()
      @labelsGraph(@el, @collection, @)
    initialize: ->
      @collection.on "filter", => return @labels()

    graph: ->
      # d3.select("svg").remove()
      @newAlbums(@el, @collection, @)
      @labelsGraph(@el, @collection, @)
      @reportingGraph(@el, @collection, @)

    onRender: ->
      if matchMedia(Foundation.media_queries['medium']).matches
        @graph()


  class Show.StationList extends Marionette.ItemView
    template: "modules/landing/showLanding/templates/stationList"
    className: " small-12 columns"
    events:
      'click a' : 'clickStation'
    clickStation: (e) ->
      e.preventDefault()
      if $(e.target).hasClass("button")
        App.navigate "station/",
          trigger:true

      else
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
    initialize: ->
      # @collection.slice(0,50)

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
