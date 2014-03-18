chartItem = require 'chartItem'

module.exports = class ChartList extends Backbone.Marionette.Collection
  tagName: 'table'
  model : chartItem
