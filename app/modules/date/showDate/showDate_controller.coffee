App = require "application"
DateApp = require "modules/date/date_app"
Controllers = require "controllers/baseController"

module.exports = App.module 'DateApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        @showPanel()
        @mainView(opts.date)

      @show @layout,
        loading: true

    mainView: (search = null) ->
      if search then @showDate(search) else @showEmpty()

    showDate: (search) ->
      date = App.request 'date:entities', search

      dateView = @getDateView date

      @show dateView,
        region: @layout.tableRegion
        loading: true
      App.execute "when:fetched", date, ->
        $(document).foundation()

    showEmpty: ->
      emptyView = @getEmptyView()
      @show emptyView,
        region: @layout.tableRegion

    getEmptyView: ->
      new Show.EmptyView

    getDateView: (date) ->
      new Show.Date
        collection: date

    showPanel: (date) ->
      panelView = @getPanelView date
      @listenTo panelView, 'click:search', (date) =>
        @showDate date

      @show panelView,
        region: @layout.panelRegion
      $(document).foundation()
      #   accordion:
      #     # active_class: 'active'
      #     multi_expand: true
      #     toggleable: true
      # )

    getPanelView: ->
      new Show.Panel

    getLayoutView: ->
      new Show.Layout


# VIEW ######################################################################


  class Show.Layout extends Marionette.Layout
    template: "modules/date/showDate/templates/show_layout"

    regions:
      panelRegion: "#panel-region"
      tableRegion: "#table-region"

  class Show.Panel extends Marionette.ItemView
    template: "modules/date/showDate/templates/panel"

    ui:
      'dateInput' : '#date_input'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      dateVal = $.trim @ui.dateInput.val()
      @trigger 'click:search', dateVal

  class Show.ArtistItem extends Marionette.ItemView
    template: "modules/date/showDate/templates/artistItem"
    tagName: 'div'

  class Show.Empty extends Marionette.ItemView
    template: "modules/date/showDate/templates/empty"
    tagName: 'div'

  class Show.EmptyView extends Marionette.ItemView
    template: "modules/date/showDate/templates/emptyview"

  class Show.Date extends Marionette.CompositeView
    template: "modules/date/showDate/templates/artists"
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
