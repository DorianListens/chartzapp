# Put your handlebars.js helpers here.

Handlebars.registerHelper 'pick', (val, options) ->
  return options.hash[val]

Handlebars.registerHelper 'toUpperCase', (str) ->
  return str.toUpperCase()
