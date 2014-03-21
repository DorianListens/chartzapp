exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  # paths:
  #   watched: ['app']
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^(vendors)/
        'test/javascripts/test.js': /^test[\\/](?!vendor)/
        'test/javascripts/test-vendor.js': /^test[\\/](?=vendor)/
      order:
        before: [
          'vendors/scripts/console-helper.js'
          'vendors/scripts/modernizr.js'
          'vendors/scripts/jquery.js'
          'vendors/scripts/underscore.js'
          'vendors/scripts/backbone.js'
          'vendors/scripts/backbone.marionette.js'
        ]
        after: [
          'test/vendor/scripts/test-helper.js'
        ]

    stylesheets:
      defaultExtension: 'scss'
      joinTo:
        'stylesheets/app.css': /^app(\/|\\)views(\/|\\)styles(\/|\\)/
        'stylesheets/vendor.css': /^vendors(\/|\\)styles/
        'test/stylesheets/vendor.css': /^test(\/|\\)vendor(\/|\\)styles(\/|\\)/
      order:
        before: []
        after: []

    templates:
      defaultExtension: 'hbs'
      joinTo: 'javascripts/app.js'

  server:
    path: 'server.coffee'
    port: 3333
    base: '/'
    run: true
