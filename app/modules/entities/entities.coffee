App = require 'application'

# Make tuesdays

tuesify = (date) ->
  theWeek = switch
    when date then moment(date)
    else moment()
  theDay = theWeek.get('day')
  theTues = switch
    when theDay is 0 then theWeek.day(-5)
    when theDay is 1 then theWeek.day(-5)
    when theDay is 2 then theWeek
    when theDay > 2 then theWeek.day(2)
  theTues = moment(theTues)
  theTues.format('YYYY-MM-DD')

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

    initialize: ->
      theCount = 0
      @set "rank", @get "currentPos"
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

  class Entities.TopxCollection extends Backbone.Collection
    model: Entities.Topx
    parse: (response) ->
      for item in response
        do (item) ->
          item.artist = item._id.artist
          item.album = item._id.album
          item.label = item._id.label
          item.slug = item._id.slug
          item.isNull = item._id.isNull
          theCount = 0
          for obj in item.appearances
            do (obj) ->
              points = 0
              points = 31-(parseInt obj.position)
              theCount += points
          item.frontPoints = theCount
      response = response.sort (a, b) ->
        a = parseInt a.frontPoints
        b = parseInt b.frontPoints
        return 0 if a is b
        if a > b then -1 else 1

      response = response.slice(0, 50)
      for item in response
        do (item) ->
          item.rank = response.indexOf(item) + 1
      response

    sortAttr: "rank"
    sortDir: 1

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
      d = new Date()
      topxCollection = new Entities.TopxCollection
      station = search.station
      topxCollection.station = station
      startDate = "2014-01-01"
      if search.startDate then startDate = search.startDate
      endDate = "#{d.yyyymmdd()}"
      if search.endDate then endDate = search.endDate
      startDate = tuesify startDate
      endDate = tuesify endDate
      if station and startDate and endDate
        searchUrl = "/api/top/#{station}/#{startDate}/#{endDate}"
        if startDate is endDate
          desc = "#{station} Top 30 for the week of #{startDate}"
        else
          desc = "Top Albums on #{station} between #{startDate} and #{endDate}"
      else
        searchUrl = "/api/topall/2014-01-01/#{d.yyyymmdd()}"
        desc = "Top Albums between 2014-01-01 and #{d.yyyymmdd()}"
      # console.log searchUrl
      topxCollection.desc = desc
      topxCollection.url = searchUrl
      topxCollection.fetch
        reset: true
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
        { name: "Home", path: 'home', icon: 'fi-home' }
        # { name: "Charts", path: 'chart' }
        # { name: "Top 50", path: 'topx'}
        { name: "Artists", path: 'artist', icon: "fi-music"}
        { name: "Stations", path: 'station', icon: 'fi-align-left' }
        # { name: "Date", path: 'date' }
        # { name: "Label", path: "label"}
      ]

    getCharts: (station = null, date = null) ->
      # console.log 'getCharts'
      # console.log station
      # console.log date
      date = tuesify date if date
      if station is null and date is null
        chartsUrl = '/api/db/wholething'
        desc = "Full Database"
      else if date is null and station isnt null
        chartsUrl = '/api/chart/'+station
        desc = "Most recent #{station} chart"
      else
        chartsUrl = '/api/chart/'+station+'/'+date
        desc = "#{station} Top 30 for the week of #{date}"

      charts = new Entities.ChartCollection
      charts.desc = desc
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
