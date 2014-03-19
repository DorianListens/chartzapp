App = require 'application'

module.exports = App.module("FooterApp", (FooterApp, App, Backbone, Marionette, $, _) =>

    FooterApp.startWithParent = false;

    # API =
    #   showFooter: ->
    #     FooterApp.Show.Controller.showFooter()

    FooterApp.on "start", ->
      console.log "FooterApp start"
      # API.showFooter()

)

###

# Show submodule

###

# Show Controller
#
#   @App.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) ->
#
#     Show.Controller =
#       showFooter: ->
#         footerView = @getFooterView()
#         App.footerRegion.show footerView
#
#       getFooterView: ->
#         new Show.Footer
#
#   # Show View
#
#   @App.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) ->
#
#    class Show.Footer extends Marionette.ItemView
#      template: '/views/templates/footer'
#
# )

# application = require 'application'
# # Layout = require('./views/DataEntryLayout')
#
# module.exports = application.module("DataEntry", ( mod, app, Backbone, Marionette, $, _ )=>
#
#   mod.startWithParent = false;
#
#   mod.addInitializer( (options) =>
#
#       ViewController = require './controllers/ViewController'
#       MainController = require './controllers/MainController'
#
#       mod.viewController = new ViewController()
#       mod.mainController = new MainController()
#
#       mod.layout = new Layout()
#       mod.layout.render()
#
#       # Freeze the object
#       #Object.freeze? this
#   )
#
#   mod.on("start", =>
#       mod.viewController.dispatch("load:de_home")
#   )
#
#   mod.on('render', =>
#
#   )
#
#   mod.on('before:stop', =>
#       application.model.set("userHasEditedRecord",false)
#   )
#
#   mod.addFinalizer( =>
#       mod.viewController.stopListening()
#       mod.mainController.stopListening()
#       delete mod.viewController
#       delete mod.mainController
#   )
# )
