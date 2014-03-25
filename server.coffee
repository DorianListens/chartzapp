# ###

# The ChartZapp API
# Responsible for crawling earshot-online.com and returning the requested chart as a JSON array.
#
#

# ###


# Require necessary components

express = require 'express'
request = require 'request'
deferred = require 'deferred'
cheerio = require 'cheerio'
moment = require 'moment'
mongo = require 'mongodb'
mongoose = require 'mongoose'

# Instantiate the Application

app = express()
app.use(express.static __dirname+'/public')

# Setup Database

mongoose.connect 'mongodb://localhost/chartz-db'

db = mongoose.connection
db.on "error", console.error.bind(console, "connection error:")
db.once "open", ->
  console.log 'connected to the db'

appearanceSchema = mongoose.Schema
  week: String
  station: String
  position: String

albumSchema = mongoose.Schema
  artist: String
  album: String
  label: String
  appearances: [
    appearanceSchema
    index: true
  ]

Album = mongoose.model 'Album', albumSchema


# Export the server to Brunch

exports.startServer = (port, path, callback) ->
  # Serve the main page
  port = process.env.PORT || port

# Routes #########################################

  app.get '/', (req, res) ->
    res.sendfile './public/index.html'
  app.listen port
  console.log 'Listening on port: '+port

  # Get the whole DB
  app.get "/api/wholething", (req, res) ->
    Album.find (err, albums) ->
      console.log err if err
      res.send albums

  app.get "/api/db/:station" , (req, res) ->
    Album.find {"appearances.station" : "#{req.params.station.toLowerCase()}"} , (err, results) ->
      console.log err if err
      if results is null
        console.log 'no results'
      else
        res.send results

  app.get "/api/db/:station/:date" , (req, res) ->
    newDate = moment(req.params.date)
    if newDate.get('day') != 2
      newDate.set('day', 2)
    Album.find {"appearances.station" : "#{req.params.station.toLowerCase()}", "appearances.week" : "#{newDate.format('YYYY-MM-DD')}" } , (err, results) ->
      console.log err if err
      if results is null
        console.log 'no results'
      else
        res.send results

  # Get most recent chart from a given station

  app.get "/api/chart/:station", (req, res) ->
      newChart = getChart(req.params.station.toLowerCase(), "", res)

  # Get a chart from any date for a given station

  app.get "/api/chart/:station/:date", (req, res) ->

    # Make sure the inputed date is a tuesday, and if not, fix it.

      newDate = moment(req.params.date)
      if newDate.get('day') != 2
        newDate.set('day', 2)
        theDate = newDate.format('YYYY-MM-DD')
      newChart = getChart(req.params.station.toLowerCase(), theDate, res)
  # return


# Album.find {'artistName' : 'Angel Olsen'} , (err, albums) ->
#   console.log err if err
#   console.log albums


# Set up the deferred request.

deferredRequest = (url) ->
  d = deferred()
  request url, (err, resp, body) ->
    if err
      d.reject new Error("Unable to fetch '" + url + "', reason: " + err)
      return
    if resp.statusCode isnt 200
      d.reject new Error("Unable to fetch '" + url + "', code: " + resp.statusCode)
      return
    d.resolve body
    return

  d.promise()

# Go get a chart!

getChart = (station, week, res) ->

  # Check if we have a specific week. If not, grab the most recent chart

  if (week == '')
    the_url = "http://www.earshot-online.com/charts/" + station + ".cfm"
    currentDate = moment()
    if currentDate.get('day') != 2
      currentDate.set('day', 2)
    week = currentDate.format('YYYY-MM-DD')
  else
    the_url = "http://www.earshot-online.com/charts/" + station + ".cfm?dWeekOfID=" + week

  # Check the database for the given station and week, and return false if nothing found.

  dbQuery = ->
    Album.find {"appearances.station" : "#{station}", "appearances.week" : "#{week}" } , (err, results) ->
      console.log err if err
    # If nothing is in the DB, make the crawl.

      if results.length is 0
        console.log 'making Earshot Crawl for #{the_url}'
        deferredRequest(the_url).then(chartParse).done (chart_res) ->
          console.log 'Returned'
          chart_res = addToDb(chart_res)
          res.send chart_res
          return
      else
        res.send results
        console.log "found in db #{station}"

  # Load the given url, and grab the chart table

  chartParse = (body) ->
    $ = cheerio.load(body)
    chart_array = []


    # Find the relevant table, and parse it.

    $("th").parents("table").find("tr").each (index, item) ->
      if 3 < index < 34
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
    console.log "adding to DB"
    for record in chart_array
      do (record) ->
        appearance =
          week: week
          station: station
          position: record.position

        Album.findOne {'artist' : record.artist, 'album' : record.album }, (err, results) ->
          console.log err if err
          if results is null
            newAlbum = new Album
              artist: record.artist
              album: record.album
              label: record.label
              appearances: [
                  week: week
                  station: station
                  position: record.position
                ]
            newAlbum.save (err, newAlbum) ->
              console.log err if err
              # console.log "saved #{record.artist} - #{record.album} to the db for the first time"
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
                # console.log "Appearance added to the db"
              else
                # console.log "Already added this appearance to the db"
              # console.log results.appearances

    return chart_array



isHeroku = NODE_ENV?
if isHeroku
  exports.startServer(5000)
