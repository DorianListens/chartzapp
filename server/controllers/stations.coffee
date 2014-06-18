mongoose = require 'mongoose'
Station = require '../models/station'

module.exports.controller = (app) ->
  app.get '/api/stations/data/:station?', (req, res) ->
    station = if req.params.station then req.params.station.toUpperCase() else null

    if !station
      Station.find (err, info) ->
        console.error err if err
        res.send info
    else
      Station.find { "name" : station }, (err, info) ->
        console.error err if err
        res.send info


  app.get "/server/parse/stations", (req, res) ->
    res.send "Okay, here goes the parsing!"
    Station.find (err, results) ->
      console.error err if err
      # res.send results
      parseStations(results)
