# ###

# The ChartZapp API
# Responsible for crawling earshot-online.com and returning the requested chart as a JSON array.
#
#

# ###


# Require necessary components

express = require 'express'
request = require "request"
deferred = require "deferred"
cheerio = require "cheerio"
moment = require 'moment'

# Instantiate the Application

app = express()
app.use(express.static __dirname+'/public')


# Export the server to Brunch

exports.startServer = (port, path, callback) ->
  # Serve the main page
  port = process.env.PORT || port
  
  app.get '/', (req, res) ->
    res.sendfile './public/index.html'
  app.listen port
  console.log 'Listening on port: '+port

  # Get most recent chart from a given station

  app.get "/api/chart/:station", (req, res) ->
      newChart = getChart(req.params.station.toLowerCase(), "", res)

  # Get a chart from any date for a given station

  app.get "/api/chart/:station/:date", (req, res) ->

    # Make sure the inputed date is a tuesday, and if not, fix it.

      newDate = moment(req.params.date)
      if newDate.get('day') != 2
        newDate.set('day', 2)
      newChart = getChart(req.params.station.toLowerCase(), newDate.format('YYYY-MM-DD'), res)
  return

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
  chartParse = (body) ->
    $ = cheerio.load(body)
    chart_array = []

    # Find the relevant table, and parse it.

    $("th").parents("table").find("tr").each (index, item) ->
      if index > 3 and index < 34
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

      return

    deferred chart_array

  # Check if we have a specific week. If not, grab the most recent chart

  if (week == '')
    the_url = "http://www.earshot-online.com/charts/" + station + ".cfm"
  else
    the_url = "http://www.earshot-online.com/charts/" + station + ".cfm?dWeekOfID=" + week
  console.log the_url

  #Make the request

  deferredRequest(the_url).then(chartParse).done (chart_res) ->
    console.log 'Returned'
    res.send chart_res
    return

  return


# isHeroku = process.env.PROD?
# if isHeroku
exports.startServer(5000)
