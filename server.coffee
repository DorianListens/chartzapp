# ###

# The ChartZapp Server
# Responsible for interacting with the DB,
# crawling Earshot, and returning results
#

# ###

# Require necessary components
require 'newrelic'
express = require 'express'
moment = require 'moment'
mongo = require 'mongodb'
mongoose = require 'mongoose'
later = require 'later'
_ = require 'underscore'
fs = require 'fs'
util = require './server/util'

# Setup Database ##################################################

mongoUri = process.env.MONGOHQ_URL || 'mongodb://localhost/chartz-db'
mongoose.connect mongoUri

db = mongoose.connection
db.on "error", console.error.bind(console, "connection error:")
db.once "open", ->
  console.log 'Database Connection Open'

# Instantiate the Application

app = express()
app.use(express.static __dirname+'/public')

# Include all controllers

fs.readdirSync('./server/controllers').forEach (file) ->
  if file.substr(-7) is '.coffee'
      route = require './server/controllers/' + file
      route.controller app

crawler = require './server/crawler'

# Set up automatic crawling on tuesday night

autoCrawlTrue = ->
  return crawler.autoCrawl(true)

sched = later.parse.recur()
  .on(4).hour().on(45).minute().on(4).dayOfWeek()

later.date.UTC()

timer = later.setInterval(crawler.autoCrawl, sched)

# Export the server to Brunch

exports.startServer = (port, path, callback) ->
  # Serve the main page
  port = process.env.PORT || port
  app.listen port
  console.log 'Listening on port: '+port
  app.use(express.bodyParser())

  app.get '/', (req, res) ->
    res.sendfile './public/index.html'

# Heroku ENV setup #################################################

isHeroku = process.env.MONGOHQ_URL?
if isHeroku
  exports.startServer(5000)
