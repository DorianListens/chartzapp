###
#
#
# The Main Album Model file, defining albums and appearances.
#
#
###

mongoose = require 'mongoose'
util = require '../util'
Schema = mongoose.Schema
moment = require 'moment'
_ = require 'underscore'

appearanceSchema = new Schema
  week: String
  station: String
  position: String

albumSchema = new Schema
  slug: String
  isNull:
    type: Boolean
    default: false
  artist: String
  artistLower:
    type: String
    lowercase: true
    index: true
  album: String
  albumLower: String
  label: String
  labelLower:
    type: String
    index: true
    lowercase: true
  points: Number
  totalPoints: Number
  currentPos: Number
  firstWeek: String
  appearances: [
    appearanceSchema
    index: true
  ]

# Pre Save Hooks

# Setup slugs and lowercases on save

albumSchema.pre 'save', (next) ->
  self = @
  self.points = 0 unless self.points
  self.artistLower = self.artist.toLowerCase() unless self.isNull
  self.albumLower = self.album.toLowerCase() unless self.isNull
  self.labelLower = self.label.toLowerCase() unless self.isNull
  slugText = "#{self.artist} #{self.album}"
  self.slug = util.slugify slugText
  next()

albumSchema.pre 'save', (next) ->
  self = @
  @appearances.sort (a, b) ->
    a = moment a.week
    b = moment b.week
    return 0 if a is b
    if a > b then -1 else 1
  oldap = {}
  _.each @appearances, (ap) ->
    if (ap.week is oldap.week) and (ap.station is oldap.station) and (ap.position is oldap.position)
      console.log "found duplicate", ap.week, ap.station, ap.position, self.artist
    oldap = ap
  # _.each @appearances
  next()


# Recalculate "total points" + first week on every save

albumSchema.pre 'save', (next) ->
  self = @
  if self.totalPoints is undefined
    self.totalPoints = 0
  pointSum = 0
  weeks = []
  for appearance in @appearances
    do (appearance) ->
      pointSum += (31 - parseInt(appearance.position))
      weeks.push appearance.week
  weeks.sort (a, b) ->
    a = moment(a)
    b = moment(b)
    return 0 if a is b
    if a > b then 1 else -1
  @firstWeek = weeks[0]
  self.totalPoints = pointSum
  next()

# Init Hooks

# Set current points on every load ###

# albumSchema.post 'init', ->
#   self = @
#   if self.points is undefined
#     self.points = 0
#   pointSum = 0
#   for appearance in @appearances
#     do (appearance) ->
#       pointSum += (31 - +appearance.position)
#   self.points = pointSum

# Instantiate

Album = mongoose.model 'Album', albumSchema

# Export

module.exports = Album
