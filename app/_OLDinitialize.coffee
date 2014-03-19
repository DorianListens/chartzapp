###

Old Application.Coffee file

require 'lib/view_helper'


class Application extends Backbone.Marionette.Application
    initialize: =>

        @on("initialize:after", (options) =>
            Backbone.history.start();
            # Freeze the object
            Object.freeze? this
        )

        @addInitializer( (options) =>

            AppLayout = require 'views/AppLayout'
            @layout = new AppLayout()
            @layout.render()

        )

        @addInitializer((options) =>
            # Instantiate the router
            Router = require 'lib/router'
            @router = new Router()
        )

        @start()



module.exports = new Application()

###

### old router

application = require('application')
HomeView = require('views/HomeView')
HeaderView = require('views/HeaderView')
FooterView = require('views/FooterView')

module.exports = class Router extends Backbone.Router

  routes:
    '': 'home'

  home: =>
    hv = new HomeView()
    header = new HeaderView()
    footer = new FooterView()
    application.layout.header.show(header)
    application.layout.content.show(hv)
    application.layout.footer.show(footer)

Old Initialize

application = require 'application'

$ ->
  application.initialize()

###
