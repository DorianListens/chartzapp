mongoose = require 'mongoose'
Schema = mongoose.Schema

stationSchema = new Schema
  name:
    index: true
    type: String
  content: String
  website: String
  fullName: String
  frequency: String
  email: [String]
  streetAddress: String
  city: String
  postalCode: String
  fax: String
  province: String
  totalCharts = String

Station = mongoose.model 'Station', stationSchema

module.exports = Station
