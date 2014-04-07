App = require "application"
ArtistsApp = require "modules/artists/artists_app"
Controllers = require "controllers/baseController"

module.exports = App.module 'ArtistsApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->

      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        @showPanel()
        @mainView()

      @show @layout,
        loading: true

    mainView: (search = null) ->
      if search then @showArtist(search) else @showEmpty()

    showArtist: (search) ->
      artists = App.request 'artist:entities', search

      artistsView = @getArtistsView artists

      @show artistsView,
        region: @layout.tableRegion
        loading: true

    showEmpty: ->
      emptyView = @getEmptyView()
      @show emptyView,
        region: @layout.tableRegion

    getEmptyView: ->
      new Show.EmptyView

    getArtistsView: (artists) ->
      new Show.Artist
        collection: artists

    showPanel: (artist) ->
      panelView = @getPanelView artist
      @listenTo panelView, 'click:search', (artist) =>
        @showArtist artist

      @show panelView,
        region: @layout.panelRegion
      $(document).foundation()

    getPanelView: ->
      new Show.Panel

    getLayoutView: ->
      new Show.Layout


# VIEW ######################################################################


  class Show.Layout extends Marionette.Layout
    template: "modules/artists/show/templates/show_layout"

    regions:
      panelRegion: "#panel-region"
      tableRegion: "#table-region"

  class Show.Panel extends Marionette.ItemView
    template: "modules/artists/show/templates/panel"

    ui:
      'artistInput' : '#artist_input'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      artistVal = $.trim @ui.artistInput.val()
      @trigger 'click:search', artistVal

  class Show.ArtistItem extends Marionette.ItemView
    template: "modules/artists/show/templates/artistItem"
    tagName: 'div'

  class Show.Empty extends Marionette.ItemView
    template: "modules/artists/show/templates/empty"
    tagName: 'div'

  class Show.EmptyView extends Marionette.ItemView
    template: "modules/artists/show/templates/emptyview"

  class Show.Artist extends Marionette.CompositeView
    template: "modules/artists/show/templates/artists"
    itemView: Show.ArtistItem
    emptyView: Show.Empty
    itemViewContainer: "#theplace"
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
