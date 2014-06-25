App = require "application"

slugify = (Text) ->
  isNumber = (n) ->
    return !isNaN(parseFloat(n)) && isFinite(n)

  if isNumber(Text.charAt(0))
    Text = "_#{Text}"

  Text.toLowerCase().replace(RegExp(" ", "g"), "-").replace /[^\w-]+/g, ""

tuesify = (date) ->
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

module.exports = (el, collection, view) ->
  # console.log collection

  margin =
    top: 50
    right: 50
    bottom: 50
    left: 50

  # width = 960 - margin.left - margin.right

  width = $("#circles-region").width() / 3 - margin.left - margin.right
  height = 500 - margin.top - margin.bottom
  radius = Math.min(width, height) / 2

  color = require 'colorList'

  arc = d3.svg.arc()
    .outerRadius(radius - 10)
    .innerRadius(radius - 30)

  pie = d3.layout.pie()
    .value (d) ->
      d
  svg = d3.select(el).select("#reporting")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(#{width / 2 + 30}, #{height / 2})")

  albums = collection.models
  stations = collection.stations
  # _.each albums, (album) ->
  #   _.each album.get('appearances'), (ap) ->
  #     stations.push ap.station
  # stations = _.uniq stations
  data = [stations.length, 49 - stations.length]

  mouseover = (d, i) ->
    d3.selectAll("g.arc")
      .transition()
      .duration(100)
      .style("opacity", 0.2)
    d3.select("g ._#{d.data}")
      .transition()
      .duration(100)
      .style("opacity", 1)
    showData(@, d, i)

  mouseout = ->
    d3.selectAll("g.arc")
      .transition()
      .duration(100)
      .style("opacity", 1)
    $(".tip").fadeOut(50).remove()

  click = (d) ->
    artist = d.attributes.artist
    view.trigger("click:album:circle", artist)

  showData = (circle, d, i) ->
    coord = d3.mouse(circle)
    $("#reporting").append("<div class='tip'></div>")
    chartTip = d3.select(".tip")
    chartTip.style("right", 1.25 + "rem" )
      .style("top", 50 + "px")
      .style("background", color i)
    $(".tip")
      .html("""
      #{if i is 0 then "Reporting Stations" else "Not Reporting"}<br />
      Stations: #{d.data}<br />
      #{(+d.data / 49 * 100).toFixed(0)}%

      """
      )
    $(".tip").fadeIn(100)

  showEmpty = ->
    $(el).append("<div class='tip text-center'></div>").find(".tip")
      .css("width", width + margin.left + margin.right + "px")
      .css("margin", "auto")
      .css("top", height / 2 + "px")
      # .css("background", "#000")
      .html("""
    <br />
    Sorry, No Data is available for the selected Time Range.
    <br />
    <br />
    """
      ).fadeIn(100)




  g = svg.selectAll(".arc")
    .data(pie(data))
    .enter().append("g")
    .attr("class", (d, i) -> "arc _#{d.data}")
  g.append("path")
    .attr("d", arc)
    .style("fill", (d, i) ->
      # console.log d
      color i)
  g.on("mouseover", mouseover)
    .on('mouseout', mouseout)



  if albums.length is 0
    showEmpty()
