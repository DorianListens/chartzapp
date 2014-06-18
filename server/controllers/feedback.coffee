mongoose = require 'mongoose'
nodemailer = require 'nodemailer'

# Setup Mailer Auth
if process.env.G_USER?
  auth =
    user: process.env.G_USER
    pass: process.env.G_PASS
else
  gauth = require '../../.gauth'
  auth = gauth()

# create reusable transport method (opens pool of SMTP connections)

smtpTransport = nodemailer.createTransport("SMTP", auth)

module.exports.controller = (app) ->

  app.post "/api/feedback", (req, res) ->

    # setup e-mail data with unicode symbols
    mailOptions =
      from: "#{req.body.name}"
      replyTo: "#{req.body.email}" # sender address
      to: "dorian.scheidt@gmail.com" # list of receivers
      subject: "Chartzapp Feedback Form" # Subject line
      text: "#{req.body.message} \n\n - #{req.body.name} - #{req.body.email}" # plaintext body

    # send mail with defined transport object
    smtpTransport.sendMail mailOptions, (error, response) ->
      console.error error if error
      console.log "Message sent: ", response.message
      res.send response

      res.end()
