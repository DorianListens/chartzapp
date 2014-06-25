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

  width = ($("#circles-region").width() - margin.left - margin.right) / 3
  # console.log width
  height = 500 - margin.top - margin.bottom
  radius = Math.min(width, height) / 2

  color = require 'colorList'

  arc = d3.svg.arc()
    .outerRadius(radius - 10)
    .innerRadius(radius - 100)

  labelPie = d3.layout.pie()
    .sort(null)
    .value (d) ->
      d.chartScore
      # d.appearances.length

  svg = d3.select(el).select("#labels")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(#{width / 2 }, #{height / 2})")

  albums = collection.models

  labels = {}
  lA = []
  aByL = {}
  _.each albums, (album) ->
    if album.attributes.album isnt ''
      label = album.get 'label'
      if aByL[label]
        aByL[label].push album.get 'album'
      else
        aByL[label] = [album.get 'album']
      # console.log album.attributes.appearances

      if labels[label]
        _.each album.attributes.appearances, (ap) ->
          labels[label].push ap
      else
        labels[label] = []
        _.each album.attributes.appearances, (ap) ->
          labels[label].push ap

  _.each aByL, (ar, l) ->
    ar = _.uniq ar

  _.each labels, (array, label) ->
    lA.push
      label: label
      appearances: array
      albums: aByL[label]

  _.each lA, (label) ->
    label.chartScore = 0
    _.each label.appearances, (ap) ->
      label.chartScore += 31 - +ap.position


  lA = lA.sort (a, b) ->
    a = a.chartScore
    b = b.chartScore
    return 0 if a is b
    if a > b then -1 else 1

  tA = lA.slice(0, 30)
  bA = lA.slice(30)

  topLabels = []

  others =
    labels: []
    chartScore: 0
    label: ""
    appearances: []
    albums: []

  _.each bA, (label) ->
    others.labels.push label.label
    others.albums.push label.albums
    _.each label.appearances, (ap) ->
      others.appearances.push ap

  _.each tA, (label) ->
    topLabels.push label

  others.label = "#{others.labels.length} Others"
  others.albums = _.flatten others.albums

  _.each others.appearances, (ap) ->
    others.chartScore += 31 - ap.position

  topLabels.push others
  # console.log topLabels

  # _.each topLabels, (label) ->
  #   label.chartScore = 0
  #   _.each label.appearances, (ap) ->
  #     label.chartScore += 31 - +ap.position

  mouseover = (d, i) ->
    d3.selectAll("g.arc")
      .transition()
      .duration(100)
      .style("opacity", 0.2)
    d3.select("g .#{slugify d.data.label}")
      .transition()
      .duration(100)
      .style("opacity", 1)
    showData(@, d)

  mouseout = ->
    d3.selectAll("g.arc")
      .transition()
      .duration(100)
      .style("opacity", 1)
    $(".tip").fadeOut(50).remove()

  click = (d) ->
    artist = d.attributes.artist
    view.trigger("click:album:circle", artist)

  showData = (circle, d) ->
    coord = d3.mouse(circle)
    $("#labels").append("<div class='tip'></div>")
    chartTip = d3.select(".tip")
    chartTip.style("right", 1.25 + "rem" )
      .style("top", 50 + "px")
      .style("background", color d.data.label)
    $(".tip")
      .html("""
      #{d.data.label}<br />
      # of Albums: #{d.data.albums.length}<br />
      # of Appearances: #{d.data.appearances.length}<br />
      Chartscore: #{d.data.chartScore}
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
    .data(labelPie(topLabels))
    .enter().append("g")
    .attr("class", (d) -> "arc #{slugify d.data.label}")
  g.append("path")
    .attr("d", arc)
    .style("fill", (d) ->
      # console.log d
      color d.data.label)
  g.on("mouseover", mouseover)
    .on('mouseout', mouseout)



  if albums.length is 0
    showEmpty()
