mongoose = require 'mongoose'
Album = require '../models/album'
crawler = require '../crawler'

module.exports.controller = (app) ->

  # Autocrawler - Disabled for production release

  # app.get "/server/go-get/:station", (req, res) ->
  #   newRes = res
  #   station = req.params.station.toLowerCase()
  #   now = moment()
  #   week = now
  #   start = moment("2014-01-01")
  #   console.log "go get #{station}"
  #   numDays = week.diff(start, 'days')
  #   weeks = []
  #   newNow = moment()
  #   weeks.push newNow
  #
  #   while week.diff(start, 'days') > 0
  #     weeks.push week
  #     week = moment(week.day(-5))
  #   theLength = weeks.length
  #   theLength -= 1
  #   lastWeek = weeks[theLength]
  #   timeout = 0
  #   getWeek = (day, station) ->
  #     setTimeout ->
  #       # getChart station, day.format("YYYY-MM-DD"), newRes
  #       console.log "get #{station} for #{day.format('YYYY-MM-DD')}"
  #       console.log "Finished #{station}" if day is lastWeek
  #     , timeout
  #
  #   getStation = (station) ->
  #     for day in weeks
  #       do (day) ->
  #         timeout += 5000
  #         getWeek day, station
  #
  #   getStation station
  #
  # app.get "/server/go-get-all", (req, res) ->
  #   newRes = res
  #   res.send "here goes!"
  #   now = moment()
  #   week = now
  #   start = moment("2014-01-01")
  #   console.log "go get the whole array"
  #   numDays = week.diff(start, 'days')
  #   weeks = []
  #   newNow = moment()
  #   newNow = tuesify newNow
  #   newNow = moment(newNow)
  #   weeks.push newNow
  #
  #   while week.diff(start, 'days') > 0
  #     weeks.push week
  #     week = moment(week.day(-5))
  #   theLength = weeks.length
  #   theLength -= 1
  #   lastWeek = weeks[theLength]
  #   timeout = 0
  #   getWeek = (day, station) ->
  #     setTimeout ->
  #       getChart station, day.format("YYYY-MM-DD"), newRes
  #       console.log "get #{station} for #{day.format('YYYY-MM-DD')}"
  #       console.log "Finished #{station}" if day is lastWeek
  #     , timeout
  #
  #   getStation = (station) ->
  #     for day in weeks
  #       do (day) ->
  #         timeout += 5000
  #         getWeek day, station
  #
  #   getAll = (stations) ->
  #     for station in stations
  #       do (station) ->
  #         getStation station.toLowerCase()
  #
  #   getAll(stationArray5)

  # Get this weeks charts

  app.get "/server/go-get/:week/:noNull", (req, res) ->
    reqWeek = moment req.params.week
    reqWeek = tuesify reqWeek
    newNow = moment()
    newNow = tuesify newNow
    res.send "Geting all charts for the week of #{reqWeek}. \n Here goes!"
    newNow = moment(reqWeek)
    theArray = stationArray
    numStations = theArray.length
    numStations -= 1
    lastStation = theArray[numStations]
    console.log "Last one is", lastStation
    timeout = 0
    weeks = []
    weeks.push newNow
    opts = {}
    opts.noNull = req.params.noNull
    console.log opts
    getWeek = (day, station) ->
      setTimeout ->
        crawler.getChart station, day.format("YYYY-MM-DD"), res, opts
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

  # Get most recent chart from a given station

  app.get "/api/chart/:station", (req, res) ->
    newChart = getChart(req.params.station.toLowerCase(), "", res)

  # Get a chart from any date for a given station

  app.get "/api/chart/:station/:date", (req, res) ->
    theDate = tuesify(req.params.date)
    newChart = getChart(req.params.station.toLowerCase(), theDate, res)
