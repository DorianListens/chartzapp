
module.exports = (el, url) ->

  margin =
    top: 20
    right: 120
    bottom: 30
    left: 50

  # width = 960 - margin.left - margin.right

  width = $("#graph-region").width() - margin.left - margin.right
  height = 500 - margin.top - margin.bottom
  parseDate = d3.time.format("%Y-%m-%d").parse
  x = d3.time.scale().range([
    0
    width
  ])
  y = d3.scale.linear().range([
    0
    height
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

  highlight = (d, i) ->
    d3.selectAll("g path, circle")
      .transition()
      .duration(100)
      .style("opacity", 0.2)
    d3.select(@)
      .transition()
      .duration(100)
      .style("stroke-width", "10px")
      .style("opactiy", 1)
    d3.selectAll("g .#{d._id} circle")
      .transition()
      .duration(100)
      .attr("r", "10")
      .style("opacity", 1)
      .forEach (d) ->
        d.forEach (c, i) ->
          showTips(d, c, i)

    d3.select(".#{d._id} text")
      .transition()
      .duration(100)
      .style("font-weight", "bold")

  mouseout = (d, i) ->
    d3.selectAll("g path, circle")
      .transition()
      .duration(100)
      .style("opacity", 1)
      .attr("r", 5)
    d3.select(@)
      .transition()
      .duration(100)
      .style("stroke-width", "1.5px")
    d3.select(".#{d._id} text")
      .transition()
      .duration(100)
      .style("font-weight", "normal")
    hideData()

  highlightCircle = (d) ->
    showData(@, d)
    d3.select(@)
      .transition()
      .duration(100)
      .attr("r", "10")
    d3.select(".#{d._id} text")
      .transition()
      .duration(100)
      .style("font-weight", "bold")
  mouseoutCircle = (d) ->
    hideData(@)
    d3.select(@)
      .transition()
      .duration(100)
      .attr("r", "5")
    d3.select(".#{d._id} text")
      .transition()
      .duration(100)
      .style("font-weight", "normal")
  highlightLegend = (d, i) ->
    d3.select(@)
      .transition()
      .duration(100)
      .style("font-weight", "bold")
    d3.selectAll("g path, circle")
      .transition()
      .duration(100)
      .style("opacity", 0.2)
    d3.selectAll("g .#{d} path")
      .transition()
      .duration(100)
      .style("stroke-width", "10px")
      .style("opacity", 1)
    d3.selectAll("g .#{d} circle")
      .transition()
      .duration(100)
      .attr("r", "10")
      .style("opacity", 1)
    d3.selectAll(".#{d} circle")
      .forEach (d) ->
        d.forEach (c, i) ->
          showTips(d, c, i)


  showTips = (d, c, i) ->
    coord1 = parseInt c.cx.animVal.value
    coord2 = parseInt c.cy.animVal.value
    coord = [coord1, coord2]
    $("#graph")
      .append("<div class='tip' id='#{d[i].__data__._id}-#{i}'></div>")
    chartTip = $("##{d[i].__data__._id}-#{i}")
    chartTip.css("left", (coord[0] + 15) + "px" )
      .css("top", (coord[1] - 50) + "px")
      .css("background", color d[i].__data__._id)
    $("##{d[i].__data__._id}-#{i}")
      .html("""
      #{d[i].__data__._id.toUpperCase()}<br />
      # #{d[i].__data__.position} <br />
      #{d[i].__data__.week}
      """
      )
    $("##{d[i].__data__._id}-#{i}").fadeIn(100)


  mouseoutLegend = (d, i) ->
    d3.select(@)
      .transition()
      .duration(100)
      .style("font-weight", "normal")
    d3.selectAll("g path, circle")
      .transition()
      .duration(100)
      .style("opacity", 1)
      .style("stroke-width", "1.5px")
      .attr("r", 5)
    d3.selectAll("g .#{d} circle")
      .transition()
      .duration(100)
      .attr("r", 5)
    hideData()
  showData = (dot, d) ->
    coord = d3.mouse(dot)
    $("#graph").append("<div class='tip'></div>")
    chartTip = d3.select(".tip")
    chartTip.style("left", (coord[0] + 15) + "px" )
      .style("top", (coord[1] - 50) + "px")
      .style("background", color d._id)
    $(".tip")
      .html("""
      Station: #{d._id.toUpperCase()}<br />
      Position: #{d.position} <br />
      Week: #{d.week}
      """
      )
    $(".tip").fadeIn(100)
  hideData = ->
    $(".tip").fadeOut(50).remove()

  draw = (url) ->
    d3.json url, (error, data) ->
      # ids = []
      # data.forEach (d) ->
      #   ids.push d._id

      stations = data

      stations.forEach (d) ->
        d.appearances.forEach (c) ->
          c.date = parseDate c.week

      x.domain [
        d3.min(stations, (c) ->
          d3.min c.appearances, (v) ->
            v.date

        )
        d3.max(stations, (c) ->
          d3.max c.appearances, (v) ->
            v.date

        )
      ]
      y.domain [ 1, 30]
      svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
      svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text "Position"
      station = svg.selectAll(".station")
        .data(stations)
        .enter()
        .append("g")
        .attr("class", (d) ->
          return "station #{d._id}")
      station.append("path")
        .attr("class", "line")
        .attr "d", (d) ->
          line d.appearances
        .style "stroke", (d, i) ->
            color d._id
        .on("mouseover", highlight)
        .on("mouseout", mouseout)
      circle = station.selectAll('circle')
        .data( (d, i) ->
          d.appearances.forEach (c) ->
            c._id = d._id
          return d.appearances)
        .enter().append("circle")
        .attr("class", (d) -> return "dot #{d._id} #{d.week}")
        .style "fill", (d, i) ->
          color d._id
        .attr("r", 5)
        .attr "cx", (d) ->
          x d.date
        .attr "cy", (d) ->
          y d.position
        .on("mouseover", highlightCircle)
        .on "mouseout", mouseoutCircle

      legend = svg.selectAll(".legend")
        .data(color.domain().slice().reverse())
        .enter().append("g")
        .attr("class", (d) -> return "legend #{d}")
        .attr "transform", (d, i) ->
          "translate(0," + i * 20 + ")"

      legend.append("rect")
        .attr("x", width + margin.left)
        .attr("width", 18)
        .attr("height", 18)
        .style "fill", color
      legend.append("text")
        .attr("x", width + 40)
        .attr("y", 9)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text (d) ->
          d.toUpperCase()
      legend.on("mouseover", highlightLegend)
        .on("mouseout", mouseoutLegend)
      return
  draw(url)

    # station.append("text").datum((d) ->
    #   name: d._id
    #   value: d.appearances[0]
    # ).attr("transform", (d) ->
    #   "translate(" + x(d.value.week) + "," + y(d.value.position) + ")"
    # ).attr("x", 3).attr("dy", ".35em").text (d) ->
    #   d.name
