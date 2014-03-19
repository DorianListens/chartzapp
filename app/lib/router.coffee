application = require('application')
HomeView = require('views/HomeView')
HeaderView = require('views/HeaderView')
FooterView = require('views/FooterView')

module.exports = class Router extends Backbone.Router

  routes:
    '': 'home'

  home: =>
    hv = new HomeView()
    header = new HeaderView()
    footer = new FooterView()
    application.layout.header.show(header)
    application.layout.content.show(hv)
    application.layout.footer.show(footer)
