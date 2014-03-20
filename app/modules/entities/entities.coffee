App = require('application')

module.exports = App.module "Entities", (Entities, App, Backbone, Marionette, $, _) =>

	class Entities.Header extends Backbone.Model

	class Entities.HeaderCollection extends Backbone.Collection
		model: Entities.Header

	class Entities.ChartItem extends Backbone.Model

	class Entities.ChartCollection extends Backbone.Collection
		model: Entities.ChartItem




	API =
		getHeaders: ->
			new Entities.HeaderCollection [
				{ name: "Users" }
				{ name: "Leads" }
				{ name: "Appointments" }
			]

		getCharts: (station) ->
			new Entities.ChartCollection


	App.reqres.setHandler "header:entities", ->
		API.getHeaders()

	App.reqres.setHandler 'chart:entities', (station) ->
		API.getCharts(station)
