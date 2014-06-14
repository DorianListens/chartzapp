App = require "application"

module.exports = (el, collection, graph, view, info) ->

  margin =
    top: 20
    right: 50#120
    bottom: 50
    left: 50

  # width = 960 - margin.left - margin.right

  width = $("#graph-region").width() - margin.left - margin.right
  height = 500 - margin.top - margin.bottom
  parseDate = d3.time.format("%Y-%m-%d").parse
  x = d3.time.scale().range([
    0
    width - 140
  ])
  y = d3.scale.linear().range([
    0
    height
  ])

  color = require 'colorList'

  # Axis
  xAxis = d3.svg.axis()
    .scale(x)
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

  click = (d) ->
    station = d._id
    view.trigger("click:station:item", station)

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
    d3.selectAll("g .#{d._id} path")
      .transition()
      .duration(100)
      .style("stroke-width", "10px")
      .style("opacity", 1)
    d3.selectAll("g .#{d._id} circle")
      .transition()
      .duration(100)
      .attr("r", "10")
      .style("opacity", 1)
    d3.selectAll(".#{d._id} circle")
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
    d3.selectAll("g .#{d._id} circle")
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
            score: 31 - ap.attributes.position
        else stations[ap.attributes.station] =
          appearances: [
            position: ap.attributes.position
            week: ap.attributes.week
            score: 31 - ap.attributes.position
          ]

    # console.log stations
    names = Object.keys stations
    _.each names, (name) ->
      output.push
        _id: name
        appearances: stations[name].appearances
    # console.log output
    output.sort (a, b) ->
      # console.log info
      stationA = info.findWhere
        name: a._id.toUpperCase()

      stationB = info.findWhere
        name: b._id.toUpperCase()
      # console.log stationA
      a = stationA.get "postalCode"
      b = stationB.get "postalCode"

      return 0 if a is b
      if a > b then -1 else 1

  parseWeeks = (collection) ->
    output = []
    weeks = {}
    _.each collection.models, (model) ->
      appearances = model.get "appearancesCollection"
      _.each appearances.models, (ap, i) ->
        if weeks[ap.attributes.week]
          weeks[ap.attributes.week].appearances.push
            station: ap.attributes.station
            position: ap.attributes.position
        else
          weeks[ap.attributes.week] =
            appearances: [
              station: ap.attributes.station
              position: ap.attributes.position
            ]
    names = Object.keys weeks
    _.each names, (name) ->
      output.push
        week: name
        appearances: weeks[name].appearances
    # console.log output
    output


  # graph = 'stations'

  draw = (graph) ->

    stations = parse(collection)

    # color.domain stations

    showInfo = ->
      if $(el).find(".info").length isnt 0
        $(".info").remove()
      else
        $(el).append("<div class='tip text-center info'></div>").find(".tip")
          .css("width", width + margin.left + margin.right + "px")
          .css("margin", "auto")
          .css("top", height / 2 + "px")
          # .css("background", "#000")
          .html(infostring)
          .on("click", hideInfo)
          .fadeIn(100)

    hideInfo = ->
      $(el).find(".info").fadeOut(100)
      $(".info").remove()

    if $(el).find(".infobox").length isnt 0
      $(".infobox").remove()
    $(el)
      .prepend("<div class='button tiny radius infobox'></div>")
      .find(".infobox")
      .html("<i class='fi-info large'></i>")
      .on("click", showInfo)

    $(el).find("svg").on("click", hideInfo)

    stations.forEach (d) ->
      d.appearances.forEach (c) ->
        c.date = parseDate c.week

    if graph is "stations"
      infostring = """
    <br />
    This graph displays the number of stations #{collection.artist} is charting
    on over time.<br />
    <br />
    (Click anywhere to hide)
    <br />
    <br />
      """

      x = d3.time.scale().range([
        0
        width - 140
      ])
      y = d3.scale.linear().range([
        0
        height
      ])

      y2 = d3.scale.linear().range([
        0
        height
      ])


      line = d3.svg.line().x((d) ->
        x d.week
      ).y((d) ->
        points = 0
        _.each d.appearances, (a) ->
          points += (31 - a.position)
        y points
      )

      area = d3.svg.area()
        .x( (d) ->
          return x d.week)
        .y0( (d) ->
          return y d.y0)
        .y1( (d) ->
           return y d.y0 + d.y )

      stack = d3.layout.stack()
        .values (d) ->
          d.values

      weeks = parseWeeks(collection)

      weeks.forEach (d) ->
          d.week = parseDate d.week

      pByW = {}
      _.each weeks, (w) ->
        _.each w.appearances, (a) ->
          # console.log a.position
          if pByW[w.week]
            pByW[w.week] += (31 - a.position)
          else
            pByW[w.week] = (31 - a.position)

      pArray = []

      _.each pByW, (w, k) ->
        pArray.push
          week: k
          score: w
      console.log stations
      # console.log pArray

      # console.log pByW

      x.domain [
        d3.min weeks, (w) ->
          w.week

        d3.max weeks, (w) ->
          w.week
      ]
      y.domain [
        # d3.max weeks, (w) ->
        #   w.appearances.length
        d3.max pArray, (p) ->
          p.score

        0
      ]
      y2.domain [
        d3.max weeks, (w) ->
          w.appearances.length
        # d3.max pArray, (p) ->
        #   p.score

        0
      ]
      yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")

      y2Axis = d3.svg.axis()
        .scale(y2)
        .orient("right")

      xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")

      # console.log
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
        .attr("dy", "-3em")
        .style("text-anchor", "end")
        .text "Chartscore"
      svg.append("g")
        .attr("class", "y2 axis")
          .attr("transform", "translate(#{width - margin.right}, 0)")
        .call(y2Axis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", "-3em")
        .style("text-anchor", "end")
        .text "Number of Stations"
      week = svg.selectAll(".week")
        .data(weeks)
        .enter()
        .append("g")
        .attr("class", (d) ->
          return "week of #{d.week}")
      week.append("path")
        .attr("class", "line")
        .attr "d", (d) ->
          weeks.sort((a,b) -> return a.week-b.week)
          # weeks.sort
          line weeks
        .style("stroke", (d) -> color d)
        .on("mouseover", highlight)
        .on("mouseout", mouseout)
      week.append("circle")
        .attr("class", (d) -> return "dot #{d.week}")
        .style "fill", (d, i) ->
          color d._id
        .attr("r", 5)
        .attr "cx", (d) ->
          x d.week
        .attr "cy", (d) ->
          y2 d.appearances.length
      station = svg.selectAll(".station")
        .data(weeks)

    if graph is "line"
      infostring = """
    <br />
    This graph displays all appearances of #{collection.artist} over the
    selected time range, organized by station.<br />
    The X-Axis is determined by the date of the appearance.<br />
    The Y-Axis is determined by the album's position.<br />
    Mouseover any dot or line for more information.<br />
    <br />
    (Click anywhere to hide)
    <br />
    <br />
    """
      line = d3.svg.line().x((d) ->
        x d.date
      ).y((d) ->
        y d.position
      )
      x.domain [
        d3.min stations, (c) ->
          d3.min c.appearances, (v) ->
            v.date

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
        .attr("dy", "-3em")
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
        .on("click", click)
        .on "mouseout", mouseoutCircle


      legend = svg.selectAll(".legend")
        .data(stations)
        .enter().append("g")
        .attr("class", (d) -> return "legend #{d}")
        .attr "transform", (d, i) ->
          if i < 20
            "translate(-70," + i * 20 + ")"
          else if i >= 20
            "translate(5," + (i - 20) * 20 + ")"

      legend.append("rect")
        .attr("x", width - 10)
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", (d) ->
          return color(d._id)
          )
      legend.append("text")
        .attr("x", width - 15)
        .attr("y", 9)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text (d) ->
          d._id.toUpperCase()
      legend.on("mouseover", highlightLegend)
        .on("mouseout", mouseoutLegend)
      return
    else if graph is "bar"
      infostring = """
    <br />
    This graph displays the number of appearances of #{collection.artist}
    over the selected time range, organized by station.<br />
    The X-Axis is determined by the station.<br />
    The Y-Axis is determined by the number of appearances.<br />
    Mouseover any bar for more information.<br />
    <br />
    (Click anywhere to hide)
    <br />
    <br />
    """
      margin.right = margin.left
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
        .attr("dy", "-3em")
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
        .on("click", click)
      station.append("text")
        .attr("y", barWidth / 2 - barWidth)
        .attr("x", (d) -> return height)
        .attr("dx", ".75em")
        .text( (d) -> return d._id.toUpperCase() )
        .attr("transform", "rotate(90)")


      return
  draw(graph)
