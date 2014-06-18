# ###

# The ChartZapp API
# Responsible for interacting with the DB,
# crawling Earshot, and returning results
#

# ###

# Require necessary components
require 'newrelic'
express = require 'express'
request = require 'request'
deferred = require 'deferred'
promisify = deferred.promisify
cheerio = require 'cheerio'
moment = require 'moment'
mongo = require 'mongodb'
mongoose = require 'mongoose'
later = require 'later'
nodemailer = require 'nodemailer'
_ = require 'underscore'

stationArray = require './stationList'


# Setup Database ##################################################

mongoUri = process.env.MONGOHQ_URL || 'mongodb://localhost/chartz-db'
mongoose.connect mongoUri

db = mongoose.connection
db.on "error", console.error.bind(console, "connection error:")
db.once "open", ->
  console.log 'connected to the db'

# Define schema
Schema = mongoose.Schema

stationSchema = new Schema
  name:
    index: true
    type: String
  content: String
  website: String
  fullName: String
  frequency: String
  email: [String]
  streetAddress: String
  city: String
  postalCode: String
  fax: String
  province: String
  totalCharts = String


appearanceSchema = new Schema
  week: String
  station: String
  position: String

albumSchema = new Schema
  slug: String
  isNull:
    type: Boolean
    default: false
  artist: String
  artistLower:
    type: String
    lowercase: true
    index: true
  album: String
  albumLower: String
  label: String
  labelLower:
    type: String
    index: true
    lowercase: true
  points: Number
  totalPoints: Number
  currentPos: Number
  appearances: [
    appearanceSchema
    index: true
  ]

# stationSchema.post 'init', ->
#   station = @name.toLowerCase()
#   self = @
#   console.log station
#   Album.aggregate { $unwind: "$appearances" },
#   { $match: { "appearances.station" : station}},
#   { $group:
#     { _id:
#       {week: "$appearances.week"
#       station: "$appearances.station"}
#     albums:
#       { $addToSet :
#         {artist: "$artist"
#         album: "$album"
#         position: "$appearances.position"
#         label: "$label"}}}},
#   $sort: { "_id.week" : -1}, (err, results) ->
#     console.log err if err
#     if results.length is 0
#       console.log 'no results'
#     else
#       count = 0
#       _.each results, (week) ->
#         count++
#         console.log week._id.week
#       console.log count
#
#       self.totalCharts = count
#       console.log self
#       self.save()



# Setup slugs and lowercases on save

albumSchema.pre 'save', (next) ->
  self = @
  self.artistLower = self.artist.toLowerCase() unless self.isNull
  self.albumLower = self.album.toLowerCase() unless self.isNull
  self.labelLower = self.label.toLowerCase() unless self.isNull
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

# albumSchema.post 'init', ->
#   self = @
#   self.currentPos = @appearances[0].position

# Set current points on every load ###

albumSchema.post 'init', ->
  self = @
  if self.points is undefined
    self.points = 0
  pointSum = 0
  for appearance in @appearances
    do (appearance) ->
      pointSum += (31 - +appearance.position)
  self.points = pointSum

# Add text search -- Not ready for production
# textSearch = require 'mongoose-text-search'
#
# albumSchema.plugin textSearch
# albumSchema.index {artist: "text", album: "text"},
# {name: "basic_search_index",
# weights:
#   artist: 5
#   album: 4}

# instantiate the schema

Album = mongoose.model 'Album', albumSchema

Station = mongoose.model 'Station', stationSchema

# Instantiate the Application

app = express()
app.use(express.static __dirname+'/public')

# Export the server to Brunch

exports.startServer = (port, path, callback) ->
  # Serve the main page
  port = process.env.PORT || port
  app.listen port
  console.log 'Listening on port: '+port
  app.use(express.bodyParser())

  # Setup Mailer
  if process.env.G_USER?
    auth =
      user: process.env.G_USER
      pass: process.env.G_PASS
  else
    gauth = require './.gauth'
    auth = gauth()
  # create reusable transport method (opens pool of SMTP connections)
  smtpTransport = nodemailer.createTransport("SMTP", auth)

  # require('./routes')(app)

# Routes #####################################################################



  # Get the whole DB

  app.get "/api/db/wholething", (req, res) ->
    Album.find (err, albums) ->
      console.log err if err
      res.send albums

  # Basic search -- Not ready for production

  # app.get "/api/search/:search", (req, res) ->
  #   Album.textSearch req.params.search, (err, albums) ->
  #     console.error err if err
  #     res.send albums

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
        getChart station, day.format("YYYY-MM-DD"), res, opts
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

  # app.get '/api/setations/data'
  app.get '/api/stations/data/:station?', (req, res) ->
    station = if req.params.station then req.params.station.toUpperCase() else null
    # console.log "requesting stations", station if station

    if !station
      Station.find (err, info) ->
        console.error err if err
        res.send info
    else
      Station.find { "name" : station }, (err, info) ->
        console.error err if err
        res.send info


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





  # Get top albums for a given station for a given date range

  app.get "/api/top/:station/:startDate/:endDate", (req, res) ->
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
    startDate = tuesify(req.params.startDate)
    endDate = tuesify(req.params.endDate)
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


  app.get "/api/nulls", (req, res) ->
    Album.find {isNull: true}, (err, resp) ->
      console.error err if err
      res.send resp

  app.post "/api/feedback", (req, res) ->

    # setup e-mail data with unicode symbols
    mailOptions =
      from: "#{req.body.name}"
      replyTo: "#{req.body.email}" # sender address
      to: "dorian.scheidt@gmail.com" # list of receivers
      subject: "Chartzapp Feedback Form" # Subject line
      text: "#{req.body.message} \n\n - #{req.body.name} - #{req.body.email}" # plaintext body

    # send mail with defined transport object
    smtpTransport.sendMail mailOptions, (error, response) ->
      console.error error if error
      console.log "Message sent: ", response.message
      res.send response

      res.end()


    # if you don't want to use this transport object anymore, uncomment following line
    # smtpTransport.close() # shut down the connection pool, no more messages

  # app.get "/server/crawl/stations", (req, res) ->
  #   res.send "Okay, crawling stations!"
  #   getStations()

  app.get "/server/parse/stations", (req, res) ->
    res.send "Okay, here goes the parsing!"
    Station.find (err, results) ->
      console.error err if err
      # res.send results
      parseStations(results)

  app.get '/canada.json', (req, res) ->
    res.sendfile './canada.json'

  app.get '/', (req, res) ->
    res.sendfile './public/index.html'

# Utility Functions #######################################################

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

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


Array::last = ->
  @[@length -1]

# Crawler ###################################################################

parseStations = (stations) ->
  console.log "parsing"
  _.each stations, (station, i) ->

    if station.name is "CHOQ"
      station.city = "Montreal"
    #   station.streetAddress = "C.P.8888, succ. Centre-Ville,"
    #   station.save()
    # if station.name is "RADL"
    # #   station.streetAddress = "75 University Ave W,"
    # #   # station.province = "ON"
    #   station.city = "Waterloo"
    # #   # station.postalCode = "N2L 3C5"
    # #   station.save()
    # else if station.name is "SCOP"
    #   station.city = "Toronto"
    # #   station.streetAddress = "55 Gould St.,"
    # #   # station.province = "ON"
    # #   # station.postalCode = "M5B 1E9"
    #
    else if station.name is "CHYZ"
      station.city = "Québec"
      station.streetAddress += " Université Laval,"
    # # #   # station.province = "QC"
    #   station.save()
    # station.save()
    # city = station.city unless station.city is undefined
    # if city
    #   cityArray = city.split(',') unless city.charAt[0] is "H"
    #   console.log cityArray
    #   station.province = cityArray[1] if cityArray[1]
    #   station.save()


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

getChart = (station, week, res, opts = {}) ->
  console.log "getChart"

  # Check if we have a specific week. If not, grab the most recent chart

  if (week == '')
    the_url = "http://www.earshot-online.com/charts/#{station}.cfm"
    week = tuesify(week)
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
        deferredRequest(the_url).then(chartParse).done (chart_res) ->
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
      if index is 1
        foundDate = $(item).find("td em strong").text().trim()
        console.log "Found date is #{foundDate}"
        newMoment = moment(foundDate, "dddd, MMMM D, YYYY")
        # console.log "week is #{week}"
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

# Set up automatic crawling on tuesdays and fridays

autoCrawl = (options = false) ->
  console.log "Autocrawling"
  res = {}
  newNow = moment()
  newNow = tuesify newNow
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
      getChart station, '', res, opts
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

autoCrawlTrue = ->
  return autoCrawl(true)

sched = later.parse.recur()
  .on(0).hour().on(13).minute().on().dayOfWeek()
#
# sched2 = later.parse.recur()
#   .on(14).hour().on(6).dayOfWeek()
#
later.date.localTime()
#
timer = later.setInterval(autoCrawl, sched)
# timer2 = later.setInterval(autoCrawlTrue, sched2)

# theNext = later.schedule(sched2).next(5)
# console.log theNext

# Heroku ENV setup #################################################

isHeroku = process.env.MONGOHQ_URL?
if isHeroku
  exports.startServer(5000)
