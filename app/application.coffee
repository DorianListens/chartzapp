require 'lib/view_helper'


class Application extends Backbone.Marionette.Application
  initialize: =>

    @on "initialize:after", (options) =>
        Backbone.history.start();
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


    @addInitializer =>
         @module('FooterApp').start()

    # @addInitializer (options) =>
    #     # Instantiate the router
    #     Router = require 'lib/router'
    #     @router = new Router()


    @start()



module.exports = new Application()
require 'footer_app'
