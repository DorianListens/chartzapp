mongoose = require 'mongoose'
Schema = mongoose.Schema

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
  appearances: [
    appearanceSchema
    index: true
  ]

# Pre Save Hooks

# Setup slugs and lowercases on save

albumSchema.pre 'save', (next) ->
  self = @
  self.artistLower = self.artist.toLowerCase() unless self.isNull
  self.albumLower = self.album.toLowerCase() unless self.isNull
  self.labelLower = self.label.toLowerCase() unless self.isNull
  slugText = "#{self.artist} #{self.album}"
  self.slug = slugify slugText
  next()


# Recalculate "total points" on every save

albumSchema.pre 'save', (next) ->
  self = @
  if self.totalPoints is undefined
    self.totalPoints = 0
  pointSum = 0
  for appearance in @appearances
    do (appearance) ->
      pointSum += (31 - parseInt(appearance.position))
  self.totalPoints = pointSum
  next()

# Init Hooks

# Set current points on every load ###

albumSchema.post 'init', ->
  self = @
  if self.points is undefined
    self.points = 0
  pointSum = 0
  for appearance in @appearances
    do (appearance) ->
      pointSum += (31 - +appearance.position)
  self.points = pointSum

# Instantiate

Album = mongoose.model 'Album', albumSchema

# Export

module.exports = Album
