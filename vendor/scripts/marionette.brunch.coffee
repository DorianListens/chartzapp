Backbone.Marionette.Renderer.render = (templateName, data) ->

  if _.isFunction templateName
    template = templateName
  else if templateName is false
    return
  else
    template = require templateName

  return template(data)

do (Backbone) ->

  _.extend Backbone.Marionette.Application::,

    navigate: (route, options = {}) ->
      # route = "#" + route if route.charAt(0) is "/"
      # console.log "Doing navigate for #{route}"
      Backbone.history.navigate route, options

    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag

    startHistory: ->
      if Backbone.history
        Backbone.history.start(
          # pushState: true
        )

    register: (instance, id) ->
      @_registry ?= {}
      @_registry[id] = instance

    unregister: (instance, id) ->
      delete @_registry[id]

    resetRegistry: ->
      oldCount = @getRegistrySize()
      for key, controller of @_registry
        controller.region.close()
      msg = "There were #{oldCount} controllers in the registry, there are now #{@getRegistrySize()}"
      if @getRegistrySize() > 0 then console.warn(msg, @_registry) else console.log(msg)

    getRegistrySize: ->
      _.size @_registry

  _sync = Backbone.sync

  Backbone.sync = (method, entity, options = {}) ->

    sync = _sync(method, entity, options)
    if !entity._fetch and method is "read"
      entity._fetch = sync
    sync
