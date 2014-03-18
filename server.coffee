express = require 'express'
request = require "request"
deferred = require "deferred"
cheerio = require "cheerio"
app = express()
app.use(express.static __dirname+'/public')


exports.startServer = (port, path, callback) ->
  app.get '/', (req, res) ->
    res.sendfile './public/index.html'
  app.listen port
  console.log 'Listening on port: '+port

  app.get "/chart/:station", (req, res) ->
      newChart = getChart(req.params.station.toLowerCase(), "2014-03-11", res)
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
  the_url = "http://www.earshot-online.com/charts/" + station + ".cfm?dWeekOfID=" + week
  deferredRequest(the_url).then(chartParse).done (chart_res) ->
    res.send chart_res
    return

  return
