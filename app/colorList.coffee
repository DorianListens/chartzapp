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
  "CFBX": "#8ad08c",
  "CFRO": "#80c47e",
  "CFUR": "#77b972",
  "CHLY": "#6fad66",
  "CFUV": "#67a25b",
  "CITR": "#609651",
  "CIVL": "#598b48",
  "CJLY": "#52803e",
  "CICK": "#4c7436",
  "CJSF": "#45692e",
  "CFMH": "#0165e4",
  "CHMA": "#025bc9",
  "CHSR": "#0351ae",
  "undefined": "#877949",
  "CFMU": "#eba294",
  "CILU": "#e99d8f",
  "CFRU": "#e7988a",
  "CJAM": "#e59386",
  "CHRW": "#e38e81",
  "CHUO": "#e1897d",
  "CIOI": "#df8478",
  "CKCU": "#dd8074",
  "CKMS": "#db7b70",
  "CFBU": "#d9766c",
  "CFRC": "#d77167",
  "CHRY": "#d66c63",
  "CIUT": "#d4675f",
  "CKLU": "#d2625b",
  "CSCR": "#d05d57",
  "CFRE": "#ce5853",
  "RADL": "#cc5450",
  "SCOP": "#ca4f4c",
  "CHMR": "#00FFFF",
  "CHOQ": "#d768db",
  "CHYZ": "#c566d1",
  "CKUT": "#b564c6",
  "CFOU": "#a562bc",
  "CISM": "#975fb1",
  "CJLO": "#8a5ca7",
  "CJMQ": "#7d589c",
  "CFCR": "#e3a667",
  "CFXU": "#20a3fe",
  "CAPR": "#40c8fe",
  "CKDU": "#60e4fd",
  "CJSR": "#ebe06e",
  "CKUA": "#e4da74",
  "CKXU": "#ddd479",
  "CJSW": "#d7ce7d",
  "CJUM": "#cc9f61",
  "CKUW": "#b5945a"

cityColors =
  "Nanaimo": "#8ad08c",
  "Victoria": "#80c47e",
  "Vancouver": "#77b972",
  "Burnaby": "#67a25b",
  "Abbotsford": "#609651",
  "Prince George": "#598b48",
  "Kamloops": "#52803e",
  "Nelson": "#4c7436",
  "Smithers": "#45692e",
  "Edmonton": "#ebe06e",
  "Calgary": "#ddd479",
  "Lethbridge": "#d7ce7d",
  "Saskatoon": "#e3a667",
  "Winnipeg": "#cc9f61",
  "Thunder Bay": "#eba294",
  "Sudbury": "#e99d8f",
  "Windsor": "#e7988a",
  "London": "#e59386",
  "Waterloo": "#e38e81",
  "Guelph": "#df8478",
  "Toronto": "#dd8074",
  "North York": "#d9766c",
  "Hamilton": "#d66c63",
  "Mississauga": "#d2625b",
  "St. Catharines": "#d05d57",
  "Kingston": "#ce5853",
  "Ottawa": "#cc5450",
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
  "St. John's": "#22fc32"
