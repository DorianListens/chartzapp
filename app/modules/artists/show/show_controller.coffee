App = require "application"
ArtistsApp = require "modules/artists/artists_app"
Controllers = require "controllers/baseController"
# graph = require "modules/artists/show/graph"

module.exports = App.module 'ArtistsApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @opts = opts
      # graph "/api/artists/#{opts.artist}"
      artist = App.request "artist:entities", opts.artist

      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        @mainView(artist)

      @show @layout,
        loading: true

    mainView: (artist) =>
      if @opts.artist
        @showArtist(artist)
      else
        @showStart()

    showArtist: (artist) ->
      # artists = App.request 'artist:entities', search
      App.execute "when:fetched", artist, =>
        $(document).foundation()
        if artist.length is 0
          @showEmpty()
        else
          artistsView = @getArtistsView artist

          @show artistsView,
            region: @layout.tableRegion
            loading: true
          @showPanel(artist)
          @showTitle(artist)
          @showGraph(artist)


    showTitle: (artist) ->
      titleView = @getTitleView artist
      @show titleView,
        region: @layout.titleRegion
        loading: true

    showGraph: (artist) ->
      graphView = @getGraphView artist
      App.vent.on "change:album:graph", (slug) ->
        graphView.graph "/api/albumgraph/#{slug}"
      @show graphView,
        region: @layout.graphRegion
        loading: true

    showEmpty: ->
      emptyView = @getEmptyView()
      @listenTo emptyView, 'click:search', (artistVal) ->
        artistVal = encodeURIComponent(artistVal)
        App.navigate "artist/#{artistVal}", trigger: true

      @show emptyView,
        region: @layout.tableRegion

    showStart: ->
      startView = @getStartView()
      @listenTo startView, 'click:search', (artistVal) ->
        artistVal = encodeURIComponent(artistVal)
        App.navigate "artist/#{artistVal}", trigger: true

      @show startView,
        region: @layout.tableRegion

    getTitleView: (artist) ->
      new Show.Title
        collection: artist

    getGraphView: (artist) ->
      new Show.Graph
        collection: artist

    getEmptyView: ->
      new Show.EmptyView

    getArtistsView: (artists) ->
      new Show.Artist
        collection: artists

    showPanel: (artist) ->
      panelView = @getPanelView artist
      @listenTo panelView, "click:albumButton", (slug) ->
        App.vent.trigger "change:album:graph", slug

      @show panelView,
        region: @layout.panelRegion
        loading: true
      # $(document).foundation()

    getStartView: ->
      new Show.Start

    getPanelView: (artist) ->
      new Show.Panel
        collection: artist

    getLayoutView: ->
      new Show.Layout


# VIEW ######################################################################


  class Show.Layout extends Marionette.Layout
    template: "modules/artists/show/templates/show_layout"

    regions:
      titleRegion: "#title-region"
      panelRegion: "#panel-region"
      graphRegion: "#graph-region"
      tableRegion: "#table-region"

  class Show.Title extends Marionette.ItemView
    template: "modules/artists/show/templates/title"
    className: "panel"

  class Show.Panel extends Marionette.ItemView
    template: "modules/artists/show/templates/panel"
    events:
      "click a" : "showGraph"

    showGraph: (e) ->
      e.preventDefault()
      console.log e.target.id
      @trigger 'click:albumButton', e.target.id

  class Show.Graph extends Marionette.ItemView
    template: "modules/artists/show/templates/graph"
    className: 'panel'
    buildGraph: require "modules/artists/show/graph"

    graph: (url) ->
      d3.select("svg").remove()
      @buildGraph(@el, url)

    id: "graph"
    onRender: ->
      nameString = @collection.url.split('/')
      nameString = nameString[3]
      @graph("/api/artistgraph/#{nameString}")

  class Show.Empty extends Marionette.ItemView
    template: "modules/artists/show/templates/empty"

  class Show.EmptyView extends Marionette.ItemView
    template: "modules/artists/show/templates/emptyview"
    ui:
      'artistInput' : '#artist_input'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      artistVal = $.trim @ui.artistInput.val()
      @trigger 'click:search', artistVal

  class Show.Start extends Marionette.ItemView
    template: "modules/artists/show/templates/start"
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
    events:
      "click a" : "clickStation"
    clickStation: (e) ->
      e.preventDefault()
      App.navigate "station/#{e.target.text}", trigger: true

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
