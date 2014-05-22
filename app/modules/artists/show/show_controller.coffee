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
        # console.log artist
        artist.countPoints()
        $(document).foundation()
        artist.initializeFilters()
        if artist.length is 0
          @showEmpty()
        else
          artistsView = @getArtistsView artist
          @listenTo artistsView, "itemview:collection:init", (item, filters) ->
            _.each filters, (values, facet) ->
              _.each values, (value) ->
                artistsView.$el.find("##{facet}")
                  .append("<option value='#{value}'>#{value.toUpperCase()}</option>")
            artistsView.$el.find(".chosen-select").chosen().trigger("chosen:updated")
          @listenTo artistsView, "submit:filter", (facet, value, collection) ->
            filter = {}
            filter[facet] = value
            collections = []
            collections.push model.get "appearancesCollection" for model in collection.models
            _.each collections, (element, i, list) ->
              element.addFilter filter

          @listenTo artistsView, "remove:filter", (facet, value, collection) ->
            filter = {}
            filter[facet] = value
            collections = []
            collections.push model.get "appearancesCollection" for model in collection.models
            _.each collections, (element, i, list) ->
              element.removeFilter filter


          @show artistsView,
            region: @layout.tableRegion
            loading: true
          @showPanel(artist)
          @showTitle(artist)
          @showGraph(artist)


    showTitle: (artist) ->
      titleView = @getTitleView artist
      @listenTo titleView, "click:pop:station", (e) ->
        # console.log e.text
        App.navigate "station/#{e.text}", trigger: true
      @show titleView,
        region: @layout.titleRegion
        loading: true

    showGraph: (artist) ->
      graphView = @getGraphView artist
      @listenTo graphView, "change:graph:type", (type, slug) ->
        slug = @slug if @slug
        switch type
          when "bar"
            graphView.barGraph slug
          when "multiline"
            graphView.lineGraph slug

      App.vent.on "change:album:graph", (slug) =>
        graphView.barGraph @slug
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

    showPanel: (artist) ->
      panelView = @getPanelView artist
      @slug = ""
      @listenTo panelView, "click:albumButton", (slug) ->
        if slug is "cz_all"
          @slug = ''
          App.vent.trigger "change:album:graph"
          artist.resetFilters()
        else
          @slug = slug
          App.vent.trigger "change:album:graph", slug
          artist.resetAndAddFilter
            slug: slug

      @show panelView,
        region: @layout.panelRegion
        loading: true
      # $(document).foundation()

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
    events:
      "click #popStation" : "popStation"
    popStation: (e) ->
      @trigger "click:pop:station", e.target

  class Show.Panel extends Marionette.ItemView
    template: "modules/artists/show/templates/panel"
    events:
      "click a" : "showGraph"

    showGraph: (e) ->
      e.preventDefault()
      $(e.target).parent().parent().find('.active').removeClass("active")
      $(e.target).parent("dd").toggleClass("active")
      @trigger 'click:albumButton', e.target.id

  class Show.Graph extends Marionette.ItemView
    template: "modules/artists/show/templates/graph"
    className: 'panel'
    ui:
      "typeSelect" : "#type-select"
    events:
      "change @ui.typeSelect" : "select"
    selectOptions:
      "Appearances By Station" : "bar"
      "Appearances By Station Over Time" : "multiline"
    select: (e) ->
      nameString = @collection.url.split('/')
      nameString = nameString[3]
      # @graph("/api/artistgraph/#{nameString}")
      @trigger 'change:graph:type', @selectOptions[@ui.typeSelect.val()]

    buildBarGraph: require "modules/artists/show/barGraph"
    buildLineGraph: require "modules/artists/show/graph"

    barGraph: (slug) ->
      d3.select("svg").remove()
      @buildBarGraph(@el, @collection, slug)

    lineGraph: (slug) ->
      d3.select("svg").remove()
      @buildLineGraph(@el, @collection, slug)

    id: "graph"
    onRender: ->
      nameString = @collection.url.split('/')
      nameString = nameString[3]
      @barGraph()

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

  class Show.Appearance extends Marionette.ItemView
    template: "modules/artists/show/templates/appearance"
    tagName: "tr"

  class Show.ArtistItem extends Marionette.CompositeView
    template: "modules/artists/show/templates/artistItem"
    initialize: ->
      @collection = @model.get "appearancesCollection"


    itemView: Show.Appearance
    itemViewContainer: "tbody"
    tagName: 'div'
    events:
      "click a" : "clickStation"
      'click th' : 'clickHeader'
    clickStation: (e) ->
      e.preventDefault()
      App.navigate "station/#{e.target.text}", trigger: true

    sortUpIcon: "fi-arrow-down"
    sortDnIcon: "fi-arrow-up"

    onRender: ->
      @$el.find(".chosen-select").chosen()
      @collection.initializeFilters()
      @trigger "collection:init", @collection.getFilterLists()
      @$("th")
      .append($("<i>"))
      .closest("th")
      .find("i")
      .addClass("fi-minus-circle size-18")
      @$("[column='#{@collection.sortAttr}']")
      .find("i")
      .removeClass("fi-minus-circle")
      .addClass @sortUpIcon

      @

    clickHeader: (e) =>
      $el = $(e.currentTarget)
      ns = $el.attr("column")
      cs = @collection.sortAttr

      # Toggle sort if the current column is sorted
      if ns is cs
        @collection.sortDir *= -1
      else
        @collection.sortDir = 1

      # Adjust the indicators.  Reset everything to hide the indicator
      $("th").find("i").attr "class", "fi-minus-circle size-18"

      # Now show the correct icon on the correct column
      if @collection.sortDir is 1
        $el.find("i").removeClass("fi-minus-circle").addClass @sortUpIcon
      else
        $el.find("i").removeClass("fi-minus-circle").addClass @sortDnIcon

      # Now sort the collection
      @collection.sortCharts ns
      return

  class Show.Artist extends Marionette.CompositeView
    template: "modules/artists/show/templates/artists"
    itemView: Show.ArtistItem
    emptyView: Show.Empty
    itemViewContainer: "#theplace"
    ui:
      "position" : "#position"
      "station" : "#station"
      "week" : "#week"
    events:
      'change input' : "submit"
      'change .chosen-select' : "submit"
    submit: (e, params) ->
      if params
        if params.selected
          @trigger "submit:filter", e.target.id, params.selected, @collection
        else if params.deselected
          @trigger "remove:filter", e.target.id, params.deselected, @collection
      else
        @trigger "submit:filter", e.target.id, @ui[e.target.id].val(), @collection
