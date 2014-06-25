App = require "application"
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
    top: 100
    right: 120
    bottom: 50
    left: 50

  # width = 960 - margin.left - margin.right

  width = $("#graph-region").width() - margin.left - margin.right
  height = 500 - margin.top - margin.bottom
  y = d3.scale.linear().range([
    0
    height
  ])
  x = d3.scale.linear().range([
    0
    width - 100
  ])
  # color = d3.scale.category20()
  color = require 'colorList'
  xAxis = d3.svg.axis()
    .scale(x)
    # .tickPadding(10)
    # .tickSize(-height, -height)
    .orient("bottom")
  yAxis = d3.svg.axis()
    .scale(y)
    # .tickPadding(10)
    # .tickSize(-width, -width)
    .orient("left")

  svg = d3.select(el)
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + (margin.left + 20) + "," + margin.top + ")")

  albums = collection.models
  # albums = _.filter albums, (album) ->
  #   album.attributes.firstWeek is tuesify collection.startDate
  # albums = albums.slice(0,25)

  rScale = d3.scale.linear()
  rScale.domain(
    d3.extent(albums, (c) ->
      c.attributes.frontPoints
      )
    )

  rScale.range [5, 130]


  y.domain [
    d3.max(albums, (c) ->
      c.attributes.appearances.length
    )
    d3.min(albums, (c) ->
      c.attributes.appearances.length
    )
  ]
  x.domain(
    d3.extent(albums, (c) ->
      c.attributes.frontPoints
      )
    )
  # x.domain(
  #   d3.extent(albums (c) ->
  #     c.attributes.frontPoints)
  #   )#[0, 11]

  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)
  unless albums.length is 0
    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(-10,0)")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text "# of Appearances"

  # color.domain albums

  mouseover = (d, i) ->
    d3.selectAll("g circle")
      .transition()
      .duration(100)
      .style("opacity", 0.2)
    d3.select("g .#{d.attributes.slug}")
      .transition()
      .duration(100)
      .style("opacity", 1)
    showData(@, d)

  mouseout = ->
    d3.selectAll("g circle")
      .transition()
      .duration(100)
      .style("opacity", 1)
    $(".tip").fadeOut(50).remove()

  click = (d) ->
    artist = d.attributes.artist
    view.trigger("click:album:circle", artist)

  showData = (circle, d) ->
    coord = d3.mouse(circle)
    $("#graph").append("<div class='tip'></div>")
    chartTip = d3.select(".tip")
    chartTip.style("left", 150 + "px" )
      .style("top", 50 + "px")
      .style("background", color d.attributes.rank)
    $(".tip")
      .html("""
      ##{d.attributes.rank}: #{d.attributes.artist} <br />
      #{d.attributes.album}<br />
      Total Appearances: #{d.attributes.appearances.length}<br />
      Chartscore: #{d.attributes.frontPoints}<br />
      First Appearance: #{d.attributes.firstWeek}<br />
      Appeared on #{d.attributes.stations.length} / #{d.attributes.totalStations} stations
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

  showInfo = ->
    if $(el).find(".tip").length isnt 0
      $(".info").remove()
    else
      $(el).append("<div class='tip text-center info'></div>").find(".tip")
        .css("width", width + margin.left + margin.right + "px")
        .css("margin", "auto")
        .css("top", height / 3 + "px")
        # .css("background", "#000")
        .html("""
      <br />
      This graph displays the top albums for all stations over the selected time range.<br />
      The X-Axis and the Radius of each circle is determined by the album's Chartscore.<br />
      The Y-Axis is determined by the album's total number of appearances.<br />
      <br />
      Mouseover any circle for more information.<br />
      <br />
      (Click anywhere to hide)
      <br />
      <br />
      """
        ).on("click", hideInfo)
        .fadeIn(100)

  hideInfo = ->
    $(el).find(".info").fadeOut(100)
    $(".info").remove()

  $(el).prepend("<div class='button tiny radius infobox'></div>").find(".infobox")
    .html("<i class='fi-info large'></i>")
    .on("click", showInfo)

  $(el).find("svg").on("click", hideInfo)

  albumCircles = svg.selectAll("circle")
    .data(albums)
    .enter().append("circle")
    .attr("fill", (d) ->
      color d.attributes.rank)
    .attr("class", (d) -> return "dot #{d.attributes.slug}")
    .attr("cy", (d) ->
      num = d.attributes.appearances.length
      y num)
    .attr("cx", (d, i) ->
      x d.attributes.frontPoints)
    .attr("r", (d) ->
      rScale d.attributes.frontPoints
      )


  albumCircles.on("mouseover", mouseover)
    .on("mouseout", mouseout)
    .on("click", click)




  if albums.length is 0
    showEmpty()
