# Utility Functions #######################################################

moment = require 'moment'
request = require 'request'
deferred = require 'deferred'

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

  # Set up the deferred request.

module.exports.deferredRequest = (url) ->
  d = deferred()
  request url, (err, resp, body) ->
    if err
      d.reject new Error("Unable to fetch '" + url + "', reason: " + err)
      return
    if resp.statusCode isnt 200
      d.reject new Error("Unable to fetch '" + url + "', code: " + resp.statusCode)
      return
    d.resolve body
    return

  d.promise()

  # Make tuesdays

module.exports.tuesify = (date) ->
  theWeek = switch
    when date then moment(date)
    else moment()
  theDay = theWeek.get('day')
  theTues = switch
    when theDay is 0 then theWeek.day(-5)
    when theDay is 1 then theWeek.day(-5)
    when theDay is 2 then theWeek
    when theDay > 2 then theWeek.day(2)
  theTues = moment(theTues)
  theTues.format('YYYY-MM-DD')

  # Make slugs

module.exports.slugify = (Text) ->
  Text.toLowerCase().replace(RegExp(" ", "g"), "-").replace /[^\w-]+/g, ""


Array::last = ->
  @[@length -1]
