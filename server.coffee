express = require 'express'
request = require "request"
deferred = require "deferred"
cheerio = require "cheerio"
moment = require 'moment'
app = express()
app.use(express.static __dirname+'/public')


exports.startServer = (port, path, callback) ->
  app.get '/', (req, res) ->
    res.sendfile './public/index.html'
  app.listen port
  console.log 'Listening on port: '+port

  app.get "/api/chart/:station", (req, res) ->
      newChart = getChart(req.params.station.toLowerCase(), "", res)
    # return

  app.get "/api/chart/:station/:date", (req, res) ->
      newDate = moment(req.params.date)
      if newDate.get('day') != 2
        newDate.set('day', 2)
      newChart = getChart(req.params.station.toLowerCase(), newDate.format('YYYY-MM-DD'), res)
  return



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

getChart = (station, week, res) ->
  chartParse = (body) ->
    $ = cheerio.load(body)
    chart_array = []
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

  if (week == '')
    the_url = "http://www.earshot-online.com/charts/" + station + ".cfm"
  else
    the_url = "http://www.earshot-online.com/charts/" + station + ".cfm?dWeekOfID=" + week
  console.log the_url
  deferredRequest(the_url).then(chartParse).done (chart_res) ->
    res.send chart_res
    return

  return
