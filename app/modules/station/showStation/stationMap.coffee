module.exports = (el, collection, view) ->

  margin =
    top: 50
    right: 50
    bottom: 50
    left: 50

  color = require '../../../colorList'

  width = $("#graph-region").width() - margin.left - margin.right
  height = 600 - margin.top - margin.bottom
  svg = d3.select(el).append("svg").attr("width", width).attr("height", height)

  colorBox =
    BC: ['#8ad08c', '#80c47e', '#77b972', '#6fad66', '#67a25b', '#609651', '#598b48', '#52803e', '#4c7436', '#45692e']
    AB: ['#ebe06e', '#e4da74', '#ddd479', '#d7ce7d', '#d0c881']
    SK: ['#e7DEB2']
    MB: ['#cc9f61', '#ca6400', '#9e8752',  '#877949']
    ON: ['#eba294', '#e99d8f', '#e7988a', '#e59386', '#e38e81', '#e1897d', '#df8478', '#dd8074', '#db7b70', '#d9766c', '#d77167', '#d66c63', '#d4675f', '#d2625b', '#d05d57', '#ce5853', '#cc5450', '#ca4f4c', '#c84a48', '#c64544']
    QC: ['#d768db', '#c566d1', '#b564c6', '#a562bc', '#975fb1', '#8a5ca7', '#7d589c', '#725592', '#675187', '#5c4c7d']
    NS: ['#20a3fe', '#40c8fe', '#60e4fd', '#7ff8fd', '#9ffcf5']
    NB: ['#0165e4', '#025bc9', '#0351ae', '#044593', '#043a78']
    NF: ['#22fc32', '#4efa44', '#7ff765', '#a7f585', '#c6f2a5']

  colorBox.BC.reverse()
  colorBox.ON.reverse()

  d3.json "canada.json", (error, canada) ->
    return console.error(error)  if error
    subunits = topojson.feature(canada, canada.objects.prov)
    #
    sByC = {}
    sByP = {}
    cities = []
    provinces = []
    collection.sort()
    collection.each (model) ->
      cities.push model.get 'city'
      provinces.push model.get 'province'
      if sByP[model.get 'province']
        sByP[model.get 'province'].push(model.get 'name')
      else
        sByP[model.get 'province'] = [model.get 'name']
      if sByC[model.get 'city']
        sByC[model.get 'city'].push(model.get 'name')
      else
        sByC[model.get 'city'] = [ model.get 'name' ]
    provinces = _.uniq provinces
    cities = _.uniq cities
    # console.log sByP
    # console.log sByC
    # console.log provinces
    sCbP = {}

    # _.each cities, (city) ->
    #
    # 
    # _.each provinces, (province) ->
    #   if province is "NL" then province = "NF"
    #   console.log province, colorBox[province], sByP[province]
    #   sCbP[province] = _.object _.zip sByP[province], colorBox[province]
    #
    #
    # stationColors = {}
    # cityColors = {}
    #
    # # console.log sCbP
    # _.each sCbP, (prov) ->
    #   _.each prov, (color, station) ->
    #     stationColors[station] = color
    #
    # console.log stationColors
    # _.each cities, (city) ->
    #   fS = sByC[city][0]
    #   cityColors[city] = stationColors[fS]
    #
    # console.log cityColors



    ids = []
    _.each provinces, (prov) ->
      if prov is "NF" then prov = "NL"
      ids.push "CA-#{prov}"
    # console.log sByC
    subunits.features = _.filter subunits.features, (feature) ->
      return feature if (_.indexOf(ids, feature.id) isnt -1)

    # Create a unit projection.

    projection = d3.geo.conicConformal().scale(1).rotate([
      105
      0
    ]).translate([
      0
      0
    ])

    # Create a path generator.
    path = d3.geo.path().projection(projection)

    # Compute the bounds of a feature of interest, then derive scale & translate.
    b = path.bounds(subunits)
    s = .95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height)
    t = [
      (width - s * (b[1][0] + b[0][0])) / 2
      (height - s * (b[1][1] + b[0][1])) / 2
    ]

    # Update the projection to use computed scale & translate.
    projection.scale(s).translate t

    mouseover = (d) ->
      d3.select("#" + d.id).transition().duration(100).style "opacity", 0.5
      return

    mouseout = (d) ->
      d3.selectAll("path").transition().duration(100).style "opacity", 1
      return

    mouseoverCity = (d) ->
      size = d3.select(@).attr("r")
      d3.select(@).transition().duration(100).attr("r", (d) ->
        return size * 2)
      showData @, d

    mouseoutCity = (d) ->
      d3.selectAll("circle").transition().duration(100).attr("r", (d) ->
        val =  sByC[d.properties.name].length
        return 6 * val)
      hideData()

    showData = (i, d) ->
      # console.log i
      $("#graph").append("<div class='tip'></div>")
      stationString = ''
      _.each sByC[d.properties.name], (station) ->
        stationString += " #{station}"
      stationString.trim()
      # console.log stationString
      chartTip = d3.select(".tip")
      chartTip.style("left", width - 150 + "px" )
        .style("top", 50 + "px")
        .style("background", color d.properties.name)
      $(".tip")
        .html("""
        City: #{d.properties.name} <br />
        Stations: #{stationString}<br />
        """
        )
      $(".tip").fadeIn(100)

    hideData = ->
      $(".tip").fadeOut().remove()

    clickProv = ->

      filter =
        province: $(this).attr('id').split('-')[1]

      if filter.province is 'NL'
        filter.province = "NF"
      collection.addFilter filter

    clickCity = ->

      filter =
        city : _.reduceRight $(this).attr("class").split(" ")[1..], (word, memo) ->
          memo += " #{word}"

      collection.addFilter filter


    data = topojson.feature(canada, canada.objects.cplaces).features
    # console.log data

    newData = _.filter data, (city) ->
      # console.log city.properties.name
      return false if (city.properties.name is "Windsor" && city.properties.province isnt "Ontario")
      return city if (_.indexOf(cities, city.properties.name) isnt -1)

    foundCities = _.map newData, (item) ->
      return item.properties.name

    svg.selectAll(".subunit")
      .data(subunits.features)
      # .data(topojson.feature(canada, canada.objects.cunits).features)
      .enter().append("path").attr("class", (d) ->
        "subunit " + d.id)
      .attr("id", (d) ->
        d.id)
      .attr("d", path)
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .on "click", clickProv

    svg.selectAll('.city')
      .data(newData)
      .enter().append("circle")
      .attr("class", (d) ->
        return "city #{d.properties.name}")
      .attr("r", (d) ->
        val =  sByC[d.properties.name].length
        return 6 * val)
      .style("fill", (d) ->
        color "#{d.properties.name}")
      .attr("transform", (d) -> return "translate(" + projection(d.geometry.coordinates) + ")")
      .on("mouseover", mouseoverCity)
      .on("mouseout", mouseoutCity)
      .on("click", clickCity)

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
        This map displays all the cities in Canada with Campus Community stations that report to Earshot.<br />
        The size of each dot is relative to the number of stations in that city. <br />
        Using the filters will redraw the map to the selected location(s).<br />
        There are no Earshot reporting stations in the three territories, or on PEI, so they are not displayed. <br />
        Mouseover any city for more information.<br />
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
