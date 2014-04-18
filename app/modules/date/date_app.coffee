App = require 'application'

module.exports = App.module 'DateApp',
(DateApp, App, Backbone, Marionette, $, _) ->

  class DateApp.Router extends Marionette.AppRouter
    appRoutes:
      "date(/)(:date)" : "showDate"

  DateApp.startWithParent = false
  DateApp.Show = require 'modules/date/showDate/showDate_controller'

  API =
    showDate: (date) ->
      console.log "showDate"
      new DateApp.Show.Controller
        region: App.mainRegion
        date: date if date
      $(document).foundation()

  App.addInitializer ->
    new DateApp.Router
      controller: API
