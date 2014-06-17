stationList = require 'stationList'

color = d3.scale.category20c()
color2 = d3.scale.category20b()
color3 = d3.scale.category20()
fullRange = color.range()
cRange = color2.range()
cRange.forEach (c) ->
  fullRange.push c
c3Range = color3.range()
c3Range.forEach (c) ->
  fullRange.push c
color.range fullRange



colorList = {}
_.each stationList, (station) ->
  colorList[station.toLowerCase()] = color station

colors = (station) ->
  # if typeof(station) is "string"
  #   station = station.toUpperCase()
  # console.log stationColors[station.toUpperCase()]
  if typeof station is "string" and stationColors[station.toUpperCase()]
    return stationColors[station.toUpperCase()]
  else if cityColors[station]
    return cityColors[station]
  else
    color.range fullRange.sort()
    return color station

module.exports = colors


# (BC) Dark Greens = ['#01f225', '#02e619', '#03d90e', '#04cc04', '#0ebf05', '#17b305', '#1ea606', '#239906', '#288c06', '#2b8006']
#
# (AB) Yellows = ['#fcd91c', '#fae737', '#f7f152', '#f2f56c', '#e9f285']
#
# (SK + MB) Oranges = ['#fc9a1c', '#faad37', '#f7bd52', '#f5ca6c', '#f2d585']
#
# (ON) Reds = ['#f70600', '#ef0b00', '#e71000', '#de1400', '#d61901', '#ce1c01', '#c62001', '#be2301', '#b62501', '#ad2801', '#a52a01', '#9d2b01', '#952c01', '#8d2d01', '#852d01', '#7c2d01', '#742d01', '#6c2c01', '#642b01', '#5c2a01']
#
# (QC) Violets = ['#8900e8', '#a301d1', '#b501ba', '#a30189', '#8c015c']
#
# (NB) Indigo = ['#20a3fe', '#40c8fe', '#60e4fd', '#7ff8fd', '#9ffcf5']
#
# (NS) Blues = ['#0165e4', '#025bc9', '#0351ae', '#044593', '#043a78']
#
# (NL) Light Greens = ['#22fc32', '#4efa44', '#7ff765', '#a7f585', '#c6f2a5']

colorBox =
  BC: ['#8ad08c', '#80c47e', '#77b972', '#6fad66', '#67a25b', '#609651', '#598b48', '#52803e', '#4c7436', '#45692e']
  AB: ['#d5d075', '#c1bb73', '#aea770', '#9b946b', '#878164']
  SK: ['#e3a667']
  MB: ['#cc9f61', '#b5945a', '#9e8752',  '#877949']
  ON: ['#e9817d', '#e37b74', '#dd776b', '#d67263', '#d06e5b', '#c96b53', '#c3684c', '#bd6545', '#b6623e', '#b06037', '#aa5d31', '#a35b2b', '#9d5926', '#965821', '#90561c', '#8a5417', '#835313', '#7d510f', '#774f0b', '#704d08']
  QC: ['#d768db', '#c566d1', '#b564c6', '#a562bc', '#975fb1', '#8a5ca7', '#7d589c', '#725592', '#675187', '#5c4c7d']
  NB: ['#20a3fe', '#40c8fe', '#60e4fd', '#7ff8fd', '#9ffcf5']
  NS: ['#0165e4', '#025bc9', '#0351ae', '#044593', '#043a78']
  NL: ['#22fc32', '#4efa44', '#7ff765', '#a7f585', '#c6f2a5']

# cList = []
#
# _.each colorBox, (list) ->
#   cList.push list
#
# cList = _.flatten cList
# uList = _.uniq cList

# console.log _.difference cList, uList


stationColors =

  "CHLY": "#45692e",
  "CFUV": "#4c7436",
  "CITR": "#52803e",
  "CFRO": "#598b48",
  "CJSF": "#609651",
  "CIVL": "#67a25b",
  "CFUR": "#6fad66",
  "CFBX": "#77b972",
  "CJLY": "#80c47e",
  "CICK": "#8ad08c",
  "CJSR": "#ebe06e",
  "CKUA": "#e4da74",
  "CJSW": "#ddd479",
  "CKXU": "#d7ce7d",
  "undefined": "#c6f2a5",
  "CFCR": "#e7DEB2",
  "CJUM": "#cc9f61",
  "CKUW": "#ca6400",
  "CILU": "#c64544",
  "CKLU": "#c84a48",
  "CJAM": "#ca4f4c",
  "CHRW": "#cc5450",
  "RADL": "#ce5853",
  "CKMS": "#d05d57",
  "CFRU": "#d2625b",
  "CIUT": "#d4675f",
  "SCOP": "#d66c63",
  "CHRY": "#d77167",
  "CSCR": "#d9766c",
  "CFMU": "#db7b70",
  "CIOI": "#dd8074",
  "CFRE": "#df8478",
  "CFBU": "#e1897d",
  "CFRC": "#e38e81",
  "CKCU": "#e59386",
  "CHUO": "#e7988a",
  "CJMQ": "#d768db",
  "CJLO": "#c566d1",
  "CHOQ": "#b564c6",
  "CISM": "#a562bc",
  "CKUT": "#975fb1",
  "CFOU": "#8a5ca7",
  "CHYZ": "#7d589c",
  "CHMA": "#0165e4",
  "CHSR": "#025bc9",
  "CFMH": "#0351ae",
  "CKDU": "#20a3fe",
  "CFXU": "#40c8fe",
  "CAPR": "#60e4fd",
  "CHMR": "#00FFFF"

cityColors =
  "Nanaimo": "#45692e",
  "Victoria": "#4c7436",
  "Vancouver": "#52803e",
  "Burnaby": "#609651",
  "Abbotsford": "#67a25b",
  "Prince George": "#6fad66",
  "Kamloops": "#77b972",
  "Nelson": "#80c47e",
  "Smithers": "#8ad08c",
  "Edmonton": "#ebe06e",
  "Calgary": "#ddd479",
  "Lethbridge": "#d7ce7d",
  "Saskatoon": "#e7DEB2",
  "Winnipeg": "#cc9f61",
  "Thunder Bay": "#c64544",
  "Sudbury": "#c84a48",
  "Windsor": "#ca4f4c",
  "London": "#cc5450",
  "Waterloo": "#ce5853",
  "Guelph": "#d2625b",
  "Toronto": "#d4675f",
  "North York": "#d77167",
  "Hamilton": "#db7b70",
  "Mississauga": "#df8478",
  "St. Catharines": "#e1897d",
  "Kingston": "#e38e81",
  "Ottawa": "#e59386",
  "Sherbrooke": "#d768db",
  "Montreal": "#c566d1",
  "Trois-Rivieres": "#8a5ca7",
  "Québec": "#7d589c",
  "Sackville": "#0165e4",
  "Fredericton": "#025bc9",
  "Saint John": "#0351ae",
  "Halifax": "#20a3fe",
  "Antigonish": "#40c8fe",
  "Sydney": "#60e4fd",
  "St. John's": "#00FFFF"
