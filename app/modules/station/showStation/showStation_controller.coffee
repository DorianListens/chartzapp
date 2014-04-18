App = require "application"
StationApp = require "modules/station/station_app"
Controllers = require "controllers/baseController"

module.exports = App.module 'StationApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @layout = @getLayoutView()
      
      @listenTo @layout, 'show', =>
        @showPanel()
        @mainView(opts.station)

      @show @layout,
        loading: true

    mainView: (search = null) ->
      if search then @showStation(search) else @showEmpty()

    showStation: (search) ->
      station = App.request 'station:entities', search

      stationView = @getStationView station

      @show stationView,
        region: @layout.tableRegion
        loading: true
      App.execute "when:fetched", station, ->
        console.log station
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

    getStationView: (station) ->
      new Show.Station
        collection: station

    showPanel: (station) ->
      panelView = @getPanelView station
      @listenTo panelView, 'click:search', (station) =>
        @showStation station

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
    template: "modules/station/showStation/templates/show_layout"

    regions:
      panelRegion: "#panel-region"
      tableRegion: "#table-region"

  class Show.Panel extends Marionette.ItemView
    template: "modules/station/showStation/templates/panel"

    ui:
      'artistInput' : '#artist_input'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      artistVal = $.trim @ui.artistInput.val()
      @trigger 'click:search', artistVal

  class Show.ArtistItem extends Marionette.ItemView
    template: "modules/station/showStation/templates/artistItem"
    tagName: 'div'

  class Show.Empty extends Marionette.ItemView
    template: "modules/station/showStation/templates/empty"
    tagName: 'div'

  class Show.EmptyView extends Marionette.ItemView
    template: "modules/station/showStation/templates/emptyview"

  class Show.Station extends Marionette.CompositeView
    template: "modules/station/showStation/templates/artists"
    itemView: Show.ArtistItem
    emptyView: Show.Empty
    itemViewContainer: "#theplace"
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
