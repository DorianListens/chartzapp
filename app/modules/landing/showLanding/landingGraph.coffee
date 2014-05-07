App = require "application"
module.exports = (el, collection, view) ->

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
    width
  ])
  color = d3.scale.category10()
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
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  albums = collection.models
  albums = albums.slice(0,10)

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
  x.domain [0, 11]

  # svg.append("g")
  #   .attr("class", "x axis")
  #   .attr("transform", "translate(0," + height + ")")
  #   .call(xAxis)
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

  color.domain albums

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
    chartTip.style("left", (coord[0] + 100) + "px" )
      .style("top", (coord[1]) + "px")
      .style("background", color d.cid)
    $(".tip")
      .html("""
      #{d.attributes.artist} <br />
      #{d.attributes.album}<br />
      Total Appearances: #{d.attributes.appearances.length}<br />
      Chartscore: #{d.attributes.frontPoints}
      """
      )
    $(".tip").fadeIn(100)


  albumCircles = svg.selectAll("circle")
    .data(albums)
    .enter().append("circle")
    .attr("fill", (d) ->
      color d.cid)
    .attr("class", (d) -> return "dot #{d.attributes.slug}")
    .attr("cy", (d) ->
      num = d.attributes.appearances.length
      y num)
    .attr("cx", (d, i) ->
      x i+2)
    .attr("r", (d) ->

      rScale d.attributes.frontPoints
      )
  # albumCircles.append("svg:div")
  #   .attr("color", "#000")
  #   .attr("y", (d) ->
  #     num = d.attributes.appearances.length
  #     y num)
  #   .attr("x", (d, i) ->
  #     x i+2)
  #   .attr("dy", ".71em")
  #   .attr("height", "50px")
  #   .attr("width", "50px")
  #   .style("z-index", "99999")
  #   .text((d, i) ->
  #     i+ 1)


  albumCircles.on("mouseover", mouseover)
    .on("mouseout", mouseout)
    .on("click", click)
