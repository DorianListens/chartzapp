App = require "application"
module.exports = (el, collection, slug = "") ->
  nameString = collection.url.split('/')
  nameString = nameString[3]
  # console.log "/api/artistgraph/#{nameString}"
  # console.log slug if slug
  if slug
    url = "/api/albumgraph/#{slug}"
  else
    url = "/api/artistgraph/#{nameString}"

  margin =
    top: 20
    right: 120
    bottom: 50
    left: 50

  barWidth = width

  width = $("#graph-region").width() - margin.left - margin.right
  height = 500 - margin.top - margin.bottom

  parseDate = d3.time.format("%Y-%m-%d").parse

  x = d3.scale.linear().range([
    0
    width - 75
  ])
  y = d3.scale.linear().range([
    height
    0
  ])
  color = d3.scale.category20()
  color2 = d3.scale.category20b()
  color3 = d3.scale.category20c()
  fullRange = color.range()
  cRange = color2.range()
  cRange.forEach (c) ->
    fullRange.push c
  c3Range = color3.range()
  c3Range.forEach (c) ->
    fullRange.push c
  color.range(fullRange)
  # Axis
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
  line = d3.svg.line().x((d) ->
    x d.date
  ).y((d) ->
    y d.position
  )
  svg = d3.select(el)
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  resize = ->
    width = $("#graph-region").width() - margin.left - margin.right
    x.range([
      0
      width
    ])
    d3.select('svg').remove()
    svg = d3.select(el)
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
      # .attr("transform", "translate(0," + height + ")")
    draw(url)

  $(window).on("resize", resize)

  draw = (url) ->
    d3.json url, (error, data) ->

      stations = data
      color.domain stations
      barWidth = width / stations.length

      stations.forEach (d) ->
        d.appearances.forEach (c) ->
          c.date = parseDate c.week

      x.domain [
        0
        stations.length
      ]
      y.domain [
        0
        d3.max(stations, (c) ->
          c.appearances.length
        )
      ]
      # svg.append("g")
      #   .attr("class", "x axis")
      #   .attr("transform", "translate(0," + height + ")")
      #   .call(xAxis)
      svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text "# of Appearances"

      mouseover = (d, i) ->
        d3.selectAll("g rect")
          .transition()
          .duration(100)
          .style("opacity", 0.2)
        d3.select("g .#{d._id} > rect")
          .transition()
          .duration(100)
          .style("opacity", 1)
        d3.select("g .#{d._id} > text")
          .transition()
          .duration(100)
          .style("font-weight", "bold")
        showData(d)

      mouseout = ->
        d3.selectAll("g rect")
          .transition()
          .duration(100)
          .style("opacity", 1)
        d3.selectAll("g text")
          .transition()
          .duration(100)
          .style("font-weight", "normal")
        $(".tip").fadeOut(50).remove()

      # click = (d) ->
      #   artist = d.attributes.artist
      #   view.trigger("click:album:circle", artist)

      showData = (d) ->
        $("#graph").append("<div class='tip'></div>")
        chartTip = d3.select(".tip")
        chartTip.style("left", width - 100 + "px" )
          .style("top", 50 + "px")
          .style("background", color d._id)
        $(".tip")
          .html("""
          #{d._id.toUpperCase()} <br />
          Total Appearances: #{d.appearances.length}<br />
          Heighest Position: #{d3.min(d.appearances, (c) ->
            return c.position )}<br />
          First: #{d3.min(d.appearances, (c) ->
            return c.week )}<br />
          Most Recent: #{d3.max(d.appearances, (c) ->
            return c.week )}
          """
          )
        $(".tip").fadeIn(100)


      station = svg.selectAll(".station")
        .data(stations)
        .enter()
        .append("g")
        .attr("transform", (d, i) ->
          return "translate(" + i * barWidth + ",0 )")
        .attr("class", (d) ->
          return "station #{d._id}")
      station.append("rect")
        .attr("class", "bar")
        .attr("width", barWidth - 1)
        .attr("height", (d) ->
          return height - y d.appearances.length)
        .attr("y", (d) -> return 3 + y d.appearances.length)
        .style "fill", (d, i) ->
          color d._id
        .on("mouseover", mouseover)
        .on("mouseout", mouseout)
      station.append("text")
        .attr("y", barWidth / 2 - barWidth)
        .attr("x", (d) -> return height)
        .attr("dx", ".75em")
        .text( (d) -> return d._id.toUpperCase() )
        .attr("transform", "rotate(90)")

      # circle = station.selectAll('circle')
      #   .data( (d, i) ->
      #     d.appearances.forEach (c) ->
      #       c._id = d._id
      #     return d.appearances)
      #   .enter().append("circle")
      #   .attr("class", (d) -> return "dot #{d._id} #{d.week}")
      #   .style "fill", (d, i) ->
      #     color d._id
      #   .attr("r", 5)
      #   .attr "cx", (d) ->
      #     x d.date
      #   .attr "cy", (d) ->
      #     y d.position
      #   .on("mouseover", highlightCircle)
      #   .on "mouseout", mouseoutCircle
      #
      # legend = svg.selectAll(".legend")
      #   .data(color.domain().slice().reverse())
      #   .enter().append("g")
      #   .attr("class", (d) -> return "legend #{d}")
      #   .attr "transform", (d, i) ->
      #     if i < 20
      #       "translate(0," + i * 20 + ")"
      #     else if i >= 20
      #       "translate(75," + (i - 20) * 20 + ")"
      #
      # legend.append("rect")
      #   .attr("x", width - 10)
      #   .attr("width", 18)
      #   .attr("height", 18)
      #   .style "fill", color
      # legend.append("text")
      #   .attr("x", width - 15)
      #   .attr("y", 9)
      #   .attr("dy", ".35em")
      #   .style("text-anchor", "end")
      #   .text (d) ->
      #     d.toUpperCase()
      # legend.on("mouseover", highlightLegend)
      #   .on("mouseout", mouseoutLegend)
      return
  draw(url)
