@App.module "ChartsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends Marionette.Layout
    template: "charts/list/templates/list_layout"

    regions:
      panelRegion: "#panel-region"
      asideRegion: "#aside-region"
      tableRegion: "#table-region"

  class List.Panel extends Marionette.ItemView
    template: "charts/list/templates/_panel"

  class List.ChartItem extends Marionette.ItemView
    template: "charts/list/templates/_chartitem"
    events:
      'click' : -> @trigger 'click:chartItem', @model

  class List.Charts extends Marionette.CompositeView
    template: "charts/list/templates/_charts"
    itemView: List.ChartItem
    itemViewContainer: "tbody"
