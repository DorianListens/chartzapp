require 'lib/view_helper'


class Application extends Backbone.Marionette.Application
  initialize: =>

    @rootRoute = "listchart"

    @on "initialize:after", (options) ->
      console.log 'initialize:after'

      @startHistory()
      @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()
      #@navigate(@rootRoute, trigger: true) unless @getCurrentRoute()
      # Freeze the object
      Object.freeze? this

    @addRegions
      headerRegion: "#header-region"
      mainRegion: "#main-region"
      footerRegion: "#footer-region"

    @addInitializer (options) =>

      AppLayout = require 'views/AppLayout'
      @layout = new AppLayout()
      @layout.render()

    @reqres.setHandler "default:region", =>
      @mainRegion

    @addInitializer =>
      @module('HeaderApp').start()
      @module('FooterApp').start()

    @start()

App = new Application()

# I don't understand why I have to do this. ################################

App.commands.setHandler "register:instance", (instance, id) ->
    App.register instance, id

App.commands.setHandler "unregister:instance", (instance, id) ->
    App.unregister instance, id

App.rootRoute = ''

module.exports = App

require 'controllers/baseController'
require 'modules/entities/entities'
require 'components/loading/loading'
require 'modules/header/header_app'
require 'modules/footer/footer_app'
require 'modules/chart/chart_app'
