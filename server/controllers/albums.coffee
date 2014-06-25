mongoose = require 'mongoose'
Album = require '../models/album'
util = require '../util'

module.exports.controller = (app) ->

  # Get every album in the db

  app.get "/api/albums", (req, res) ->
    Album.find (err, albums) ->
      console.log err if err
      res.send albums

  app.get "/api/saveall", (req, res) ->
    Album.find (err, albums) ->
      console.log err if err
      albums.forEach (album) ->
        album.save()
      res.send "Saving all albums"

  app.get "/api/save/:week", (req, res) ->
    week = req.params.week
    Album.find { appearances: { $elemMatch : {'week' : "#{week}" }}},
    { totalPoints: 1, points: 1, artist: 1, album: 1, label: 1, appearances: 1},
    (err, results) ->
      console.error err if err
      results.sort (a, b) ->
        a = a.artist
        b = b.artist
        if a is b then return 0
        if a > b then -1 else 1
      oldres = {}
      for result in results
        do (result) ->
          if (result.artist is oldres.artist) and (result.album is oldres.album) and (result.label is oldres.label)
            result.remove()
            console.log "removing #{result.artist} - #{result.album}"
          else
            result.save()
            oldres = result
      res.send "Saving all albums which appeared on #{week}"

  # Get every entry for a given station from the db, grouped by week

  app.get "/api/albums/:station" , (req, res) ->
    station = req.params.station.toLowerCase()
    Album.aggregate { $unwind: "$appearances" },
    { $match: { "appearances.station" : station}},
    { $group:
      { _id:
        {week: "$appearances.week"
        station: "$appearances.station"}
      albums:
        { $addToSet :
          {artist: "$artist"
          album: "$album"
          position: "$appearances.position"
          label: "$label"}}}},
    $sort: { "_id.week" : -1}, (err, results) ->
      console.log err if err
      res.send results

  # Get a given station for a given week from the db

  app.get "/api/albums/:station/:date" , (req, res) ->
    station = req.params.station.toLowerCase()
    week = util.tuesify(req.params.date)
    Album.find { appearances: { $elemMatch : {'station' : "#{station}", 'week' : "#{week}" }}},
    { artist: 1, album: 1, label: 1, firstWeek: 1, appearances: { $elemMatch : {'station' : "#{station}", 'week' : "#{week}" }}}, (err, results) ->
      console.log err if err
      if results.length is 0
        console.log 'no results'
        res.send results
      else
        res.send results

  # Get all charts for a given station for a given date range

  app.get "/api/station/:station/:startDate/:endDate", (req, res) ->
    station = req.params.station.toLowerCase()
    startDate = util.tuesify(req.params.startDate)
    endDate = util.tuesify(req.params.endDate)
    Album.aggregate { $unwind: "$appearances" },
    { $match: { "appearances.week" : { $gte: startDate, $lte: endDate}, "appearances.station" : station }},
    { $group:
      { _id:
        {station: "$appearances.station"
        date: "$appearances.week"}
      albums:
        { $addToSet :
          {artist: "$artist"
          album: "$album"
          position: "$appearances.position"
          label: "$label"}}}},
    { $sort: {"_id.date" : -1}},
    (err, results) ->
      res.send results

  # Get top albums for a given station for a given date range

  app.get "/api/top/:station/:startDate/:endDate", (req, res) ->
    station = req.params.station.toLowerCase()
    startDate = util.tuesify(req.params.startDate)
    endDate = util.tuesify(req.params.endDate)
    Album.aggregate { $unwind: "$appearances" },
    { $match: { "appearances.week" : { $gte: startDate, $lte: endDate}, "appearances.station" : station }},
    { $group:
      { _id:
        {artist: "$artist"
        album: "$album"
        slug: "$slug"
        label: "$label"
        isNull: "$isNull"
        firstWeek: "$firstWeek"}
      appearances:
        { $addToSet :
            {station: "$appearances.station"
            week: "$appearances.week"
            position: "$appearances.position"}}
      positions :
        { $push : "$appearances.position"}
      }},
    (err, results) ->
      console.error err if err
      res.send results

  # Get top records for all stations

  app.get "/api/topall/:startDate/:endDate", (req, res) ->
    # console.log req.query
    startDate = util.tuesify(req.params.startDate)
    endDate = util.tuesify(req.params.endDate)
    Album.aggregate { $unwind: "$appearances" },
    { $match: { "appearances.week" : { $gte: startDate, $lte: endDate}}},
    { $group:
      { _id:
        {artist: "$artist"
        album: "$album"
        slug: "$slug"
        label: "$label"
        isNull: "$isNull"
        firstWeek: "$firstWeek"}
      appearances:
        { $addToSet :
            {station: "$appearances.station"
            week: "$appearances.week"
            position: "$appearances.position"}}
      # positions :
      #   { $push : "$appearances.position"}
      }},
    (err, results) ->
      console.error err if err
      res.send results

  # Get all entries for a given artist

  app.get "/api/artists/:artist?", (req, res) ->
    if req.params.artist
      theArtist = req.params.artist.toLowerCase()
      # console.log theArtist
      Album.find { "artistLower" : theArtist }, (err, results) ->
        console.error err if err
        for result in results
          result.appearances.sort (a, b) ->
            aW = moment a.week
            bW = moment b.week
            if aW is bW
              if a.station is b.station then return 0
              if a.station > b.station then return 1 else return -1
            if aW > bW then 1 else -1
          oldap = {}
          _.each result.appearances, (ap) ->
            if (ap.week is oldap.week) and (ap.station is oldap.station) and (ap.position is oldap.position)
              console.log "found duplicate", ap.week, ap.station, ap.position, self.artist
              if ap.week is "2014-06-24"
                ap.remove()
                console.log "removing"
            else
              oldap = ap
          result.save()
        res.send results
    else
      res.send []

  # Get all entries for a given label

  app.get "/api/label/:label", (req, res) ->
    theLabel = req.params.label.toLowerCase()
    Album.find { "labelLower" : theLabel }, (err, results) ->
      console.error err if err
      res.send results

  # Get all entries for a given week, grouped by station

  app.get "/api/date/:date", (req, res) ->
    week = util.tuesify(req.params.date)
    Album.aggregate { $unwind: "$appearances" },
    { $match: { "appearances.week" : week}},
    { $group:
      { _id:
        {week: "$appearances.week"
        station: "$appearances.station"}
      albums:
        { $addToSet :
          {artist: "$artist"
          album: "$album"
          position: "$appearances.position"
          label: "$label"}}}},
    (err, results) ->
      res.send results

  # Get all charts for a given date range, grouped by station

  app.get "/api/date/:startDate/:endDate", (req, res) ->
    startDate = util.tuesify(req.params.startDate)
    endDate = util.tuesify(req.params.endDate)
    Album.aggregate { $unwind: "$appearances" },
    { $match: { "appearances.week" : { $gte: startDate, $lte: endDate}}},
    { $group:
      { _id:
        {week: "$appearances.week"
        station: "$appearances.station"}
      albums:
        { $addToSet :
          {artist: "$artist"
          album: "$album"
          position: "$appearances.position"
          label: "$label"}}}},
    (err, results) ->
      res.send results

  app.get "/api/nulls", (req, res) ->
    Album.find {isNull: true}, (err, resp) ->
      console.error err if err
      res.send resp
