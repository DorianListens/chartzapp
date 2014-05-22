App = require "application"
LabelApp = require "modules/label/label_app"
Controllers = require "controllers/baseController"

module.exports = App.module 'LabelApp.Show',
(Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (opts) ->
      @layout = @getLayoutView()

      @listenTo @layout, 'show', =>
        @showPanel()
        @mainView(opts.label)

      @show @layout,
        loading: true

    mainView: (search = null) ->
      if search then @showLabel(search) else @showEmpty()

    showLabel: (search) ->
      label = App.request 'label:entities', search

      labelView = @getLabelView label

      @show labelView,
        region: @layout.tableRegion
        loading: true
      App.execute "when:fetched", label, ->
        label.initializeFilters()
        console.log label
        info = label.getFilterLists()
        console.log label.getFilterLists()
        $(document).foundation()

    showEmpty: ->
      emptyView = @getEmptyView()
      @show emptyView,
        region: @layout.tableRegion

    getEmptyView: ->
      new Show.EmptyView

    getLabelView: (label) ->
      new Show.Label
        collection: label

    showPanel: (label) ->
      panelView = @getPanelView label
      @listenTo panelView, 'click:search', (label) =>
        @showLabel label

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
    template: "modules/label/showLabel/templates/show_layout"

    regions:
      panelRegion: "#panel-region"
      tableRegion: "#table-region"

  class Show.Panel extends Marionette.ItemView
    template: "modules/label/showLabel/templates/panel"

    ui:
      'labelInput' : '#label_input'

    events:
      'submit' : 'submit'

    submit: (e) ->
      e.preventDefault()
      labelVal = $.trim @ui.labelInput.val()
      @trigger 'click:search', labelVal

  class Show.ArtistItem extends Marionette.ItemView
    template: "modules/label/showLabel/templates/artistItem"
    tagName: 'div'

  class Show.Empty extends Marionette.ItemView
    template: "modules/label/showLabel/templates/empty"
    tagName: 'div'

  class Show.EmptyView extends Marionette.ItemView
    template: "modules/label/showLabel/templates/emptyview"

  class Show.Label extends Marionette.CompositeView
    template: "modules/label/showLabel/templates/artists"
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
