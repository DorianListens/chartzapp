App = require('application')

module.exports = App.module "Entities", (Entities, App, Backbone, Marionette, $, _) =>


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
		comparator: (collection) ->
			currentPos = collection.get 'currentPos'
			return currentPos

	  # comparator: (property) ->
	  #   return selectedStrategy.apply Entities.ChartItem.get(property)
		#
	  # strategies:
	  #   points: (model) ->
	  #     model.get "points"
		#
	  #   label: (model) ->
	  #     model.get "label"
		#
	  # changeSort: (sortProperty) ->
	  #   @comparator = @strategies[sortProperty]
	  #   return
		#
	  # initialize: ->
	  #   @changeSort "points"
	  #   console.log @comparator
	  #   @changeSort "label"
	  #   console.log @comparator
	  #   return
		# #


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
