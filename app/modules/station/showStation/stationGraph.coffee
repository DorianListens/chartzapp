App = require "application"
module.exports = (el, collection, view) ->

  margin =
    top: 100
    right: 100
    bottom: 50
    left: 100

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


  barWidth = width / albums.length

  rScale = d3.scale.linear()
  rScale.domain(
    d3.extent(albums, (c) ->
      c.attributes.frontPoints
      )
    )

  rScale.range [5, 130]


  y.domain [
    d3.max(albums, (c) ->
      c.attributes.frontPoints
    )
    d3.min(albums, (c) ->
      c.attributes.frontPoints #appearances.length
    ) - 10
  ]
  x.domain [0, 11]

  # svg.append("g")
  #   .attr("class", "x axis")
  #   .attr("transform", "translate(0," + height + ")")
  #   .call(xAxis)
  unless albums.length is 0
    svg.append("g")
      .attr("class", "y axis")
      # .attr("transform", "translate(-20,0)")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 4)
      .attr("dy", "-4em")
      .style("text-anchor", "end")
      .text "Chartscore"

  color.domain albums

  mouseover = (d, i) ->
    d3.selectAll("g rect")
      .transition()
      .duration(100)
      .style("opacity", 0.2)
    d3.select("g .#{d.attributes.slug} > rect")
      .transition()
      .duration(100)
      .style("opacity", 1)
    showData(@, d)

  mouseout = ->
    d3.selectAll("g rect")
      .transition()
      .duration(100)
      .style("opacity", 1)
    $(".tip").fadeOut(50).remove()

  click = (d) ->
    artist = d.attributes.artist
    view.trigger("click:album:circle", artist)

  showData = (i, d) ->

    $("#graph").append("<div class='tip'></div>")
    chartTip = d3.select(".tip")
    chartTip.style("left", width - 150 + "px" )
      .style("top", 50 + "px")
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
      This graph displays the top 10 albums on #{collection.station} over the selected time range.<br />
      The X-Axis is determined by the album's rank.<br />
      The Y-Axis is determined by the album's Chartscore.<br />
      Mouseover any bar for more information.<br />
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

  album = svg.selectAll(".album")
    .data(albums)
    .enter()
    .append("g")
    .attr("transform", (d, i) ->
      return "translate(" + i * barWidth + ",0 )")
    .attr("class", (d) ->
      return "album #{d.attributes.slug}")
  album.append("rect")
    .attr("class", "bar")
    .attr("width", barWidth - 1)
    .attr("height", (d) ->
      return height - y d.attributes.frontPoints) # appearances.length)
    .attr("y", (d) -> return 3 + y d.attributes.frontPoints) #appearances.length)
    .style "fill", (d, i) ->
      color d.cid
    # .on("mouseover", mouseover)
    # .on("mouseout", mouseout)
  album.append("text")
    .attr("y", height + 20)# barWidth / 2 - barWidth)
    .attr("x", (d) -> return (barWidth / 2) - 10)#height)
    # .attr("dx", ".75em")
    .text( (d, i) -> return "##{i + 1}")
    # .attr("transform", "rotate(90)")

  album.on("mouseover", mouseover)
    .on("mouseout", mouseout)
    .on("click", click)

  if albums.length is 0
    showEmpty()
