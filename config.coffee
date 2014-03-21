exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^(vendor|bower_components)/
        'test/javascripts/test.js': /^test[\\/](?!vendor)/
        'test/javascripts/test-vendor.js': /^test[\\/](?=vendor)/
      order:
        before: [
          'vendor/scripts/console-helper.js'
          'bower_components/modernizr/modernizr.js'
          'vendor/scripts/jquery.js'
          'vendor/scripts/underscore.js'
          'vendor/scripts/backbone.js'
          'vendor/scripts/backbone.marionette.js'
    
        ]
        after: [
          'test/vendor/scripts/test-helper.js'
        ]

    stylesheets:
      defaultExtension: 'scss'
      joinTo:
        'stylesheets/app.css': /^app(\/|\\)views(\/|\\)styles(\/|\\)/
        'stylesheets/vendor.css': /^vendor(\/|\\)styles/
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
