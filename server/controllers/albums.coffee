mongoose = require 'mongoose'
Album = require '../models/album'
util = require '../util'

module.exports.controller = (app) ->

  # Get every album in the db

  app.get "/api/albums", (req, res) ->
    Album.find (err, albums) ->
      console.log err if err
      res.send albums

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
    { artist: 1, album: 1, label: 1, appearances: { $elemMatch : {'station' : "#{station}", 'week' : "#{week}" }}}, (err, results) ->
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
        isNull: "$isNull"}
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
        isNull: "$isNull"}
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

  # Get all entries for a given artist

  app.get "/api/artists/:artist", (req, res) ->
    theArtist = req.params.artist.toLowerCase()
    Album.find { "artistLower" : theArtist }, (err, results) ->
      console.error err if err
      res.send results

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

  # Get all entries for a given date range, grouped by station

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
