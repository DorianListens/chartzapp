App = require "application"
module.exports = (el, collection, graph) ->

  margin =
    top: 20
    right: 120
    bottom: 50
    left: 50

  # width = 960 - margin.left - margin.right

  width = $("#graph-region").width() - margin.left - margin.right
  height = 500 - margin.top - margin.bottom
  parseDate = d3.time.format("%Y-%m-%d").parse
  x = d3.time.scale().range([
    0
    width - 75
  ])
  y = d3.scale.linear().range([
    0
    height
  ])

  # Colour setup
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
    draw(graph)

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
    if i % 2
      chartTip.css("top", (coord[1] + 50) + "px" )
    else
      chartTip.css("top", (coord[1] - 50) + "px")
    chartTip.css("left", (coord[0] + 50) + "px" )
      # .css("top", (coord[1] - 50) + "px")
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

  parse = (collection) ->
    output = []
    stations = {}
    _.each collection.models, (model) ->
      appearances = model.get "appearancesCollection"
      _.each appearances.models, (ap, i) ->
        if stations[ap.attributes.station]
          stations[ap.attributes.station].appearances.push
            position: ap.attributes.position
            week: ap.attributes.week
        else stations[ap.attributes.station] =
          appearances: [
            position: ap.attributes.position
            week: ap.attributes.week
          ]
    # console.log stations
    names = Object.keys stations
    _.each names, (name) ->
      output.push
        _id: name
        appearances: stations[name].appearances
    # console.log output
    output

  draw = (graph) ->

    stations = parse(collection)


    stations.forEach (d) ->
      d.appearances.forEach (c) ->
        c.date = parseDate c.week

    if graph is "line"

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
      y.domain [1, 30]
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
          d.appearances.sort((a,b) -> return a.date-b.date)
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
          if i < 20
            "translate(0," + i * 20 + ")"
          else if i >= 20
            "translate(75," + (i - 20) * 20 + ")"

      legend.append("rect")
        .attr("x", width - 10)
        .attr("width", 18)
        .attr("height", 18)
        .style "fill", color
      legend.append("text")
        .attr("x", width - 15)
        .attr("y", 9)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text (d) ->
          d.toUpperCase()
      legend.on("mouseover", highlightLegend)
        .on("mouseout", mouseoutLegend)
      return
    else if graph is "bar"
      color.domain stations
      barWidth = width / stations.length
      x = d3.scale.linear().range([
        0
        width - 75
      ])
      y = d3.scale.linear().range([
        height
        0
      ])
      yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")

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
          Highest Position: #{d3.min(d.appearances, (c) ->
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


      return
  draw(graph)

    # station.append("text").datum((d) ->
    #   name: d._id
    #   value: d.appearances[0]
    # ).attr("transform", (d) ->
    #   "translate(" + x(d.value.week) + "," + y(d.value.position) + ")"
    # ).attr("x", 3).attr("dy", ".35em").text (d) ->
    #   d.name
