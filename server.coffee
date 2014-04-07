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
  album: String
  label: String
  points: Number
  totalPoints: Number
  currentPos: Number
  appearances: [
    appearanceSchema
    index: true
  ]


sluggify = (Text) ->
  Text.toLowerCase().replace(RegExp(" ", "g"), "-").replace /[^\w-]+/g, ""

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

# Save Slug on Save

albumSchema.pre 'save', (next) ->
  self = @
  slugText = "#{self.artist} #{self.album}"
  self.slug = sluggify slugText
  next()

# Set current position to whatever is on top of the "appearances" stack

albumSchema.post 'init', ->
  self = @
  self.currentPos = @appearances[0].position

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

# Set the Slug

albumSchema.post 'init', ->
  self = @
  slugText = "#{self.artist} #{self.album}"
  self.slug = sluggify slugText

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

  # Get every entry for a given station from the db

  app.get "/api/db/:station" , (req, res) ->
    Album.find {"appearances.station" : "#{req.params.station.toLowerCase()}"} , (err, results) ->
      console.log err if err
      if results is 0
        console.log 'no results'
        res.send results
      else
        res.send results

  # Get a given station for a given week from the db

  app.get "/api/db/:station/:date" , (req, res) ->
    newDate = moment(req.params.date)
    if newDate.get('day') != 2
      newDate.set('day', 2)
    station = req.params.station.toLowerCase()
    week = newDate.format('YYYY-MM-DD')
    Album.find { appearances: { $elemMatch : {'station' : "#{station}", 'week' : "#{week}" }}},
    { artist: 1, album: 1, label: 1, appearances: { $elemMatch : {'station' : "#{station}", 'week' : "#{week}" }}}, (err, results) ->
      console.log err if err
      if results.length is 0
        console.log 'no results'
        res.send results
      else
        res.send results

  # Get all enteries for a given artist

  app.get "/api/artists/:artist", (req, res) ->
    Album.find {"artist" : "#{req.params.artist}"}, (err, results) ->
      console.log err if err
      console.log req.params.artist
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
  console.log "getChart"
  # Check if we have a specific week. If not, grab the most recent chart

  if (week == '')
    the_url = "http://www.earshot-online.com/charts/" + station + ".cfm"
    currentDate = moment()
    if currentDate.get('day') > 2
      currentDate.set('day', 2)
    else if currentDate.get('day') < 2
      currentDate.set('day', -2)
    week = currentDate.format('YYYY-MM-DD')
  else
    the_url = "http://www.earshot-online.com/charts/" + station + ".cfm?dWeekOfID=" + week

  # Check the database for the given station and week, and return false if nothing found.

  dbQuery = ->
    d = deferred()
    console.log 'Making dbQuery'
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
              album: record.album
              label: record.label
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
