App = require 'application'

module.exports = App.module "Entities",
(Entities, App, Backbone, Marionette, $, _) ->

  App.commands.setHandler "when:fetched", (entities, callback) ->
    xhrs = _.chain([entities]).flatten().pluck("_fetch").value()

    $.when(xhrs...).done ->
      $(".accordion").on "click", "dd:not(.active)", (event) ->
        # $("dd.active").removeClass("active").find(".content").slideUp "slow"
        $(this).addClass("active").find(".content").slideToggle "slow"
      callback()

  class Entities.Header extends Backbone.Model

  class Entities.HeaderCollection extends Backbone.Collection
    model: Entities.Header

  class Entities.ChartItem extends Backbone.Model
    defaults:
      artist: String
      album: String
      label: String
      points: Number
      frontPoints: Number
      currentPos: Number
      appearances: []

    initialize: ->
      theCount = 0
      for obj in @get("appearances")
        do (obj) ->
          points = 0
          points = 31-(parseInt obj.position)
          theCount += points
      @set "frontPoints", theCount

  class Entities.ChartCollection extends Backbone.Collection
    model: Entities.ChartItem
    sortAttr: "points"
    sortDir: -1

    sortCharts: (attr) ->
      @sortAttr = attr
      @sort()
      @trigger "reset"

    comparator: (a, b) ->
      a = a.get(@sortAttr)
      b = b.get(@sortAttr)

      return 0 if a is b

      if @sortDir is 1
        if a > b then 1 else -1
      else
        if a > b then -1 else 1

  class Entities.ArtistItem extends Backbone.Model

  class Entities.ArtistCollection extends Backbone.Collection
    model: Entities.ArtistItem

  # class Entities.Album extends Backbone.Model
  #
  # class Entities.Albums extends Backbone.Collection
  #   model: Entities.Album

  class Entities.StationItem extends Backbone.Model
    # initialize: ->
    #   @albums = new Entities.Albums [ @albums ]


  class Entities.SingleStation extends Backbone.Collection
    model: Entities.StationItem

  class Entities.DateItem extends Backbone.Model

  class Entities.SingleDate extends Backbone.Collection
    model: Entities.DateItem

  class Entities.Station extends Backbone.Model

  class Entities.Stations extends Backbone.Collection
    model: Entities.Station

  class Entities.Label extends Backbone.Model

  class Entities.LabelCollection extends Backbone.Collection
    model: Entities.Label

  class Entities.Topx extends Backbone.Model

    initialize: ->
      theCount = 0
      for obj in @get("appearances")
        do (obj) ->
          points = 0
          points = 31-(parseInt obj.position)
          theCount += points
      @set "frontPoints", theCount



  class Entities.TopxCollection extends Backbone.Collection
    model: Entities.Topx
    sortAttr: "frontPoints"
    sortDir: -1

    sortCharts: (attr) ->
      @sortAttr = attr
      @sort()
      @trigger "reset"

    comparator: (a, b) ->
      a = a.get(@sortAttr)
      b = b.get(@sortAttr)

      return 0 if a is b

      if @sortDir is 1
        if a > b then 1 else -1
      else
        if a > b then -1 else 1

  API =
    getTopx: (search) ->
      topxCollection = new Entities.TopxCollection
      number = search.number
      station = search.station
      startDate = search.startDate
      endDate = search.endDate
      if station and startDate and endDate
        searchUrl = "/api/top/#{number}/#{station}/#{startDate}/#{endDate}"
      else
        d = new Date()
        searchUrl = "/api/top/5/ckut/2014-01-07/#{d.yyyymmdd()}"
      topxCollection.url = searchUrl
      topxCollection.fetch
        reset: true
      console.log topxCollection
      topxCollection

    getLabel: (label) ->
      labelCollection = new Entities.LabelCollection
      labelCollection.url = "/api/label/#{label}"
      labelCollection.fetch
        reset: true
      labelCollection

    getDate: (date) ->
      theDate = new Entities.SingleDate
      theDate.url = "/api/date/#{date}"
      theDate.fetch
        reset: true
      theDate

    getStation: (station) ->
      theStation = new Entities.SingleStation
      theStation.url = "/api/db/#{station}"
      theStation.fetch
        reset: true
      theStation

    getArtist: (artist) ->
      artists = new Entities.ArtistCollection
      artists.url = "/api/artists/#{artist}"
      artists.fetch
        reset: true
      artists

    getHeaders: ->
      new Entities.HeaderCollection [
        { name: "Charts", path: 'chart' }
        { name: "Top 50", path: 'topx'}
        { name: "Artists", path: 'artist' }
        { name: "Stations", path: 'station' }
        { name: "Date", path: 'date' }
        { name: "Label", path: "label"}
      ]

    getCharts: (station = null, date = null) ->
      console.log 'getCharts'
      console.log station
      console.log date
      if station is null and date is null
        chartsUrl = '/api/db/wholething'
      else if date is null and station isnt null
        chartsUrl = 'api/chart/'+station
      else
        chartsUrl = 'api/chart/'+station+'/'+date

      charts = new Entities.ChartCollection
      charts.url = chartsUrl
      charts.fetch
        reset: true
      charts

    getStations: ->
      new Entities.Stations [
        {name:'CAPR'}
        {name:'CFBU'}
        {name:'CFBX'}
        {name:'CFCR'}
        {name:'CFMH'}
        {name:'CFMU'}
        {name:'CFOU'}
        {name:'CFRC'}
        {name:'CFRE'}
        {name:'CFRO'}
        {name:'CFRU'}
        {name:'CFUR'}
        {name:'CFUV'}
        {name:'CFXU'}
        {name:'CHLY'}
        {name:'CHMA'}
        {name:'CHMR'}
        {name:'CHOQ'}
        {name:'CHRW'}
        {name:'CHRY'}
        {name:'CHSR'}
        {name:'CHUO'}
        {name:'CHYZ'}
        {name:'CICK'}
        {name:'CILU'}
        {name:'CIOI'}
        {name:'CISM'}
        {name:'CITR'}
        {name:'CIUT'}
        {name:'CIVL'}
        {name:'CJAM'}
        {name:'CJLO'}
        {name:'CJLY'}
        {name:'CJMQ'}
        {name:'CJSF'}
        {name:'CJSR'}
        {name:'CJSW'}
        {name:'CJUM'}
        {name:'CKCU'}
        {name:'CKDU'}
        {name:'CKLU'}
        {name:'CKMS'}
        {name:'CKUA'}
        {name:'CKUT'}
        {name:'CKUW'}
        {name:'CKXU'}
        {name:'CSCR'}
        {name:'RADL'}
        {name:'SCOP'}
      ]


  App.reqres.setHandler "header:entities", ->
    API.getHeaders()

  App.reqres.setHandler "artist:entities", (artist) ->
    API.getArtist artist

  App.reqres.setHandler 'chart:entities', (station, date) ->
    API.getCharts station, date

  App.reqres.setHandler 'stations:entities', ->
    API.getStations()

  App.reqres.setHandler 'station:entities', (station) ->
    API.getStation station

  App.reqres.setHandler 'date:entities', (date) ->
    API.getDate date

  App.reqres.setHandler 'label:entities', (label) ->
    API.getLabel label

  App.reqres.setHandler 'topx:entities', (search) ->
    API.getTopx search
