# ChartZapp

A simple web application for interacting with Canadian Campus Radio Charts.

All data is scraped (with love and admiration) from [Earshot Online](http://earshot-online.com).

Currently under development.

## Stack

Build:
* [Brunch](brunch.io)

Lang:
* [CoffeeScript](http://coffeescript.org/)

Back-End:
* [Node](http://nodejs.org/)
* [Express](http://expressjs.com/)
* [MongoDB](https://www.mongodb.org/)
* [Mongoose](http://mongoosejs.com/)

Front-End:
* [Backbone](http://backbonejs.org/)
* [Marionette](http://marionettejs.com/)
* [Handlebars](http://handlebarsjs.com/)
* [Foundation](https://github.com/zurb/foundation)
* [D3](http://d3js.org)

Analytics:
* [Google Analytics](http://www.google.ca/analytics/)
* [New Relic](http://newrelic.com/)


## To Install


```
npm install -g brunch
git clone https://github.com/DorianListens/chartzapp path/to/local
cd path/to/local
npm install
brunch build
brunch watch -server
```

Navigate to localhost:8888, and you should have yourself a local copy!
Brunch will automatically compile yr stylesheets and js/coffee files.
If you make any updates to the backend, you'll need to restart brunch to serve
the new server code.

Instructions for DB setup coming soon. 
