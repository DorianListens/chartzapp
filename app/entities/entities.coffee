App = require 'application'

# Utilities

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

potentialWeeksCount = (date1, date2) ->
  date1 = moment date1
  date2 = moment date2
  if _.isEqual(date1, date2)
    return 1
  count = 0

  while (date1 <= date2)
    count++
    date1 = moment(date1.day(9))

  return count

potentialWeeks = (date1, date2) ->
  date1 = moment date1
  date2 = moment date2
  if _.isEqual(date1, date2)
    return [date1.format("YYYY-MM-DD")]
  count = 0

  weeks = []

  while (date1 <= date2)
    weeks.push date1.format("YYYY-MM-DD")# count++
    date1 = moment(date1.day(9))

  return weeks


mode = (array) ->
  return null  if array.length is 0
  modeMap = {}
  maxCount = 1
  modes = [array[0]]
  i = 0

  while i < array.length
    el = array[i]
    unless modeMap[el]?
      modeMap[el] = 1
    else
      modeMap[el]++
    if modeMap[el] > maxCount
      modes = [el]
      maxCount = modeMap[el]
    else if modeMap[el] is maxCount
      modes.push el
      maxCount = modeMap[el]
    i++
  modes

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

  class Entities.Album extends Backbone.Model
    initialize: ->
      @getAppearances()
    getAppearances: ->
      appearances = @get "appearances"
      @set "appearancesCollection", new Entities.Appearances appearances

  class Entities.ArtistCollection extends Backbone.FacetedSearchCollection
    model: Entities.Album
    filterFacets: ["album", "label", "slug"]
    countPoints: ->
      @popAlbum = ''
      @popAlbumNumber = 0
      @totalChartScore = 0
      @totalAppearances = 0
      @stations = []
      @popStation = ''
      # console.log @models
      for model in @models
        do (model) ->
        @totalChartScore += model.get "totalPoints"
        @totalAppearances += model.attributes.appearances.length
        if model.attributes.appearances.length > @popAlbumNumber
          @popAlbum = model.get "album"
          @popAlbumNumber = model.attributes.appearances.length
        for appearance in model.attributes.appearances
          do (appearance) =>
            @stations.push appearance.station.toUpperCase()
        @popStation = mode(@stations)
      for model in @models
        do (model) =>
          model.set "totalChartScore", @totalChartScore
          model.set "totalAppearances", @totalAppearances
          model.set "popAlbum", @popAlbum
          model.set "popStation", @popStation


  class Entities.Appearance extends Backbone.Model

  class Entities.Appearances extends Backbone.FacetedSearchCollection

    model: Entities.Appearance
    filterFacets: ["station", 'position', 'week']
    sortAttr: "week"
    sortDir: -1
    sortCharts: (attr) ->
      @sortAttr = attr
      @sort()
      @trigger "reset"

    comparator: (a, b) ->
      if @sortAttr is 'position'
        a = +a.get(@sortAttr)
        b = +b.get(@sortAttr)
      else
        a = a.get(@sortAttr)
        b = b.get(@sortAttr)

      return 0 if a is b

      if @sortDir is 1
        if a > b then 1 else -1
      else
        if a > b then -1 else 1

  class Entities.StationItem extends Backbone.Model

  class Entities.SingleStation extends Backbone.Collection
    model: Entities.StationItem

  class Entities.DateItem extends Backbone.Model

  class Entities.SingleDate extends Backbone.Collection
    model: Entities.DateItem

  class Entities.Station extends Backbone.Model

  class Entities.Stations extends Backbone.FacetedSearchCollection
    model: Entities.Station
    filterFacets: ['name','province','city']
    sortAttr: "postalCode"
    sortDir: -1
    sortCharts: (attr) ->
      @sortAttr = attr
      @sort()
      @trigger "reset"

    comparator: (a, b) ->
      if @sortAttr is 'position'
        a = +a.get(@sortAttr)
        b = +b.get(@sortAttr)
      else
        a = a.get(@sortAttr)
        b = b.get(@sortAttr)

      return 0 if a is b

      if @sortDir is 1
        if a > b then 1 else -1
      else
        if a > b then -1 else 1

  class Entities.Label extends Backbone.Model

  class Entities.LabelCollection extends Backbone.FacetedSearchCollection
    model: Entities.Label
    filterFacets: ["album", "artist", "appearances"]

  class Entities.Topx extends Backbone.Model
    initialize: ->
      # info = App.request 'stations:entities', @collection.station
      @set
        info: @collection.info
        startDate: @collection.startDate
        endDate: @collection.endDate
        potential: @collection.potential
        percentage: parseInt(
          @collection.weeks.length / @collection.potential * 1000
          )
      # App.execute "when:fetched", info, ->
      #   console.log "info fetched"

  class Entities.TopxCollection extends Backbone.FacetedSearchCollection
    model: Entities.Topx
    filterFacets: ["album", "artist", "firstWeek"]
    parse: (response) ->
      weeks = []
      stations = []
      response = response.filter (v, i, a) ->
        return v if v._id.isNull is false and v._id.artist isnt ''
      totalAlbums = response.length

      for item in response
        do (item) ->
          item.artist = item._id.artist
          item.album = item._id.album
          item.label = item._id.label
          item.slug = item._id.slug
          item.isNull = item._id.isNull
          item.firstWeek = item._id.firstWeek
          theCount = 0
          item.stations = []
          for obj in item.appearances
            do (obj) ->
              points = 0
              points = 31-(parseInt obj.position)
              theCount += points
              weeks.push obj.week
              stations.push obj.station
              item.stations.push obj.station
          item.stations = _.uniq item.stations
          item.frontPoints = theCount
          item.totalAlbums = totalAlbums
      weeks.sort()
      @weeks = _.uniq weeks, true
      @stations = _.uniq stations
      for item in response
        do (item) =>
          item.totalWeeks = @weeks
          item.totalStations = @stations.length
      response = response.sort (a, b) ->
        a = +a.frontPoints
        b = +b.frontPoints
        return 0 if a is b
        if a > b then -1 else 1

      # response = response.slice(0, @number)
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
      d = moment()
      # console.log d.day()
      number = 30
      number = search.number if search.number

      topxCollection = new Entities.TopxCollection
      topxCollection.number = number
      station = search.station.toUpperCase() if search.station
      if station
        topxCollection.info = App.request "stations:entities", station
      topxCollection.station = station
      startDate =  "2014-01-01" # "#{d.yyyymmdd()}" #
      if search.startDate then startDate = search.startDate
      endDate = "#{d.format "YYYY-MM-DD"}"
      if search.endDate then endDate = search.endDate
      startDate = tuesify startDate
      endDate = tuesify endDate
      topxCollection.startDate = startDate
      topxCollection.endDate = endDate
      topxCollection.potentialA = potentialWeeks(startDate, endDate)
      topxCollection.potential = potentialWeeksCount(startDate, endDate)
      if station and startDate and endDate
        searchUrl = "/api/top/#{station}/#{startDate}/#{endDate}"
        if startDate is endDate
          desc = "#{station} Top 30 for the week of #{startDate}"
          week = startDate
        else
          desc = "Top Albums on #{station} between #{startDate} and #{endDate}"
      else
        searchUrl = "/api/topall/#{startDate}/#{endDate}"
        if startDate is endDate
          desc = "For the week of #{startDate}"
          week = startDate
        else
          desc = "For the #{topxCollection.potential} weeks between #{startDate} and #{endDate}"
      # console.log searchUrl
      topxCollection.desc = desc
      topxCollection.week = week if week
      topxCollection.url = searchUrl
      topxCollection.fetch
        reset: true
        # data:
        #   something: true
      topxCollection

    getLabel: (label) ->
      labelCollection = new Entities.LabelCollection
      label = encodeURIComponent(label)
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
      # console.log(artist) if artist
      # if artist
      artists = new Entities.ArtistCollection
      artists.artist = artist if artist
      artist = encodeURIComponent(artist) if artist
      artists.url = "/api/artists/#{if artist then artist else ''}"
      # console.log artists.url
      artists.fetch
        reset: true
      artists

    getHeaders: ->
      new Entities.HeaderCollection [
        { name: "Home", path: 'home', icon: 'fi-home' }
        { name: "Stations", path: 'station', icon: 'fi-results' }
        { name: "Artists", path: 'artist', icon: "fi-results-demographics"}
        { name: "FAQ", path: 'faq', icon: 'fi-info' }
        { name: "Twitter", path: 'http://twitter.com/chartzapp', icon: 'fi-social-twitter' }
      ]

    getCharts: (station = null, date = null) ->
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

    getStations: (station) ->
      stations = new Entities.Stations
      if station
        stations.url = "api/stations/data/#{station}"
      else
        stations.url = "api/stations/data/"
      stations.fetch
        reset: true
      stations


  App.reqres.setHandler "header:entities", ->
    API.getHeaders()

  App.reqres.setHandler "artist:entities", (artist) ->
    API.getArtist artist

  App.reqres.setHandler 'chart:entities', (station, date) ->
    API.getCharts station, date

  App.reqres.setHandler 'stations:entities', (station) ->
    API.getStations station

  App.reqres.setHandler 'station:entities', (station) ->
    API.getStation station

  App.reqres.setHandler 'date:entities', (date) ->
    API.getDate date

  App.reqres.setHandler 'label:entities', (label) ->
    API.getLabel label

  App.reqres.setHandler 'topx:entities', (search) ->
    API.getTopx search
