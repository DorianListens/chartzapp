App = require "application"
TopxApp = require "modules/topx/topx_app"
Controllers = require "controllers/baseController"

module.exports = App.module 'TopxApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        @showPanel()
        @mainView(opts)

      @show @layout,
        loading: true

    mainView: (search = null) ->
      if search then @showTopx(search) else @showEmpty()

    showTopx: (search) ->
      topx = App.request 'topx:entities', search

      topxView = @getTopxView topx

      @show topxView,
        region: @layout.tableRegion
        loading: true
      App.execute "when:fetched", topx, ->
        topx.sort()
        console.log topx
        $(document).foundation
          accordion:
            # active_class: 'active'
            multi_expand: true
            toggleable: true


    showEmpty: ->
      emptyView = @getEmptyView()
      @show emptyView,
        region: @layout.tableRegion

    getEmptyView: ->
      new Show.EmptyView

    getTopxView: (topx) ->
      new Show.Topx
        collection: topx

    showPanel: (topx) ->
      panelView = @getPanelView topx
      @listenTo panelView, 'click:search', (newSearch) =>
        @showTopx newSearch

      @show panelView,
        region: @layout.panelRegion
      $(document).foundation(
        accordion:
          # active_class: 'active'
          multi_expand: true
          toggleable: true
      )

    getPanelView: ->
      new Show.Panel

    getLayoutView: ->
      new Show.Layout


# VIEW ######################################################################


  class Show.Layout extends Marionette.Layout
    template: "modules/topx/showTopx/templates/show_layout"

    regions:
      panelRegion: "#panel-region"
      tableRegion: "#table-region"

  class Show.Panel extends Marionette.ItemView
    template: "modules/topx/showTopx/templates/panel"

    ui:
      'stationInput' : '#station_input'
      'numberInput' : '#number_input'
      'startDateInput' : '#startDate_input'
      'endDateInput' : '#endDate_input'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      search = {}
      search.number = $.trim @ui.numberInput.val()
      search.station = $.trim @ui.stationInput.val()
      search.startDate = $.trim @ui.startDateInput.val()
      search.endDate = $.trim @ui.endDateInput.val()
      @trigger 'click:search', search

  class Show.ArtistItem extends Marionette.ItemView
    template: "modules/topx/showTopx/templates/artistItem"
    tagName: 'div'
    initialize: ->
      @model = @model.set index: @options.index
      
  class Show.Empty extends Marionette.ItemView
    template: "modules/topx/showTopx/templates/empty"
    tagName: 'div'

  class Show.EmptyView extends Marionette.ItemView
    template: "modules/topx/showTopx/templates/emptyview"

  class Show.Topx extends Marionette.CompositeView
    template: "modules/topx/showTopx/templates/artists"
    itemView: Show.ArtistItem
    emptyView: Show.Empty
    itemViewContainer: "#theplace"
    itemViewOptions: (model) ->
      index: @collection.indexOf(model) + 1
    # initialize: ->
    #   @collection = @model.get "albums"
    # events:
    #   'click th' : 'clickHeader'
    #
    # sortUpIcon: "fi-arrow-down"
    # sortDnIcon: "fi-arrow-up"
    #
    # onRender: ->
    #   @$("th")
    #   .append($("<i>"))
    #   .closest("th")
    #   .find("i")
    #   .addClass("fi-minus-circle size-18")
    #   @$("[column='#{@collection.sortAttr}']")
    #   .find("i")
    #   .removeClass("fi-minus-circle")
    #   .addClass @sortUpIcon
    #
    #   @
    #
    # clickHeader: (e) =>
    #   $el = $(e.currentTarget)
    #   ns = $el.attr("column")
    #   cs = @collection.sortAttr
    #
    #   # Toggle sort if the current column is sorted
    #   if ns is cs
    #     @collection.sortDir *= -1
    #   else
    #     @collection.sortDir = 1
    #
    #   # Adjust the indicators.  Reset everything to hide the indicator
    #   $("th").find("i").attr "class", "fi-minus-circle size-18"
    #
    #   # Now show the correct icon on the correct column
    #   if @collection.sortDir is 1
    #     $el.find("i").removeClass("fi-minus-circle").addClass @sortUpIcon
    #   else
    #     $el.find("i").removeClass("fi-minus-circle").addClass @sortDnIcon
    #
    #   # Now sort the collection
    #   @collection.sortCharts ns
    #   return
