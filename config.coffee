exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  plugins:
    coffeelint:
      pattern: /^app\/.*\.coffee$/
      options:
        indentation:
          level: "warn"
          value: 2
        no_tabs:
          level: "ignore"
        max_line_length:
          level: "warn"
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/app.js': /^app/

        # the Heroku node build adds node stuff inside /vendor
        # Make sure to ignore it.

        'javascripts/vendor.js': /^(vendor\/(?!node))/
        'test/javascripts/test.js': /^test[\\/](?!vendor)/
        'test/javascripts/test-vendor.js': /^test[\\/](?=vendor)/
      order:
        before: [
          'vendor/scripts/console-helper.js'
          'vendor/scripts/modernizr.js'
          'vendor/scripts/jquery.js'
          'vendor/scripts/underscore.js'
          'vendor/scripts/backbone.js'
          'vendor/scripts/backbone.marionette.js'
          'vendor/scripts/spin.js'
          'vendor/scripts/foundation.js'
          'vendor/scripts/foundation/*'
          'vendor/scripts/moment.js'
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
        before: [
          'app/views/styles/foundation.scss'
        ]
        after: [
          # "app/views/styles/station.scss"
        ]

    templates:
      defaultExtension: 'hbs'
      joinTo: 'javascripts/app.js'

  server:
    path: 'server.coffee'
    port: 3333
    base: '/'
    run: true
