stationList = require 'stationList'

color = d3.scale.category20c()
color2 = d3.scale.category20b()
color3 = d3.scale.category20()
fullRange = color.range()
cRange = color2.range()
cRange.forEach (c) ->
  fullRange.push c
c3Range = color3.range()
c3Range.forEach (c) ->
  fullRange.push c
color.range fullRange



colorList = {}
_.each stationList, (station) ->
  colorList[station.toLowerCase()] = color station

colors = (station) ->
  station = station.toLowerCase() if typeof station is "String"
  if colorList[station]
    return colorList[station]
  else
    color.range fullRange.sort()
    return color station

module.exports = colors
