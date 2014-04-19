# ###

# The ChartZapp API
# Responsible for interacting with the DB,
# crawling Earshot, and returning results
#

# ###

# Require necessary components

express = require 'express'
request = require 'request'
deferred = require 'deferred'
promisify = deferred.promisify
cheerio = require 'cheerio'
moment = require 'moment'
mongo = require 'mongodb'
mongoose = require 'mongoose'
require('mongoose-middleware').initialize mongoose

# Setup Database ##################################################

mongoUri = process.env.MONGOHQ_URL || 'mongodb://localhost/chartz-db'
mongoose.connect mongoUri

db = mongoose.connection
db.on "error", console.error.bind(console, "connection error:")
db.once "open", ->
  console.log 'connected to the db'

# Define schema

appearanceSchema = mongoose.Schema
  week: String
  station: String
  position: String

albumSchema = mongoose.Schema
  slug: String
  artist: String
  artistLower:
    type: String
    index: true
  album: String
  albumLower: String
  label: String
  labelLower:
    type: String
    index: true
  points: Number
  totalPoints: Number
  currentPos: Number
  appearances: [
    appearanceSchema
    index: true
  ]

# Setup slugs and lowercases on save

albumSchema.pre 'save', (next) ->
  self = @
  self.artistLower = self.artist.toLowerCase()
  self.albumLower = self.album.toLowerCase()
  self.labelLower = self.label.toLowerCase()
  slugText = "#{self.artist} #{self.album}"
  self.slug = slugify slugText
  next()


# Recalculate "total points" on every save

albumSchema.pre 'save', (next) ->
  self = @
  if self.totalPoints is undefined
    self.totalPoints = 0
  pointSum = 0
  for appearance in @appearances
    do (appearance) ->
      pointSum += (31 - parseInt(appearance.position))
  self.totalPoints = pointSum
  next()

# Set current position to whatever is on top of the "appearances" stack

albumSchema.post 'init', ->
  self = @
  self.currentPos = @appearances[0].position

# albumSchema.post 'init', ->
#   self = @
#   self.artistLower = self.artist.toLowerCase()
#   self.albumLower = self.album.toLowerCase()
#   self.labelLower = self.label.toLowerCase()
#   self.save()
#
# Set current points on every load ###

albumSchema.post 'init', ->
  self = @
  if self.points is undefined
    self.points = 0
  pointSum = 0
  for appearance in @appearances
    do (appearance) ->
      pointSum += (31 - parseInt(appearance.position))
  self.points = pointSum

# instantiate the schema

Album = mongoose.model 'Album', albumSchema

# Instantiate the Application

app = express()
app.use(express.static __dirname+'/public')


# Export the server to Brunch

exports.startServer = (port, path, callback) ->
  # Serve the main page
  port = process.env.PORT || port
  app.listen port
  console.log 'Listening on port: '+port
  # require('./routes')(app)

# Routes #####################################################################

  app.get '/', (req, res) ->
    res.sendfile './public/index.html'

  # Get the whole DB

  app.get "/api/db/wholething", (req, res) ->
    Album.find (err, albums) ->
      console.log err if err
      res.send albums

  # Get every entry for a given station from the db, grouped by week

  app.get "/api/db/:station" , (req, res) ->
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
      if results is 0
        console.log 'no results'
        res.send results
      else
        res.send results

  # Get a given station for a given week from the db

  app.get "/api/db/:station/:date" , (req, res) ->
    station = req.params.station.toLowerCase()
    week = tuesify(req.params.date)
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
    startDate = tuesify(req.params.startDate)
    endDate = tuesify(req.params.endDate)
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

  # Get top 50 for a given station for a given date range

  app.get "/api/top/:num/:station/:startDate/:endDate", (req, res) ->
    num = parseInt req.params.num
    station = req.params.station.toLowerCase()
    startDate = tuesify(req.params.startDate)
    endDate = tuesify(req.params.endDate)
    Album.aggregate { $unwind: "$appearances" },
    { $match: { "appearances.week" : { $gte: startDate, $lte: endDate}, "appearances.station" : station }},
    { $group:
      { _id:
        {artist: "$artist"
        album: "$album"
        slug: "$slug"
        label: "$label"}
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
    startDate = tuesify(req.params.startDate)
    endDate = tuesify(req.params.endDate)
    Album.aggregate { $unwind: "$appearances" },
    { $match: { "appearances.week" : { $gte: startDate, $lte: endDate}}},
    { $group:
      { _id:
        {artist: "$artist"
        album: "$album"
        slug: "$slug"
        label: "$label"}
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
    # Album.find { artist_l: req.params.artist.toLowerCase() }, (err, results) ->
      console.log err if err
      res.send results

  # Get all entries for a given label

  app.get "/api/label/:label", (req, res) ->
    theLabel = req.params.label.toLowerCase()
    Album.find { "labelLower" : theLabel }, (err, results) ->
      console.error err if err
      res.send results

  # Get all entries for a given week, grouped by station

  app.get "/api/date/:date", (req, res) ->
    week = tuesify(req.params.date)
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
    startDate = tuesify(req.params.startDate)
    endDate = tuesify(req.params.endDate)
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


  # Get most recent chart from a given station

  app.get "/api/chart/:station", (req, res) ->
    newChart = getChart(req.params.station.toLowerCase(), "", res)

  # Get a chart from any date for a given station

  app.get "/api/chart/:station/:date", (req, res) ->
    theDate = tuesify(req.params.date)
    newChart = getChart(req.params.station.toLowerCase(), theDate, res)

# Utility Functions #######################################################

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

  # Make slugs

slugify = (Text) ->
  Text.toLowerCase().replace(RegExp(" ", "g"), "-").replace /[^\w-]+/g, ""

# Crawler ###################################################################

# Go get a chart!

getChart = (station, week, res) ->
  console.log "getChart"

  # Check if we have a specific week. If not, grab the most recent chart

  if (week == '')
    the_url = "http://www.earshot-online.com/charts/#{station}.cfm"
    week = tuesify(week)
  else
    the_url = "http://www.earshot-online.com/charts/#{station}.cfm?dWeekOfID=#{week}"

  # Check the database for the given station and week, and return false if nothing found.

  dbQuery = ->
    d = deferred()
    console.log "Making dbQuery for #{station} and #{week}"
    Album.find { appearances: { $elemMatch : {'station' : "#{station}", 'week' : "#{week}" }}},
    { totalPoints: 1, points: 1, artist: 1, album: 1, label: 1, appearances: { $elemMatch : {'station' : "#{station}", 'week' : "#{week}" }}}, (err, results) ->
      console.log err if err

    # If nothing is in the DB, make the crawl.

      if results.length is 0
        console.log "making Earshot Crawl for #{the_url}"
        deferredRequest(the_url).then(chartParse).done (chart_res) ->
          console.log 'Returned'
          if chart_res.length is 0
            res.send chart_res #"Sorry, there is no #{station} chart for #{week}"
          else
            addToDb(chart_res)
        , (err) ->
          console.log err
          res.send []
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
      if index is 1
        foundDate = $(item).find("td em strong").text().trim()
        console.log "Found date is #{foundDate}"
        newMoment = moment(foundDate, "dddd, MMMM D, YYYY")
        console.log "week is #{week}"
        theDate = newMoment.format('YYYY-MM-DD')
        if week isnt theDate
          week = theDate
          console.log "week has been updated to #{theDate}"
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
    count = 0
    console.log "adding to DB"
    for record in chart_array
      do (record) ->
        appearance =
          week: week
          station: station
          position: record.position

        Album.findOne {'artist' : "#{record.artist}", 'album' : "#{record.album}" }, (err, results) ->
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
              console.log "saved #{record.artist} - #{record.album} to the db for the first time"
              count++
              console.log count
              if count is 30
                dbQuery()
          else
            console.log "Found #{record.artist} - #{record.album} in the db"
            if results.appearances.length > 0
              alreadyAdded = false
              for appear in results.appearances
                do (appear) ->
                  if appear.week is week and appear.station is station
                    alreadyAdded = true
              if alreadyAdded isnt true
                results.appearances.push appearance
                results.save()
                console.log "Appearance added to the db"
                count++
                console.log count
                if count is 30
                  dbQuery()
              else
                console.log "Already added this appearance to the db"
                count++
                console.log count
                if count is 30
                  dbQuery()

  dbQuery()


# Heroku ENV setup #################################################

isHeroku = process.env.MONGOHQ_URL?
if isHeroku
  exports.startServer(5000)
