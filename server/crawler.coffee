# Crawler ###################################################################

Album = require './models/album'
stationArray = require './lib/stationList'
cheerio = require 'cheerio'
moment = require 'moment'
util = require './util'
_ = require 'underscore'
deferred = require 'deferred'


module.exports.parseStations = (stations) ->
  console.log "parsing"
  _.each stations, (station, i) ->

    if station.name is "CHOQ"
      station.city = "Montreal"

    else if station.name is "CHYZ"
      station.city = "Québec"
      station.streetAddress += " Université Laval,"

    # addressLines = []
    # $ = cheerio.load(station.content)
    # # console.log $.children()
    # $(".halfColumn").first().filter((index) ->
    #   _.each this[0].children, (item, it) ->
    #     if item.type is "text"
    #       if item.data.replace(/(\r\n|\n|\r)/g, "").trim() isnt ''
    #         addressLines.push item.data.replace(/(\r\n|\n|\r)/g, "").trim()
    #   if this.type is 'tag' then return true else return
    #   )
    # # station.fullName = addressLines[0]
    # # station.streetAddress = addressLines[1]
    # station.city = addressLines[2]
    # station.postalCode = addressLines[3]
    # station.fax = addressLines[4] if addressLines[4]
    # else
    #   station.city = station.city.split(",")[0].trim()

    # station.city = station.city.trim()
    # station.province = station.province.trim()
    station.save()
    #
    #   # console.log a, i
    # console.log station.name, station.city, station.province, station.streetAddress, station.postalCode
    #

# getStations = ->
#   console.log "getStations"

  # stationParse = (body) ->
  #   $ = cheerio.load(body)
  #   found = []
  #   _.each stationArray, (station) ->
  #     content = $("a[name=#{station}]").closest(".section-box")
  #     newStation = new Station
  #       name: station
  #       content: content
  #     newStation.save (err, theStation) ->
  #       console.error err if err
  #       console.log "Saved #{station} to the DB!"
  #       console.log theStation
  #
  #   deferred found

  # stationsUrl = "http://www.earshot-online.com/stations.cfm#CKUA"
  # deferredRequest(stationsUrl).then(stationParse).done (station_response) ->
  #   console.log "response", station_response
# Go get a chart!

module.exports.getChart = (station, week, res, opts = {}) ->
  console.log "getChart"

  # Check if we have a specific week. If not, grab the most recent chart

  if (week == '')
    the_url = "http://www.earshot-online.com/charts/#{station}.cfm"
    week = util.tuesify(week)
  else
    the_url = "http://www.earshot-online.com/charts/#{station}.cfm?dWeekOfID=#{week}"

  # Check the database for the given station and week, and return false if nothing found.

  dbQuery = ->
    console.log "Making dbQuery for #{station} and #{week}"
    Album.find { appearances: { $elemMatch : {'station' : "#{station}", 'week' : "#{week}" }}},
    { totalPoints: 1, points: 1, artist: 1, album: 1, label: 1, appearances: { $elemMatch : {'station' : "#{station}", 'week' : "#{week}" }}}, (err, results) ->
      console.log err if err

    # If nothing is in the DB, make the crawl.

      if results.length is 0
        console.log "making Earshot Crawl for #{the_url}"
        util.deferredRequest(the_url).then(chartParse).done (chart_res) ->
          console.log 'Returned'
          # if chart_res.length is 0
          #   res.send chart_res #"Sorry, there is no #{station} chart for #{week}"
          # else
          addToDb(chart_res)
        , (err) ->
          console.error err
          # res.send []
          return
      else
        # res.send results
        console.log "found in db #{station}"

  # Load the given url, and grab the chart table

  chartParse = (body) ->
    $ = cheerio.load(body)
    chart_array = []

    # Find the relevant table, and parse it.

    $("th").parents("table").find("tr").each (index, item) ->
      # console.log index
      if index is 0
        foundDate = $(item).find("td em strong").first().text().trim()
        console.log "Found date is #{foundDate}"
        newMoment = moment(foundDate, "dddd, MMMM D, YYYY")
        # console.log "week is #{week}"
        theDate = newMoment.format('YYYY-MM-DD')
        if week isnt theDate
          week = theDate
          console.log "week has been updated to #{theDate}"
      if 2 < index < 34
        tds = $(item).find("td")
        chartPos = $(tds.eq(0)).text().trim()
        artist = tds.eq(2).text().trim()
        album = tds.eq(3).text().trim()
        label = tds.eq(4).text().trim()
        chart_array.push
          position: chartPos
          artist: artist
          album: album
          label: label

    deferred chart_array

  # If the chart is new, add it to the database

  addToDb = (chart_array) ->
    count = 0
    console.log "adding to DB"
    nulls = []
    newAlbums = []
    oldAlbums = []
    reCrawls = []

    unless opts.noNull
      if chart_array.length is 0
        nulls.push
          week: week
          station: station
        newAlbum = new Album
          isNull: true
          appearances: [
            week: week
            station: station
          ]
        newAlbum.save (err, newAlbum) ->
          console.error err if err
          dbQuery()
    for record in chart_array
      do (record) ->
        appearance =
          week: week
          station: station
          position: record.position

        Album.findOne {'artist' : "#{record.artist}", 'album' : "#{record.album}", 'label' : "#{record.label}" }, (err, results) ->
          console.log err if err
          if results is null
            newAlbum = new Album
              artist: record.artist
              artistLower: record.artist.toLowerCase()
              album: record.album
              albumLower: record.album.toLowerCase()
              label: record.label
              labelLower: record.label.toLowerCase()
              points: 0
              appearances: [
                  week: week
                  station: station
                  position: record.position
                ]
            newAlbum.save (err, newAlbum) ->
              console.error err if err
              newAlbums.push
                artist: record.artist
                album: record.album
              # console.log "saved #{record.artist} - #{record.album} to the db for the first time"
              count++
              # console.log count
              if count is 30
                dbQuery()
          else
            # console.log "Found #{record.artist} - #{record.album} in the db"
            if results.appearances.length > 0
              alreadyAdded = false
              for appear in results.appearances
                do (appear) ->
                  if appear.week is week and appear.station is station
                    alreadyAdded = true
              if alreadyAdded isnt true
                results.appearances.push appearance
                results.save()
                oldAlbums.push
                  artist: record.artist
                  album: record.album
                # console.log "Appearance added to the db"
                count++
                # console.log count
                if count is 30
                  dbQuery()
              else
                reCrawls.push
                  album: record.album
                  artist: record.artist
                # console.log "Already added this appearance to the db"
                count++
                # console.log count
                if count is 30
                  dbQuery()
    if count is 30
      console.log """
      Finished Crawling #{station} for #{week}
      Added #{newAlbums.length} new albums, \n
      Updated #{oldAlbums.length} old albums \n
      Made #{reCrawls.length} reCrawls
      """

  dbQuery()

module.exports.autoCrawl = (options = false) ->
  console.log "Autocrawling"
  res = {}
  newNow = moment()
  newNow = util.tuesify newNow
  newNow = moment(newNow)
  theArray = stationArray
  numStations = theArray.length
  numStations -= 1
  lastStation = theArray[numStations]
  console.log "Last one is", lastStation
  timeout = 0
  weeks = []
  weeks.push newNow
  opts = {}
  opts.noNull = true unless options
  getWeek = (day, station) ->
    setTimeout ->
      module.exports.getChart station, '', res, opts
      console.log "get #{station} for #{day.format('YYYY-MM-DD')}"
      console.log "Finished" if station is lastStation.toLowerCase()
    , timeout

  getStation = (station) ->
    for day in weeks
      do (day) ->
        timeout += 8000
        getWeek day, station

  getAll = (stations) ->
    for station in stations
      do (station) ->
        getStation station.toLowerCase()

  getAll(theArray)

module.exports.autoCrawlTrue = ->
  return module.exports.autoCrawl(true)
