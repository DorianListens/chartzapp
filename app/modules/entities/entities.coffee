App = require('application')

module.exports = App.module "Entities",
(Entities, App, Backbone, Marionette, $, _) ->


  App.commands.setHandler "when:fetched", (entities, callback) ->
    xhrs = _.chain([entities]).flatten().pluck("_fetch").value()

    $.when(xhrs...).done ->
      callback()

  class Entities.Header extends Backbone.Model

  class Entities.HeaderCollection extends Backbone.Collection
    model: Entities.Header

  class Entities.ChartItem extends Backbone.Model
    defaults:
      artist: String
      album: String
      label: String
      points: Number
      currentPos: Number
      appearances: []


  class Entities.ChartCollection extends Backbone.Collection
    model: Entities.ChartItem
    sortAttr: "points"
    sortDir: -1

    sortCharts: (attr) ->
      @sortAttr = attr
      @sort()
      @trigger "reset"

    comparator: (a, b) ->
      a = a.get(@sortAttr)
      b = b.get(@sortAttr)

      return 0 if a is b

      if @sortDir is 1
        return if a > b then 1 else -1
      else
        return if a > b then -1 else 1


  API =
    getHeaders: ->
      new Entities.HeaderCollection [
        { name: "Charts", url: '/' }
      ]

    getCharts: (station = null, date = null) ->
      console.log 'getCharts'
      console.log station
      if station is null and date is null
        console.log 'first conditional'
        chartsUrl = '/api/db/wholething'
      else if date is null and station isnt null
        console.log 'second conditional'
        chartsUrl = 'api/chart/'+station
      else
        console.log 'third conditional'
        chartsUrl = 'api/chart/'+station+'/'+date

      charts = new Entities.ChartCollection
      charts.url = chartsUrl
      charts.fetch
        reset: true
      charts


  App.reqres.setHandler "header:entities", ->
    API.getHeaders()

  App.reqres.setHandler 'chart:entities', (station, date) ->
    API.getCharts station, date
