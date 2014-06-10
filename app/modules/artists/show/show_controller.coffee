App = require "application"
ArtistsApp = require "modules/artists/artists_app"
Controllers = require "controllers/baseController"
# graph = require "modules/artists/show/graph"

module.exports = App.module 'ArtistsApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @opts = opts
      artist = App.request "artist:entities", opts.artist

      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        @mainView(artist)

      @show @layout,
        region: App.mainRegion
        loading: false


    mainView: (artist) =>
      if @opts.artist
        @showArtist(artist)
      else
        @showStart()

    showArtist: (artist) ->
      # artists = App.request 'artist:entities', search
      App.execute "when:fetched", artist, =>
        # console.log artist
        # artist.countPoints()
        $(document).foundation()
        # artist.initializeFilters()
        if artist.length is 0
          @showEmpty()
        # else
      artistsView = @getArtistsView artist
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
      @listenTo graphView, 'click:station:item', (station) ->
        station = encodeURIComponent(station)
        App.navigate "station/#{station}", trigger: true
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
          # App.vent.trigger "change:album:graph"
          artist.resetFilters()
        else
          @slug = slug
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
    # className: "panel"
    events:
      "click #popStation" : "popStation"
    popStation: (e) ->
      @trigger "click:pop:station", e.target

  class Show.Panel extends Marionette.ItemView
    template: "modules/artists/show/templates/panel"
    className: ""
    events:
      "click a.albumlink" : "showGraph"
      "click a.button" : "showFilters"

    showGraph: (e) ->
      e.preventDefault()
      $(e.target).parent().parent().find('.active').removeClass("active")
      $(e.target).parent("dd").toggleClass("active")
      @trigger 'click:albumButton', e.target.id

    showFilters: (e) ->
      e.preventDefault()
      if $("#filters").hasClass("hide")
        $("#filters").slideDown().toggleClass("hide")
        $(e.target).text("Hide Filters")
      else
        $("#filters").slideUp().toggleClass("hide")
        $(e.target).text("Show Filters")

  class Show.Graph extends Marionette.ItemView
    template: "modules/artists/show/templates/graph"
    ui:
      "typeSelect" : "#type-select"
    events:
      "change @ui.typeSelect" : "select"
    selectOptions:
      "Appearances By Station" : "bar"
      "Appearances By Station Over Time" : "line"
    select: (e) ->
      e.preventDefault()
      @graphType = @ui.typeSelect.val()
      @graph(@graphType)

    buildGraph: require "modules/artists/show/graph"

    graphType: "bar"

    graph: (type) ->
      d3.select("svg").remove()
      @buildGraph(@el, @collection, type, @)

    id: "graph"

    collections: []

    initialize: ->
      App.execute "when:fetched", @collection, =>
        _.each @collection.models, (model) =>
          @collections.push model.get "appearancesCollection"
        _.each @collections, (appearances) =>
          @listenTo appearances, "filter", =>
            # console.log "appearances filter"
            @render()
        @listenTo @collection, "filter", =>
          # console.log "collection filter"
          @render()

    onRender: ->
      if matchMedia(Foundation.media_queries['medium']).matches
        @ui.typeSelect
          .find("option[value='#{@graphType}']").attr("selected", true)
        @graph(@graphType)

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

  class Show.Album extends Marionette.CompositeView
    template: "modules/artists/show/templates/artistItem"
    initialize: ->
      @collection = @model.get "appearancesCollection"
      # console.log @collection
      # @collection.initializeFilters()
      # @collection.resetFilters()


    itemView: Show.Appearance
    itemViewContainer: "tbody"
    tagName: 'div'
    events:
      "click a" : "clickStation"
      'click th' : 'clickHeader'
    clickStation: (e) ->
      e.preventDefault()
      App.navigate "station/#{encodeURIComponent e.target.text}", trigger: true

    sortUpIcon: "fi-arrow-down"
    sortDnIcon: "fi-arrow-up"

    onRender: ->
      @$el.find(".chosen-select").chosen()
      # console.log @collection.getFilterLists()
      @$("[column]")
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
    itemView: Show.Album
    emptyView: Show.Empty
    itemViewContainer: "#theplace"
    ui:
      "position" : "#position"
      "station" : "#station"
      "week" : "#week"
      "clear" : "#clearFilters"

    events:
      'change input' : "submit"
      'change .chosen-select' : "submit"
      "click @ui.clear" : "clearFilters"

    collections: []
    initialize: ->
      @filters = []
      @bigList = {}

      subCollection = "appearancesCollection"

      App.execute "when:fetched", @collection, =>
        @collection.countPoints()
        $(document).foundation()
        @collection.initializeFilters()
        @collections.push model.get subCollection for model in @collection.models

        _.each @collections, (collection, i) =>
          collection.initializeFilters()
          @filters[i] = collection.getFilterLists()

    onRender: ->
      filterFacets = Object.keys(@filters[0])
      _.each filterFacets, (facet) =>
        @bigList[facet] = []
      _.each @filters, (filterSet) =>
        _.each filterFacets, (facet, i) =>
          @bigList[facet].push filterSet[facet]
      _.each filterFacets, (facet) =>
        @bigList[facet] = _.uniq( _.flatten _.union @bigList[facet])
        @bigList[facet].sort (a, b) ->
          if a is b then return 0
          if facet is "position"
            if +a > +b then 1 else -1
          else if facet is "week"
            if moment(a) > moment(b) then 1 else -1
          else
            if a > b then 1 else -1

      # console.log bigList
      _.each @bigList, (bigSet, facet) =>
        _.each bigSet, (value) =>
          @$el.find("##{facet}").append("""
            <option value='#{value}'>#{value.toUpperCase()}</option>
            """).attr("disabled", false)
      # # console.log bigList
      @$el.find(".chosen-select").chosen().trigger("chosen:updated")
      @collection.on "filter", =>
        @makeFilterLists()

    submit: (e, params) ->
      e.preventDefault()
      filter = {}
      facet = e.target.id
      value = if params.selected then params.selected else params.deselected
      filter[facet] = value
      if params.selected then @addFilter filter else @removeFilter filter

    clearFilters: (e) ->
      e.preventDefault()
      _.each @collections, (collection) ->
        collection.resetFilters()
      @$el.find("option").attr("disabled", false)
      @$el.find(".chosen-select").val('[]').trigger('chosen:updated')

    addFilter: (filter) ->
      _.each @collections, (collection) ->
        collection.addFilter filter
      @updateFilters filter

    removeFilter: (filter) ->
      _.each @collections, (collection) ->
        collection.removeFilter filter
      @updateFilters filter

    makeFilterLists: ->
      @$el.find("option").attr("disabled", true)
      _.each @collection.models, (model) =>
        filterList = model.attributes.appearancesCollection.initializeFilterLists()
        _.each filterList, (values, facet) =>
          _.each values, (value) =>
            @$el.find("option[value='#{value}']").attr("disabled", false)
      @$el.find(".chosen-select").chosen().trigger("chosen:updated")

    updateFilters: (filter) ->
      filterFacet = Object.keys filter
      @$el.find("option").attr("disabled", true)
      _.each @collections, (collection, i, list) =>
          facets = collection.getUpdatedFilterLists(filterFacet)
          _.each facets, (values, facet) =>
            _.each values, (value) =>
              @$el.find("option[value='#{value}']").attr("disabled", false)
      @$el.find(".chosen-select").chosen().trigger("chosen:updated")
