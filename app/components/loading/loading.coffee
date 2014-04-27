App = require 'application'
Controllers = require 'controllers/baseController'

module.exports = App.module "Components.Loading",
(Loading, App, Backbone, Marionette, $, _) ->

  class Loading.LoadingController extends App.Controllers.Base

    initialize: (options) ->
      { view, config } = options

      config = if _.isBoolean(config) then {} else config

      _.defaults config,
        loadingType: "spinner"
        entities: @getEntities(view)
        debug: false

      switch config.loadingType
        when "opacity"
          @region.currentView.$el.css "opacity", 0.5
        when "spinner"
          loadingView = @getLoadingView()
          @show loadingView
        else
          throw new Error("Invalid loadingType")

      @showRealView view, loadingView, config

    showRealView: (realView, loadingView, config) ->
      App.execute "when:fetched", config.entities, =>
        switch config.loadingType
          when "opacity"
            @region.currentView.$el.removeAttr "style"
          when "spinner"
            return realView.close() if @region.currentView isnt loadingView

        ## show the real view unless we've set debug in the loading options
        @show realView unless config.debug

    getEntities: (view) ->
      ## return the entities manually set during configuration, or just pull
      ## off the model and collection from the view (if they exist)
      _.chain(view).pick("model", "collection").toArray().compact().value()

    getLoadingView: ->
      new Loading.LoadingView

  App.commands.setHandler "show:loading", (view, options) ->
    new Loading.LoadingController
      view: view
      region: options.region
      config: options.loading

  class Loading.LoadingView extends Marionette.ItemView
    template: false
    className: "loading-container small-1 small-centered columns"
    id: "loadingView"

    onShow: ->
      opts = @_getOptions()
      @spinner = new Spinner(opts)
      @spinner.spin()
      @$el.append(@spinner.el)

    onClose: ->
      $(document).foundation()
      @spinner.stop()

    _getOptions: ->
      lines: 10 # The number of lines to draw
      length: 20 # The length of each line
      width: 1 # The line thickness
      radius: 7 # The radius of the inner circle
      corners: 1 # Corner roundness (0..1)
      rotate: 9 # The rotation offset
      direction: 1 # 1: clockwise, -1: counterclockwise
      color: '#000' # #rgb or #rrggbb
      speed: 1 # Rounds per second
      trail: 60 # Afterglow percentage
      shadow: false # Whether to render a shadow
      hwaccel: false # Whether to use hardware acceleration
      className: 'spinner' # The CSS class to assign to the spinner
      zIndex: 2e9 # The z-index (defaults to 2000000000)
      #top: 50% # Top position relative to parent in px
      #left: 50% # Left position relative to parent in px
