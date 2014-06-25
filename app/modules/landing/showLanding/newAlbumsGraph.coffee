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
    gutter: 30

  # width = 960 - margin.left - margin.right

  width = ($("#circles-region").width() - margin.left - margin.right) /3 - (margin.gutter * 4)
  height = 500 - margin.top - margin.bottom
  radius = Math.min(width, height) / 2

  color = require 'colorList'

  arc = d3.svg.arc()
    .outerRadius(radius - 10)
    .innerRadius(0)

  pie = d3.layout.pie()
    # .sort(null)
    .value (d) ->
      d.length

  newPie = d3.layout.pie()
    .value (d) ->
      d.length
  svg = d3.select(el).select("#newAlbums")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(#{width / 2 + margin.gutter * 1.75}, #{height / 2})")

  albums = collection.models
  oldVNew = []
  # console.log collection
  oldVNew[0] = _.filter albums, (album) ->
    _.indexOf(collection.potentialA, album.attributes.firstWeek) isnt -1
  oldVNew[1] = _.filter albums, (album) ->
    _.indexOf(collection.potentialA, album.attributes.firstWeek) is -1

  _.each oldVNew, (array) ->
    array.sort (a, b) ->
      a = a.get 'frontPoints'
      b = b.get 'frontPoints'
      return 0 if a is b
      if a > b then -1 else 1
  # console.log oldVNew[1]

  mouseover = (d, i) ->
    d3.selectAll("g.arc")
      .transition()
      .duration(100)
      .style("opacity", 0.2)
    d3.select("g ._#{i}")
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

  click = (d, i) ->
    $this = d3.select(this)
    # $this.attr("class", =>
    if $this.classed("arc _0")
      if $this.classed("selected")
        view.trigger("switch:all")
        $this.attr("class", "arc _0")
      else
        view.trigger("switch:debuts")
        $this.attr("class","arc _0 selected")
        d3.select("g ._1").attr("class", "arc _1")
    else
      view.trigger("switch:all")
      d3.select("g ._0").attr("class", "arc _0")





    choice = ["debuts", "all"]
    # artist = d.attributes.artist
    # view.trigger("switch:#{choice[i]}")

  showData = (circle, d, i) ->
    coord = d3.mouse(circle)
    $("#newAlbums").append("<div class='tip'></div>")
    chartTip = d3.select(".tip")
    chartTip.style("right", 1.25 + "rem" )
      .style("top", 50 + "px")
      .style("background", color i)
    $(".tip")
      .html("""
      #{if i is 0 then "New This Week" else "Previously Appeared"}<br />
      Albums: #{d.data.length}<br />
      #{(+d.data.length / +albums.length * 100).toFixed(0)}%<br />
      #1: #{d.data[0].get 'artist'} - #{d.data[0].get 'album'}
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
    .data(pie(oldVNew))
    .enter().append("g")
    .attr("class", (d, i) -> "arc _#{i}")
  g.append("path")
    .attr("d", arc)
    .style("fill", (d, i) ->
      color i)
  g.on("mouseover", mouseover)
    .on('mouseout', mouseout)
    .on('click', click)



  if albums.length is 0
    showEmpty()
