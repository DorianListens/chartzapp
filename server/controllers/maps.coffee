module.exports.controller = (app) ->

  app.get '/canada.json', (req, res) ->
    res.sendfile 'server/lib/canada.json'
