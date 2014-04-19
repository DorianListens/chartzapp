require 'lib/view_helper'

class Application extends Backbone.Marionette.Application

  initialize: =>

    @rootRoute = "home"

    @on "initialize:after", (options) ->

      @startHistory()
      @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()
      # Freeze the object
      Object.freeze? this

    @addRegions
      headerRegion: "#header-region"
      mainRegion: "#main-region"
      footerRegion: "#footer-region"

    @mainRegion.open = (view) ->
      @$el.hide() # fadeOut("fast")
      if view.constructor.name isnt "LoadingView"
        @$el.fadeOut("slow")
        @$el.html(view.el).css('opacity' : 0)
        @$el.show()
        @$el.fadeTo("slow", 1)
      else @$el.show()

    @reqres.setHandler "default:region", =>
      @mainRegion

    @addInitializer =>
      @module('HeaderApp').start()
      @module('FooterApp').start()

    @start()

App = new Application()

App.commands.setHandler "register:instance", (instance, id) ->
  App.register instance, id

App.commands.setHandler "unregister:instance", (instance, id) ->
  App.unregister instance, id

App.rootRoute = ''

module.exports = App

Date::yyyymmdd = ->
  yyyy = @getFullYear().toString()
  mm = (@getMonth() + 1).toString() # getMonth() is zero-based
  dd = @getDate().toString()
  yyyy + "-" + ((if mm[1] then mm else "0" + mm[0])) + "-" + ((if dd[1] then dd else "0" + dd[0]))


require 'controllers/baseController'
require 'modules/entities/entities'
require 'components/loading/loading'
require 'modules/header/header_app'
require 'modules/footer/footer_app'
require 'modules/chart/chart_app'
require 'modules/artists/artists_app'
require 'modules/station/station_app'
require 'modules/date/date_app'
require 'modules/label/label_app'
require 'modules/topx/topx_app'
require 'modules/landing/landing_app'
