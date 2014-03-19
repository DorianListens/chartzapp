# @App = ((Backbone, Marionette) ->
#
#   App = new Marionette.Application
#
#   App.addRegions
#     headerRegion: "#header-region"
#     mainRegion: "#main-region"
#     footerRegion: "#footer-region"
#
#   App.addInitializer ->
# 		App.module("HeaderApp").start()
# 		App.module("FooterApp").start()
#
#   App.on 'initialize:after', (options) ->
#     if Backbone.history
#       Backbone.history.start()
#
#   App
#
#   )(Backbone, Marionette)
#
# module.exports = @App
#
# ###
#
# Charts App Module
#
# ###
#
#
#
# @App.module 'ChartsApp', (ChartsApp, App, Backbone, Marionette, $, _) ->
#
#   class ChartsApp.Router extends Marionette.AppRouter
#     appRoutes:
#       "charts" : "listCharts"
#
#   API =
#     listCharts: ->
#       ChartsApp.List.Controller.listCharts()
#
#     clickChartItem: (id) ->
#       @$.toggleClass('clicked')
#
#   App.vent.on "click:chartItem", (chartItem) ->
#     API.clickChartItem chartItem.id
#
#   App.addInitializer ->
#     new ChartsApp.Router
#       controller: API
#
# ###
#
# ChartsApp.List Submodule
#
# ###
#
# # List Controller
#
# @App.module "ChartsApp.List", (List, App, Backbone, Marionette, $, _) ->
#
#   List.Controller =
#
#     listCharts: ->
#
#       charts = App.request 'chart:entites'
#
#       @layout = @getLayoutView()
#
#       @layout.on 'show', =>
#         @showPanel charts
#         @listCharts charts
#
#       App.mainRegion.show @layout
#
#     listCharts: (charts) ->
#       chartsView = @getChartsView charts
#       chartsView.on 'itemview:click:chartItem', (iv, chartItem) ->
#         App.vent.trigger 'click:chartItem', chartItem
#       @layout.tableRegion.show chartsView
#
#     getChartsView: (charts) ->
#       new List.Charts
#         collection: charts
#
#     showPanel: (charts) ->
#       panelView = @getPanelVIew charts
#       @layout.panelRegion.show panelView
#
#     getPanelView: (charts) ->
#       new List.Charts
#         collection: charts
#
#     getLayoutView: ->
#       new List.Layout
#
# # List View
#
# @App.module "ChartsApp.List", (List, App, Backbone, Marionette, $, _) ->
#
#   class List.Layout extends Marionette.Layout
#     template: "views/templates/list_layout"
#
#     regions:
#       panelRegion: "#panel-region"
#       asideRegion: "#aside-region"
#       tableRegion: "#table-region"
#
#   class List.Panel extends Marionette.ItemView
#     template: "views/templates/_panel"
#
#   class List.ChartItem extends Marionette.ItemView
#     template: "views/templates/_chartitem"
#     events:
#       'click' : -> @trigger 'click:chartItem', @model
#
#   class List.Charts extends Marionette.CompositeView
#     template: "views/templates/_charts"
#     itemView: List.ChartItem
#     itemViewContainer: "tbody"
#
# ###
#
# Footer Module
#
# ###
#
# @App.module "FooterApp", (FooterApp, App, Backbone, Marionette, $, _) ->
#   @startWithParent = false
#
#   API =
#     showFooter: ->
#       FooterApp.Show.Controller.showFooter()
#
#   FooterApp.on "start", ->
#     API.showFooter()
#     console.log "FooterApp start"
#
# ###
#
# # Show submodule
#
# ###
#
# # Show Controller
#
# @App.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) ->
#
#   Show.Controller =
#     showFooter: ->
#       footerView = @getFooterView()
#       App.footerRegion.show footerView
#
#     getFooterView: ->
#       new Show.Footer
#
# # Show View
#
# @App.module "FooterApp.Show", (Show, App, Backbone, Marionette, $, _) ->
#
#  class Show.Footer extends Marionette.ItemView
#    template: '/views/templates/footer'
