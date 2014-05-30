# Put your handlebars.js helpers here.

Handlebars.registerHelper 'pick', (val, options) ->
  return options.hash[val]

Handlebars.registerHelper 'toUpper', (str) ->
  return str.toUpperCase() if str

Handlebars.registerHelper 'json', (context) ->
  return JSON.stringify context

Handlebars.registerHelper 'each_with_sort', (array, key, opts) ->
  array = array.sort (a, b) ->
    a = parseInt a[key]
    b = parseInt b[key]
    return  1 if a > b
    return  0 if a is b
    return -1 if a < b
  s = ''
  for e in array
    s += opts.fn(e)
  s

Handlebars.registerHelper 'each_sort_date', (array, key, opts) ->
  array = array.sort (a, b) ->
    a = new Date(a[key])
    b = new Date(b[key])
    return  1 if a > b
    return  0 if a is b
    return -1 if a < b
  s = ''
  for e in array
    s += opts.fn(e)
  s

Handlebars.registerHelper 'log', (object) ->
  console.log object

Handlebars.registerHelper 'countPoints', (array) ->
  theCount = 0
  for obj in array
    do (obj) ->
      points = 0
      points = 31-(parseInt obj.position)
      theCount += points
  theCount
