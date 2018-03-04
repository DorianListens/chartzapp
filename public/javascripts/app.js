(function() {
  'use strict';

  var globals = typeof global === 'undefined' ? self : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};
  var aliases = {};
  var has = {}.hasOwnProperty;

  var expRe = /^\.\.?(\/|$)/;
  var expand = function(root, name) {
    var results = [], part;
    var parts = (expRe.test(name) ? root + '/' + name : name).split('/');
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function expanded(name) {
      var absolute = expand(dirname(path), name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var hot = hmr && hmr.createHot(name);
    var module = {id: name, exports: {}, hot: hot};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var expandAlias = function(name) {
    return aliases[name] ? expandAlias(aliases[name]) : name;
  };

  var _resolve = function(name, dep) {
    return expandAlias(expand(dirname(name), dep));
  };

  var require = function(name, loaderPath) {
    if (loaderPath == null) loaderPath = '/';
    var path = expandAlias(name);

    if (has.call(cache, path)) return cache[path].exports;
    if (has.call(modules, path)) return initModule(path, modules[path]);

    throw new Error("Cannot find module '" + name + "' from '" + loaderPath + "'");
  };

  require.alias = function(from, to) {
    aliases[to] = from;
  };

  var extRe = /\.[^.\/]+$/;
  var indexRe = /\/index(\.[^\/]+)?$/;
  var addExtensions = function(bundle) {
    if (extRe.test(bundle)) {
      var alias = bundle.replace(extRe, '');
      if (!has.call(aliases, alias) || aliases[alias].replace(extRe, '') === alias + '/index') {
        aliases[alias] = bundle;
      }
    }

    if (indexRe.test(bundle)) {
      var iAlias = bundle.replace(indexRe, '');
      if (!has.call(aliases, iAlias)) {
        aliases[iAlias] = bundle;
      }
    }
  };

  require.register = require.define = function(bundle, fn) {
    if (bundle && typeof bundle === 'object') {
      for (var key in bundle) {
        if (has.call(bundle, key)) {
          require.register(key, bundle[key]);
        }
      }
    } else {
      modules[bundle] = fn;
      delete cache[bundle];
      addExtensions(bundle);
    }
  };

  require.list = function() {
    var list = [];
    for (var item in modules) {
      if (has.call(modules, item)) {
        list.push(item);
      }
    }
    return list;
  };

  var hmr = globals._hmr && new globals._hmr(_resolve, require, modules, cache);
  require._cache = cache;
  require.hmr = hmr && hmr.wrap;
  require.brunch = true;
  globals.require = require;
})();

(function() {
var global = typeof window === 'undefined' ? this : window;
var __makeRelativeRequire = function(require, mappings, pref) {
  var none = {};
  var tryReq = function(name, pref) {
    var val;
    try {
      val = require(pref + '/node_modules/' + name);
      return val;
    } catch (e) {
      if (e.toString().indexOf('Cannot find module') === -1) {
        throw e;
      }

      if (pref.indexOf('node_modules') !== -1) {
        var s = pref.split('/');
        var i = s.lastIndexOf('node_modules');
        var newPref = s.slice(0, i).join('/');
        return tryReq(name, newPref);
      }
    }
    return none;
  };
  return function(name) {
    if (name in mappings) name = mappings[name];
    if (!name) return;
    if (name[0] !== '.' && pref) {
      var val = tryReq(name, pref);
      if (val !== none) return val;
    }
    return require(name);
  }
};
require.register("application.coffee", function(exports, require, module) {
var App, Application, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

require('lib/view_helper');

Application = (function(_super) {
  __extends(Application, _super);

  function Application() {
    this.initialize = __bind(this.initialize, this);
    _ref = Application.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Application.prototype.initialize = function() {
    var _this = this;
    this.rootRoute = "home";
    this.on("initialize:after", function(options) {
      this.startHistory();
      if (!this.getCurrentRoute()) {
        this.navigate(this.rootRoute, {
          trigger: true,
          init: true
        });
      }
      return typeof Object.freeze === "function" ? Object.freeze(this) : void 0;
    });
    this.addRegions({
      headerRegion: "#header-region",
      mainRegion: "#main-region",
      footerRegion: "#footer-region"
    });
    this.mainRegion.open = function(view) {
      this.$el.hide();
      if (view.el.id !== "loadingView") {
        this.$el.fadeOut("slow");
        this.$el.html(view.el).css({
          'opacity': 0
        });
        this.$el.show();
        return this.$el.fadeTo("slow", 1);
      } else {
        return this.$el.show();
      }
    };
    this.reqres.setHandler("default:region", function() {
      return _this.mainRegion;
    });
    this.addInitializer(function() {
      _this.module('HeaderApp').start();
      return _this.module('FooterApp').start();
    });
    return this.start();
  };

  return Application;

})(Backbone.Marionette.Application);

App = new Application();

App.commands.setHandler("register:instance", function(instance, id) {
  return App.register(instance, id);
});

App.commands.setHandler("unregister:instance", function(instance, id) {
  return App.unregister(instance, id);
});

App.rootRoute = '';

module.exports = App;

Date.prototype.yyyymmdd = function() {
  var dd, mm, yyyy;
  yyyy = this.getFullYear().toString();
  mm = (this.getMonth() + 1).toString();
  dd = this.getDate().toString();
  return yyyy + "-" + (mm[1] ? mm : "0" + mm[0]) + "-" + (dd[1] ? dd : "0" + dd[0]);
};

require('controllers/baseController');

require('entities/entities');

require('components/loading/loading');

require('modules/header/header_app');

require('modules/footer/footer_app');

require('modules/about/about_app');

require('modules/artists/artists_app');

require('modules/station/station_app');

require('modules/landing/landing_app');

});

require.register("colorList.coffee", function(exports, require, module) {
var c3Range, cRange, cityColors, color, color2, color3, colorBox, colorList, colors, fullRange, stationColors, stationList;

stationList = require('lib/stationList');

color = d3.scale.category20c();

color2 = d3.scale.category20b();

color3 = d3.scale.category20();

fullRange = color.range();

cRange = color2.range();

cRange.forEach(function(c) {
  return fullRange.push(c);
});

c3Range = color3.range();

c3Range.forEach(function(c) {
  return fullRange.push(c);
});

color.range(fullRange);

colorList = {};

_.each(stationList, function(station) {
  return colorList[station.toLowerCase()] = color(station);
});

colors = function(station) {
  if (typeof station === "string" && stationColors[station.toUpperCase()]) {
    return stationColors[station.toUpperCase()];
  } else if (cityColors[station]) {
    return cityColors[station];
  } else {
    color.range(fullRange.sort());
    return color(station);
  }
};

module.exports = colors;

colorBox = {
  BC: ['#8ad08c', '#80c47e', '#77b972', '#6fad66', '#67a25b', '#609651', '#598b48', '#52803e', '#4c7436', '#45692e'],
  AB: ['#d5d075', '#c1bb73', '#aea770', '#9b946b', '#878164'],
  SK: ['#e3a667'],
  MB: ['#cc9f61', '#b5945a', '#9e8752', '#877949'],
  ON: ['#e9817d', '#e37b74', '#dd776b', '#d67263', '#d06e5b', '#c96b53', '#c3684c', '#bd6545', '#b6623e', '#b06037', '#aa5d31', '#a35b2b', '#9d5926', '#965821', '#90561c', '#8a5417', '#835313', '#7d510f', '#774f0b', '#704d08'],
  QC: ['#d768db', '#c566d1', '#b564c6', '#a562bc', '#975fb1', '#8a5ca7', '#7d589c', '#725592', '#675187', '#5c4c7d'],
  NB: ['#20a3fe', '#40c8fe', '#60e4fd', '#7ff8fd', '#9ffcf5'],
  NS: ['#0165e4', '#025bc9', '#0351ae', '#044593', '#043a78'],
  NL: ['#22fc32', '#4efa44', '#7ff765', '#a7f585', '#c6f2a5']
};

stationColors = {
  "CHLY": "#45692e",
  "CFUV": "#4c7436",
  "CITR": "#52803e",
  "CFRO": "#598b48",
  "CJSF": "#609651",
  "CIVL": "#67a25b",
  "CFUR": "#6fad66",
  "CFBX": "#77b972",
  "CJLY": "#80c47e",
  "CICK": "#8ad08c",
  "CJSR": "#ebe06e",
  "CKUA": "#e4da74",
  "CJSW": "#ddd479",
  "CKXU": "#d7ce7d",
  "undefined": "#c6f2a5",
  "CFCR": "#e7DEB2",
  "CJUM": "#cc9f61",
  "CKUW": "#ca6400",
  "CILU": "#c64544",
  "CKLU": "#c84a48",
  "CJAM": "#ca4f4c",
  "CHRW": "#cc5450",
  "RADL": "#ce5853",
  "CKMS": "#d05d57",
  "CFRU": "#d2625b",
  "CIUT": "#d4675f",
  "SCOP": "#d66c63",
  "CHRY": "#d77167",
  "CSCR": "#d9766c",
  "CFMU": "#db7b70",
  "CIOI": "#dd8074",
  "CFRE": "#df8478",
  "CFBU": "#e1897d",
  "CFRC": "#e38e81",
  "CKCU": "#e59386",
  "CHUO": "#e7988a",
  "CJMQ": "#d768db",
  "CJLO": "#c566d1",
  "CHOQ": "#b564c6",
  "CISM": "#a562bc",
  "CKUT": "#975fb1",
  "CFOU": "#8a5ca7",
  "CHYZ": "#7d589c",
  "CHMA": "#0165e4",
  "CHSR": "#025bc9",
  "CFMH": "#0351ae",
  "CKDU": "#20a3fe",
  "CFXU": "#40c8fe",
  "CAPR": "#60e4fd",
  "CHMR": "#00FFFF"
};

cityColors = {
  "Nanaimo": "#45692e",
  "Victoria": "#4c7436",
  "Vancouver": "#52803e",
  "Burnaby": "#609651",
  "Abbotsford": "#67a25b",
  "Prince George": "#6fad66",
  "Kamloops": "#77b972",
  "Nelson": "#80c47e",
  "Smithers": "#8ad08c",
  "Edmonton": "#ebe06e",
  "Calgary": "#ddd479",
  "Lethbridge": "#d7ce7d",
  "Saskatoon": "#e7DEB2",
  "Winnipeg": "#cc9f61",
  "Thunder Bay": "#c64544",
  "Sudbury": "#c84a48",
  "Windsor": "#ca4f4c",
  "London": "#cc5450",
  "Waterloo": "#ce5853",
  "Guelph": "#d2625b",
  "Toronto": "#d4675f",
  "North York": "#d77167",
  "Hamilton": "#db7b70",
  "Mississauga": "#df8478",
  "St. Catharines": "#e1897d",
  "Kingston": "#e38e81",
  "Ottawa": "#e59386",
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
  "St. John's": "#00FFFF"
};

});

require.register("components/loading/loading.coffee", function(exports, require, module) {
var App, Controllers,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('application');

Controllers = require('controllers/baseController');

module.exports = App.module("Components.Loading", function(Loading, App, Backbone, Marionette, $, _) {
  var _ref, _ref1;
  Loading.LoadingController = (function(_super) {
    __extends(LoadingController, _super);

    function LoadingController() {
      _ref = LoadingController.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    LoadingController.prototype.initialize = function(options) {
      var config, loadingView, view;
      view = options.view, config = options.config;
      config = _.isBoolean(config) ? {} : config;
      _.defaults(config, {
        loadingType: "spinner",
        entities: this.getEntities(view),
        debug: false
      });
      switch (config.loadingType) {
        case "opacity":
          if (this.region.currentView) {
            this.region.currentView.$el.css("opacity", 0.2);
          }
          break;
        case "spinner":
          loadingView = this.getLoadingView();
          this.show(loadingView);
          break;
        default:
          throw new Error("Invalid loadingType");
      }
      return this.showRealView(view, loadingView, config);
    };

    LoadingController.prototype.showRealView = function(realView, loadingView, config) {
      var _this = this;
      return App.execute("when:fetched", config.entities, function() {
        switch (config.loadingType) {
          case "opacity":
            if (_this.region.currentView) {
              _this.region.currentView.$el.removeAttr("style");
            }
            break;
          case "spinner":
            if (_this.region.currentView !== loadingView) {
              return realView.close();
            }
        }
        if (!config.debug) {
          return _this.show(realView);
        }
      });
    };

    LoadingController.prototype.getEntities = function(view) {
      return _.chain(view).pick("model", "collection").toArray().compact().value();
    };

    LoadingController.prototype.getLoadingView = function() {
      return new Loading.LoadingView;
    };

    return LoadingController;

  })(App.Controllers.Base);
  App.commands.setHandler("show:loading", function(view, options) {
    return new Loading.LoadingController({
      view: view,
      region: options.region,
      config: options.loading
    });
  });
  return Loading.LoadingView = (function(_super) {
    __extends(LoadingView, _super);

    function LoadingView() {
      _ref1 = LoadingView.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    LoadingView.prototype.template = false;

    LoadingView.prototype.className = "loading-container small-1 small-centered columns";

    LoadingView.prototype.id = "loadingView";

    LoadingView.prototype.onShow = function() {
      var opts;
      opts = this._getOptions();
      this.spinner = new Spinner(opts);
      this.spinner.spin();
      return this.$el.append(this.spinner.el);
    };

    LoadingView.prototype.onClose = function() {
      $(document).foundation();
      return this.spinner.stop();
    };

    LoadingView.prototype._getOptions = function() {
      return {
        lines: 10,
        length: 20,
        width: 1,
        radius: 7,
        corners: 1,
        rotate: 9,
        direction: 1,
        color: '#000',
        speed: 1,
        trail: 60,
        shadow: false,
        hwaccel: false,
        className: 'spinner',
        zIndex: 2e9
      };
    };

    return LoadingView;

  })(Marionette.ItemView);
});

});

require.register("controllers/baseController.coffee", function(exports, require, module) {
var App,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('application');

module.exports = App.module("Controllers", function(Controllers, App, Backbone, Marionette, $, _) {
  return Controllers.Base = (function(_super) {
    __extends(Base, _super);

    function Base(options) {
      if (options == null) {
        options = {};
      }
      this.region = options.region || App.request("default:region");
      this._instance_id = _.uniqueId("controller");
      App.execute("register:instance", this, this._instance_id);
      Base.__super__.constructor.apply(this, arguments);
    }

    Base.prototype.close = function() {
      App.execute("unregister:instance", this, this._instance_id);
      return Base.__super__.close.apply(this, arguments);
    };

    Base.prototype.show = function(view, options) {
      if (options == null) {
        options = {};
      }
      _.defaults(options, {
        loading: false,
        region: this.region
      });
      this._setMainView(view);
      return this._manageView(view, options);
    };

    Base.prototype._setMainView = function(view) {
      if (this._mainView) {
        return;
      }
      this._mainView = view;
      return this.listenTo(view, "close", this.close);
    };

    Base.prototype._manageView = function(view, options) {
      if (options.loading) {
        return App.execute("show:loading", view, options);
      } else {
        return options.region.show(view);
      }
    };

    return Base;

  })(Marionette.Controller);
});

});

require.register("entities/entities.coffee", function(exports, require, module) {
var App, mode, potentialWeeks, potentialWeeksCount, tuesify,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('application');

tuesify = function(date) {
  var theDay, theTues, theWeek;
  theWeek = (function() {
    switch (false) {
      case !date:
        return moment(date);
      default:
        return moment();
    }
  })();
  theDay = theWeek.get('day');
  theTues = (function() {
    switch (false) {
      case theDay !== 0:
        return theWeek.day(-5);
      case theDay !== 1:
        return theWeek.day(-5);
      case theDay !== 2:
        return theWeek;
      case !(theDay > 2):
        return theWeek.day(2);
    }
  })();
  theTues = moment(theTues);
  return theTues.format('YYYY-MM-DD');
};

potentialWeeksCount = function(date1, date2) {
  var count;
  date1 = moment(date1);
  date2 = moment(date2);
  if (_.isEqual(date1, date2)) {
    return 1;
  }
  count = 0;
  while (date1 <= date2) {
    count++;
    date1 = moment(date1.day(9));
  }
  return count;
};

potentialWeeks = function(date1, date2) {
  var count, weeks;
  date1 = moment(date1);
  date2 = moment(date2);
  if (_.isEqual(date1, date2)) {
    return [date1.format("YYYY-MM-DD")];
  }
  count = 0;
  weeks = [];
  while (date1 <= date2) {
    weeks.push(date1.format("YYYY-MM-DD"));
    date1 = moment(date1.day(9));
  }
  return weeks;
};

mode = function(array) {
  var el, i, maxCount, modeMap, modes;
  if (array.length === 0) {
    return null;
  }
  modeMap = {};
  maxCount = 1;
  modes = [array[0]];
  i = 0;
  while (i < array.length) {
    el = array[i];
    if (modeMap[el] == null) {
      modeMap[el] = 1;
    } else {
      modeMap[el]++;
    }
    if (modeMap[el] > maxCount) {
      modes = [el];
      maxCount = modeMap[el];
    } else if (modeMap[el] === maxCount) {
      modes.push(el);
      maxCount = modeMap[el];
    }
    i++;
  }
  return modes;
};

module.exports = App.module("Entities", function(Entities, App, Backbone, Marionette, $, _) {
  var API, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
  App.commands.setHandler("when:fetched", function(entities, callback) {
    var xhrs;
    xhrs = _.chain([entities]).flatten().pluck("_fetch").value();
    return $.when.apply($, xhrs).done(function() {
      $(".accordion").on("click", "dd:not(.active)", function(event) {
        return $(this).addClass("active").find(".content").slideToggle("slow");
      });
      return callback();
    });
  });
  Entities.Header = (function(_super) {
    __extends(Header, _super);

    function Header() {
      _ref = Header.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return Header;

  })(Backbone.Model);
  Entities.HeaderCollection = (function(_super) {
    __extends(HeaderCollection, _super);

    function HeaderCollection() {
      _ref1 = HeaderCollection.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    HeaderCollection.prototype.model = Entities.Header;

    return HeaderCollection;

  })(Backbone.Collection);
  Entities.ChartItem = (function(_super) {
    __extends(ChartItem, _super);

    function ChartItem() {
      _ref2 = ChartItem.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    ChartItem.prototype.initialize = function() {
      var obj, theCount, _fn, _i, _len, _ref3;
      theCount = 0;
      this.set("rank", this.get("currentPos"));
      _ref3 = this.get("appearances");
      _fn = function(obj) {
        var points;
        points = 0;
        points = 31 - (parseInt(obj.position));
        return theCount += points;
      };
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        obj = _ref3[_i];
        _fn(obj);
      }
      return this.set("frontPoints", theCount);
    };

    return ChartItem;

  })(Backbone.Model);
  Entities.ChartCollection = (function(_super) {
    __extends(ChartCollection, _super);

    function ChartCollection() {
      _ref3 = ChartCollection.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    ChartCollection.prototype.model = Entities.ChartItem;

    ChartCollection.prototype.sortAttr = "points";

    ChartCollection.prototype.sortDir = -1;

    ChartCollection.prototype.sortCharts = function(attr) {
      this.sortAttr = attr;
      this.sort();
      return this.trigger("reset");
    };

    ChartCollection.prototype.comparator = function(a, b) {
      a = a.get(this.sortAttr);
      b = b.get(this.sortAttr);
      if (a === b) {
        return 0;
      }
      if (this.sortDir === 1) {
        if (a > b) {
          return 1;
        } else {
          return -1;
        }
      } else {
        if (a > b) {
          return -1;
        } else {
          return 1;
        }
      }
    };

    return ChartCollection;

  })(Backbone.Collection);
  Entities.Album = (function(_super) {
    __extends(Album, _super);

    function Album() {
      _ref4 = Album.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    Album.prototype.initialize = function() {
      return this.getAppearances();
    };

    Album.prototype.getAppearances = function() {
      var appearances;
      appearances = this.get("appearances");
      return this.set("appearancesCollection", new Entities.Appearances(appearances));
    };

    return Album;

  })(Backbone.Model);
  Entities.ArtistCollection = (function(_super) {
    __extends(ArtistCollection, _super);

    function ArtistCollection() {
      _ref5 = ArtistCollection.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    ArtistCollection.prototype.model = Entities.Album;

    ArtistCollection.prototype.filterFacets = ["album", "label", "slug"];

    ArtistCollection.prototype.countPoints = function() {
      var appearance, model, _fn, _fn1, _i, _j, _k, _len, _len1, _len2, _ref6, _ref7, _ref8, _results,
        _this = this;
      this.popAlbum = '';
      this.popAlbumNumber = 0;
      this.totalChartScore = 0;
      this.totalAppearances = 0;
      this.stations = [];
      this.popStation = '';
      _ref6 = this.models;
      _fn = function(model) {};
      for (_i = 0, _len = _ref6.length; _i < _len; _i++) {
        model = _ref6[_i];
        _fn(model);
        this.totalChartScore += model.get("totalPoints");
        this.totalAppearances += model.attributes.appearances.length;
        if (model.attributes.appearances.length > this.popAlbumNumber) {
          this.popAlbum = model.get("album");
          this.popAlbumNumber = model.attributes.appearances.length;
        }
        _ref7 = model.attributes.appearances;
        _fn1 = function(appearance) {
          return _this.stations.push(appearance.station.toUpperCase());
        };
        for (_j = 0, _len1 = _ref7.length; _j < _len1; _j++) {
          appearance = _ref7[_j];
          _fn1(appearance);
        }
        this.popStation = mode(this.stations);
      }
      _ref8 = this.models;
      _results = [];
      for (_k = 0, _len2 = _ref8.length; _k < _len2; _k++) {
        model = _ref8[_k];
        _results.push((function(model) {
          model.set("totalChartScore", _this.totalChartScore);
          model.set("totalAppearances", _this.totalAppearances);
          model.set("popAlbum", _this.popAlbum);
          return model.set("popStation", _this.popStation);
        })(model));
      }
      return _results;
    };

    return ArtistCollection;

  })(Backbone.FacetedSearchCollection);
  Entities.Appearance = (function(_super) {
    __extends(Appearance, _super);

    function Appearance() {
      _ref6 = Appearance.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    return Appearance;

  })(Backbone.Model);
  Entities.Appearances = (function(_super) {
    __extends(Appearances, _super);

    function Appearances() {
      _ref7 = Appearances.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    Appearances.prototype.model = Entities.Appearance;

    Appearances.prototype.filterFacets = ["station", 'position', 'week'];

    Appearances.prototype.sortAttr = "week";

    Appearances.prototype.sortDir = -1;

    Appearances.prototype.sortCharts = function(attr) {
      this.sortAttr = attr;
      this.sort();
      return this.trigger("reset");
    };

    Appearances.prototype.comparator = function(a, b) {
      if (this.sortAttr === 'position') {
        a = +a.get(this.sortAttr);
        b = +b.get(this.sortAttr);
      } else {
        a = a.get(this.sortAttr);
        b = b.get(this.sortAttr);
      }
      if (a === b) {
        return 0;
      }
      if (this.sortDir === 1) {
        if (a > b) {
          return 1;
        } else {
          return -1;
        }
      } else {
        if (a > b) {
          return -1;
        } else {
          return 1;
        }
      }
    };

    return Appearances;

  })(Backbone.FacetedSearchCollection);
  Entities.StationItem = (function(_super) {
    __extends(StationItem, _super);

    function StationItem() {
      _ref8 = StationItem.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    return StationItem;

  })(Backbone.Model);
  Entities.SingleStation = (function(_super) {
    __extends(SingleStation, _super);

    function SingleStation() {
      _ref9 = SingleStation.__super__.constructor.apply(this, arguments);
      return _ref9;
    }

    SingleStation.prototype.model = Entities.StationItem;

    return SingleStation;

  })(Backbone.Collection);
  Entities.DateItem = (function(_super) {
    __extends(DateItem, _super);

    function DateItem() {
      _ref10 = DateItem.__super__.constructor.apply(this, arguments);
      return _ref10;
    }

    return DateItem;

  })(Backbone.Model);
  Entities.SingleDate = (function(_super) {
    __extends(SingleDate, _super);

    function SingleDate() {
      _ref11 = SingleDate.__super__.constructor.apply(this, arguments);
      return _ref11;
    }

    SingleDate.prototype.model = Entities.DateItem;

    return SingleDate;

  })(Backbone.Collection);
  Entities.Station = (function(_super) {
    __extends(Station, _super);

    function Station() {
      _ref12 = Station.__super__.constructor.apply(this, arguments);
      return _ref12;
    }

    return Station;

  })(Backbone.Model);
  Entities.Stations = (function(_super) {
    __extends(Stations, _super);

    function Stations() {
      _ref13 = Stations.__super__.constructor.apply(this, arguments);
      return _ref13;
    }

    Stations.prototype.model = Entities.Station;

    Stations.prototype.filterFacets = ['name', 'province', 'city'];

    Stations.prototype.sortAttr = "postalCode";

    Stations.prototype.sortDir = -1;

    Stations.prototype.sortCharts = function(attr) {
      this.sortAttr = attr;
      this.sort();
      return this.trigger("reset");
    };

    Stations.prototype.comparator = function(a, b) {
      if (this.sortAttr === 'position') {
        a = +a.get(this.sortAttr);
        b = +b.get(this.sortAttr);
      } else {
        a = a.get(this.sortAttr);
        b = b.get(this.sortAttr);
      }
      if (a === b) {
        return 0;
      }
      if (this.sortDir === 1) {
        if (a > b) {
          return 1;
        } else {
          return -1;
        }
      } else {
        if (a > b) {
          return -1;
        } else {
          return 1;
        }
      }
    };

    return Stations;

  })(Backbone.FacetedSearchCollection);
  Entities.Label = (function(_super) {
    __extends(Label, _super);

    function Label() {
      _ref14 = Label.__super__.constructor.apply(this, arguments);
      return _ref14;
    }

    return Label;

  })(Backbone.Model);
  Entities.LabelCollection = (function(_super) {
    __extends(LabelCollection, _super);

    function LabelCollection() {
      _ref15 = LabelCollection.__super__.constructor.apply(this, arguments);
      return _ref15;
    }

    LabelCollection.prototype.model = Entities.Label;

    LabelCollection.prototype.filterFacets = ["album", "artist", "appearances"];

    return LabelCollection;

  })(Backbone.FacetedSearchCollection);
  Entities.Topx = (function(_super) {
    __extends(Topx, _super);

    function Topx() {
      _ref16 = Topx.__super__.constructor.apply(this, arguments);
      return _ref16;
    }

    Topx.prototype.initialize = function() {
      return this.set({
        info: this.collection.info,
        startDate: this.collection.startDate,
        endDate: this.collection.endDate,
        potential: this.collection.potential,
        percentage: parseInt(this.collection.weeks.length / this.collection.potential * 1000)
      });
    };

    return Topx;

  })(Backbone.Model);
  Entities.TopxCollection = (function(_super) {
    __extends(TopxCollection, _super);

    function TopxCollection() {
      _ref17 = TopxCollection.__super__.constructor.apply(this, arguments);
      return _ref17;
    }

    TopxCollection.prototype.model = Entities.Topx;

    TopxCollection.prototype.filterFacets = ["album", "artist", "firstWeek"];

    TopxCollection.prototype.parse = function(response) {
      var item, stations, totalAlbums, weeks, _fn, _fn1, _fn2, _i, _j, _k, _len, _len1, _len2,
        _this = this;
      weeks = [];
      stations = [];
      response = response.filter(function(v, i, a) {
        if (v._id.isNull === false && v._id.artist !== '') {
          return v;
        }
      });
      totalAlbums = response.length;
      _fn = function(item) {
        var obj, theCount, _fn1, _j, _len1, _ref18;
        item.artist = item._id.artist;
        item.album = item._id.album;
        item.label = item._id.label;
        item.slug = item._id.slug;
        item.isNull = item._id.isNull;
        item.firstWeek = item._id.firstWeek;
        theCount = 0;
        item.stations = [];
        _ref18 = item.appearances;
        _fn1 = function(obj) {
          var points;
          points = 0;
          points = 31 - (parseInt(obj.position));
          theCount += points;
          weeks.push(obj.week);
          stations.push(obj.station);
          return item.stations.push(obj.station);
        };
        for (_j = 0, _len1 = _ref18.length; _j < _len1; _j++) {
          obj = _ref18[_j];
          _fn1(obj);
        }
        item.stations = _.uniq(item.stations);
        item.frontPoints = theCount;
        return item.totalAlbums = totalAlbums;
      };
      for (_i = 0, _len = response.length; _i < _len; _i++) {
        item = response[_i];
        _fn(item);
      }
      weeks.sort();
      this.weeks = _.uniq(weeks, true);
      this.stations = _.uniq(stations);
      _fn1 = function(item) {
        item.totalWeeks = _this.weeks;
        return item.totalStations = _this.stations.length;
      };
      for (_j = 0, _len1 = response.length; _j < _len1; _j++) {
        item = response[_j];
        _fn1(item);
      }
      response = response.sort(function(a, b) {
        a = +a.frontPoints;
        b = +b.frontPoints;
        if (a === b) {
          return 0;
        }
        if (a > b) {
          return -1;
        } else {
          return 1;
        }
      });
      _fn2 = function(item) {
        return item.rank = response.indexOf(item) + 1;
      };
      for (_k = 0, _len2 = response.length; _k < _len2; _k++) {
        item = response[_k];
        _fn2(item);
      }
      return response;
    };

    TopxCollection.prototype.sortAttr = "rank";

    TopxCollection.prototype.sortDir = 1;

    TopxCollection.prototype.sortCharts = function(attr) {
      this.sortAttr = attr;
      this.sort();
      return this.trigger("reset");
    };

    TopxCollection.prototype.comparator = function(a, b) {
      a = a.get(this.sortAttr);
      b = b.get(this.sortAttr);
      if (a === b) {
        return 0;
      }
      if (this.sortDir === 1) {
        if (a > b) {
          return 1;
        } else {
          return -1;
        }
      } else {
        if (a > b) {
          return -1;
        } else {
          return 1;
        }
      }
    };

    return TopxCollection;

  })(Backbone.FacetedSearchCollection);
  API = {
    getTopx: function(search) {
      var d, desc, endDate, number, searchUrl, startDate, station, today, topxCollection, week;
      d = moment();
      number = 30;
      if (search.number) {
        number = search.number;
      }
      topxCollection = new Entities.TopxCollection;
      topxCollection.number = number;
      if (search.station) {
        station = search.station.toUpperCase();
      }
      if (station) {
        topxCollection.info = App.request("stations:entities", station);
      }
      topxCollection.station = station;
      today = "" + (d.format("YYYY-MM-DD"));
      startDate = today;
      if (search.startDate) {
        startDate = search.startDate;
      }
      endDate = today;
      if (search.endDate) {
        endDate = search.endDate;
      }
      startDate = tuesify(startDate);
      endDate = tuesify(endDate);
      topxCollection.startDate = startDate;
      topxCollection.endDate = endDate;
      topxCollection.potentialA = potentialWeeks(startDate, endDate);
      topxCollection.potential = potentialWeeksCount(startDate, endDate);
      if (station && startDate && endDate) {
        searchUrl = "/api/top/" + station + "/" + startDate + "/" + endDate;
        if (startDate === endDate) {
          desc = "" + station + " Top 30 for the week of " + startDate;
          week = startDate;
        } else {
          desc = "Top Albums on " + station + " between " + startDate + " and " + endDate;
        }
      } else {
        searchUrl = "/api/topall/" + startDate + "/" + endDate;
        if (startDate === endDate) {
          desc = "For the week of " + startDate;
          week = startDate;
        } else {
          desc = "For the " + topxCollection.potential + " weeks between " + startDate + " and " + endDate;
        }
      }
      topxCollection.desc = desc;
      if (week) {
        topxCollection.week = week;
      }
      topxCollection.url = searchUrl;
      topxCollection.fetch({
        reset: true
      });
      return topxCollection;
    },
    getLabel: function(label) {
      var labelCollection;
      labelCollection = new Entities.LabelCollection;
      label = encodeURIComponent(label);
      labelCollection.url = "/api/label/" + label;
      labelCollection.fetch({
        reset: true
      });
      return labelCollection;
    },
    getDate: function(date) {
      var theDate;
      theDate = new Entities.SingleDate;
      theDate.url = "/api/date/" + date;
      theDate.fetch({
        reset: true
      });
      return theDate;
    },
    getStation: function(station) {
      var theStation;
      theStation = new Entities.SingleStation;
      theStation.url = "/api/db/" + station;
      theStation.fetch({
        reset: true
      });
      return theStation;
    },
    getArtist: function(artist) {
      var artists;
      artists = new Entities.ArtistCollection;
      if (artist) {
        artists.artist = artist;
      }
      if (artist) {
        artist = encodeURIComponent(artist);
      }
      artists.url = "/api/artists/" + (artist ? artist : '');
      artists.fetch({
        reset: true
      });
      return artists;
    },
    getHeaders: function() {
      return new Entities.HeaderCollection([
        {
          name: "Home",
          path: 'home',
          icon: 'fi-home'
        }, {
          name: "Stations",
          path: 'station',
          icon: 'fi-results'
        }, {
          name: "Artists",
          path: 'artist',
          icon: "fi-results-demographics"
        }, {
          name: "FAQ",
          path: 'faq',
          icon: 'fi-info'
        }, {
          name: "Twitter",
          path: 'http://twitter.com/chartzapp',
          icon: 'fi-social-twitter'
        }
      ]);
    },
    getCharts: function(station, date) {
      var charts, chartsUrl, desc;
      if (station == null) {
        station = null;
      }
      if (date == null) {
        date = null;
      }
      if (date) {
        date = tuesify(date);
      }
      if (station === null && date === null) {
        chartsUrl = '/api/db/wholething';
        desc = "Full Database";
      } else if (date === null && station !== null) {
        chartsUrl = '/api/chart/' + station;
        desc = "Most recent " + station + " chart";
      } else {
        chartsUrl = '/api/chart/' + station + '/' + date;
        desc = "" + station + " Top 30 for the week of " + date;
      }
      charts = new Entities.ChartCollection;
      charts.desc = desc;
      charts.url = chartsUrl;
      charts.fetch({
        reset: true
      });
      return charts;
    },
    getStations: function(station) {
      var stations;
      stations = new Entities.Stations;
      if (station) {
        stations.url = "api/stations/data/" + station;
      } else {
        stations.url = "api/stations/data/";
      }
      stations.fetch({
        reset: true
      });
      return stations;
    }
  };
  App.reqres.setHandler("header:entities", function() {
    return API.getHeaders();
  });
  App.reqres.setHandler("artist:entities", function(artist) {
    return API.getArtist(artist);
  });
  App.reqres.setHandler('chart:entities', function(station, date) {
    return API.getCharts(station, date);
  });
  App.reqres.setHandler('stations:entities', function(station) {
    return API.getStations(station);
  });
  App.reqres.setHandler('station:entities', function(station) {
    return API.getStation(station);
  });
  App.reqres.setHandler('date:entities', function(date) {
    return API.getDate(date);
  });
  App.reqres.setHandler('label:entities', function(label) {
    return API.getLabel(label);
  });
  return App.reqres.setHandler('topx:entities', function(search) {
    return API.getTopx(search);
  });
});

});

require.register("init.coffee", function(exports, require, module) {
this.App = require('application');

$(function() {
  return App.initialize();
});

});

require.register("lib/stationList.coffee", function(exports, require, module) {
module.exports = ['CAPR', 'CFBU', 'CFBX', 'CFCR', 'CFMH', 'CFMU', 'CFOU', 'CFRC', 'CFRE', 'CFRO', 'CFRU', 'CFUR', 'CFUV', 'CFXU', 'CHLY', 'CHMA', 'CHMR', 'CHOQ', 'CHRW', 'CHRY', 'CHSR', 'CHUO', 'CHYZ', 'CICK', 'CILU', 'CIOI', 'CISM', 'CITR', 'CIUT', 'CIVL', 'CJAM', 'CJLO', 'CJLY', 'CJMQ', 'CJSF', 'CJSR', 'CJSW', 'CJUM', 'CKCU', 'CKDU', 'CKLU', 'CKMS', 'CKUA', 'CKUT', 'CKUW', 'CKXU', 'CSCR', 'RADL', 'SCOP'];

});

require.register("lib/view_helper.coffee", function(exports, require, module) {
Handlebars.registerHelper('pick', function(val, options) {
  return options.hash[val];
});

Handlebars.registerHelper('toUpper', function(str) {
  if (str) {
    return str.toUpperCase();
  }
});

Handlebars.registerHelper('json', function(context) {
  return JSON.stringify(context);
});

Handlebars.registerHelper('each_with_sort', function(array, key, opts) {
  var e, s, _i, _len;
  array = array.sort(function(a, b) {
    a = parseInt(a[key]);
    b = parseInt(b[key]);
    if (a > b) {
      return 1;
    }
    if (a === b) {
      return 0;
    }
    if (a < b) {
      return -1;
    }
  });
  s = '';
  for (_i = 0, _len = array.length; _i < _len; _i++) {
    e = array[_i];
    s += opts.fn(e);
  }
  return s;
});

Handlebars.registerHelper('each_sort_date', function(array, key, opts) {
  var e, s, _i, _len;
  array = array.sort(function(a, b) {
    a = new Date(a[key]);
    b = new Date(b[key]);
    if (a > b) {
      return 1;
    }
    if (a === b) {
      return 0;
    }
    if (a < b) {
      return -1;
    }
  });
  s = '';
  for (_i = 0, _len = array.length; _i < _len; _i++) {
    e = array[_i];
    s += opts.fn(e);
  }
  return s;
});

Handlebars.registerHelper('log', function(object) {
  return console.log(object);
});

Handlebars.registerHelper('countPoints', function(array) {
  var obj, theCount, _fn, _i, _len;
  theCount = 0;
  _fn = function(obj) {
    var points;
    points = 0;
    points = 31 - (parseInt(obj.position));
    return theCount += points;
  };
  for (_i = 0, _len = array.length; _i < _len; _i++) {
    obj = array[_i];
    _fn(obj);
  }
  return theCount;
});

});

require.register("modules/about/about_app.coffee", function(exports, require, module) {
var App,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('application');

module.exports = App.module('AboutApp', function(AboutApp, App, Backbone, Marionette, $, _) {
  var API, _ref;
  AboutApp.Router = (function(_super) {
    __extends(Router, _super);

    function Router() {
      _ref = Router.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Router.prototype.appRoutes = {
      "faq": "about"
    };

    return Router;

  })(Marionette.AppRouter);
  AboutApp.startWithParent = false;
  AboutApp.Show = require('modules/about/showAbout/showAbout_controller');
  API = {
    about: function() {
      new AboutApp.Show.Controller({
        region: App.mainRegion
      });
      return $(document).foundation();
    }
  };
  return App.addInitializer(function() {
    return new AboutApp.Router({
      controller: API
    });
  });
});

});

require.register("modules/about/showAbout/showAbout_controller.coffee", function(exports, require, module) {
var App, Controllers,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require("application");

Controllers = require("controllers/baseController");

module.exports = App.module('AboutApp.Show', function(Show, App, Backbone, Marionette, $, _) {
  var _ref, _ref1;
  Show.Controller = (function(_super) {
    __extends(Controller, _super);

    function Controller() {
      _ref = Controller.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Controller.prototype.initialize = function(opts) {
      this.layout = this.getLayoutView();
      this.show(this.layout, {
        loading: true
      });
      return $(document).foundation();
    };

    Controller.prototype.getLayoutView = function() {
      return new Show.Layout;
    };

    return Controller;

  })(App.Controllers.Base);
  return Show.Layout = (function(_super) {
    __extends(Layout, _super);

    function Layout() {
      _ref1 = Layout.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Layout.prototype.template = "modules/about/showAbout/templates/show_layout";

    Layout.prototype.id = "about-page";

    return Layout;

  })(Marionette.Layout);
});

});

require.register("modules/about/showAbout/templates/show_layout.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div class='title-row'>\n  <div class=\"row\">\n  <div id=\"title_region\" class=\"small-12 columns\">\n      <h1 class=\"main-title\">FAQ</h1>\n    </div>\n  </div>\n</div>\n<div class='panel-row'>\n  <div class=\"row\">\n    <div id=\"blurb_region\" class=\"small-9 columns\">\n      <h1>What?</h1>\n      <p class=\"lead\">This is <strong>ChartZapp</strong>, a new way of analyzing Canadian Campus-Community Radio Charts.</p>\n      <p>It uses modern web technologies to explore and visualize the treasure-trove of data collected and compiled by the excellent folks at\n      <a href=\"http://www.earshot-online.com/\" target=\"blank\">!Earshot Online</a>, and published by the <a href=\"http://www.ncra.ca/\" target=\"blank\">the NCRA.</a></p>\n    </div>\n    <div class=\"small-3 columns text-right\" id=\"faqicon\">\n      <i class=\"fi-lightbulb\"></i>\n    </div>\n  </div>\n</div>\n\n<div class='graph-row'>\n  <div class=\"row\">\n    <div class=\"small-3 columns \" id=\"faqicon\">\n      <i class=\"fi-torsos\"></i>\n    </div>\n    <div id=\"blurb_region\" class=\"small-9 columns text-right\">\n      <h1>Who?</h1>\n      <p class=\"lead\">Chartzapp was built for <strong>Stations, Artists, Labels, </strong>and <strong>Media.</strong></p>\n      <p>It makes information about Campus-Community Radio Charts more\n        accessible and visually stimulating, with the aim of providing some\n        newfangled, nerdy data analysis to the Canadian independent music community.\n      <p>It was developed independently by <a href=\"http://dorianlistens.com\" target=\"blank\">Dorian Scheidt,</a>\n         a Campus Community Radio Nerd (among other things) living in Montréal, QC, and now has the support of !earshot and the NCRA.</p>\n    </div>\n  </div>\n</div>\n\n\n<div class='panel-row'>\n  <div class=\"row\">\n    <div id=\"blurb_region\" class=\"small-9 columns\">\n      <h1>Why?</h1>\n      <p class=\"lead\"><strong>Charts</strong> and <strong>Graphs</strong> were\n        simply made for each other, don't you agree?</p>\n      <p>More Reasons:</p>\n      <ul>\n        <li>Campus-Community Radio is Great!</li>\n        <li>Data Analysis and Visualization are Cool!</li>\n        <li>Learning new things is Fun!</li>\n      </ul>\n      </div>\n    <div class=\"small-3 columns text-right\" id=\"faqicon\">\n      <i class=\"fi-graph-trend\"></i>\n    </div>\n  </div>\n</div>\n\n<div class='graph-row'>\n  <div class=\"row\">\n    <div class=\"small-3 columns \" id=\"faqicon\">\n      <i class=\"fi-wrench\"></i>\n    </div>\n    <div id=\"blurb_region\" class=\"small-9 columns text-right\">\n      <h1>How?</h1>\n      <p class=\"lead\">Chartzapp is a <strong>Single Page Application</strong> built using\n        open source tools.<p>\n      <p>It relies entirely on the chart data collected, edited and compiled by <a href=\"http://www.earshot-online.com/\" target=\"blank\">!earshot.</a></p>\n      <p>It is written almost entirely in\n        <a href=\"http://coffeescript.org/\" target=\"blank\">Coffeescript</a>\n        on both the front and\n        back-end. It uses <a href=\"http://nodejs.org/\" target=\"blank\">Node.js</a>\n        to run a server and webcrawler, which stores data in a\n        <a href=\"http://www.mongodb.org/\" target=\"blank\">MongoDB</a> database,\n        and then compares, analyzes and displays things with\n        <a href=\"http://backbonejs.org\" target=\"blank\">Backbone</a>,\n        <a href=\"http://marionettejs.com/\" target=\"blank\">Marionette</a>,\n        and <a href=\"http://d3js.org/\" target=\"blank\">D3</a>.\n        It's styled using the excellent\n        <a href=\"http://foundation.zurb.com/\" target=\"blank\">Foundation</a>\n        responsive framework.</p>\n    </div>\n  </div>\n</div>\n\n\n\n<div class='panel-row'>\n  <div class=\"row\">\n    <div id=\"blurb_region\" class=\"small-9 columns\">\n      <h1>When?</h1>\n      <p class=\"lead\"><strong>Now</strong>, and hopefully, <strong>Forever!</strong></p>\n      <p>The database currently extends from December 31st, 2013 to the Present</p>\n      <ul>\n        <li>Beta Release: <strong>June 10th, 2014</strong></li>\n        <li>Alpha Deploy: <strong>March 21st, 2014</strong></li>\n        <li>First Keystrokes: <strong>3:39 PM (EDT)</strong> on <strong>March 15th, 2014</strong></li>\n      </ul>\n    </div>\n    <div class=\"small-3 columns text-right\" id=\"faqicon\">\n      <i class=\"fi-calendar\"></i>\n    </div>\n  </div>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/artists_app.coffee", function(exports, require, module) {
var App,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('application');

module.exports = App.module('ArtistsApp', function(ArtistsApp, App, Backbone, Marionette, $, _) {
  var API, _ref;
  ArtistsApp.Router = (function(_super) {
    __extends(Router, _super);

    function Router() {
      _ref = Router.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Router.prototype.appRoutes = {
      "artist(/)(:artist)": "showArtists"
    };

    return Router;

  })(Marionette.AppRouter);
  ArtistsApp.startWithParent = false;
  ArtistsApp.Show = require('modules/artists/show/show_controller');
  API = {
    showArtists: function(artist) {
      new ArtistsApp.Show.Controller({
        region: App.mainRegion,
        artist: artist ? artist : void 0
      });
      return $(document).foundation();
    }
  };
  return App.addInitializer(function() {
    return new ArtistsApp.Router({
      controller: API
    });
  });
});

});

require.register("modules/artists/show/graph.coffee", function(exports, require, module) {
var App;

App = require("application");

module.exports = function(el, collection, graph, view, info) {
  var click, color, draw, height, hideData, highlight, highlightCircle, highlightLegend, margin, mouseout, mouseoutCircle, mouseoutLegend, parse, parseDate, parseWeeks, resize, showData, showTips, svg, width, x, xAxis, y, yAxis;
  margin = {
    top: 20,
    right: 50,
    bottom: 50,
    left: 50
  };
  width = $("#graph-region").width() - margin.left - margin.right;
  height = 500 - margin.top - margin.bottom;
  parseDate = d3.time.format("%Y-%m-%d").parse;
  x = d3.time.scale().range([0, width - 140]);
  y = d3.scale.linear().range([0, height]);
  color = require('colorList');
  xAxis = d3.svg.axis().scale(x).orient("bottom");
  yAxis = d3.svg.axis().scale(y).orient("left");
  svg = d3.select(el).append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
  resize = function() {
    width = $("#graph-region").width() - margin.left - margin.right;
    x.range([0, width]);
    d3.select('svg').remove();
    svg = d3.select(el).append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    return draw(graph);
  };
  $(window).on("resize", resize);
  click = function(d) {
    var station;
    station = d._id;
    return view.trigger("click:station:item", station);
  };
  highlight = function(d, i) {
    d3.selectAll("g path, circle").transition().duration(100).style("opacity", 0.2);
    d3.select(this).transition().duration(100).style("stroke-width", "10px").style("opactiy", 1);
    d3.selectAll("g ." + d._id + " circle").transition().duration(100).attr("r", "10").style("opacity", 1).forEach(function(d) {
      return d.forEach(function(c, i) {
        return showTips(d, c, i);
      });
    });
    return d3.select("." + d._id + " text").transition().duration(100).style("font-weight", "bold");
  };
  mouseout = function(d, i) {
    d3.selectAll("g path, circle").transition().duration(100).style("opacity", 1).attr("r", 5);
    d3.select(this).transition().duration(100).style("stroke-width", "1.5px");
    d3.select("." + d._id + " text").transition().duration(100).style("font-weight", "normal");
    return hideData();
  };
  highlightCircle = function(d) {
    showData(this, d);
    d3.select(this).transition().duration(100).attr("r", "10");
    return d3.select("." + d._id + " text").transition().duration(100).style("font-weight", "bold");
  };
  mouseoutCircle = function(d) {
    hideData(this);
    d3.select(this).transition().duration(100).attr("r", "5");
    return d3.select("." + d._id + " text").transition().duration(100).style("font-weight", "normal");
  };
  highlightLegend = function(d, i) {
    d3.select(this).transition().duration(100).style("font-weight", "bold");
    d3.selectAll("g path, circle").transition().duration(100).style("opacity", 0.2);
    d3.selectAll("g ." + d._id + " path").transition().duration(100).style("stroke-width", "10px").style("opacity", 1);
    d3.selectAll("g ." + d._id + " circle").transition().duration(100).attr("r", "10").style("opacity", 1);
    return d3.selectAll("." + d._id + " circle").forEach(function(d) {
      return d.forEach(function(c, i) {
        return showTips(d, c, i);
      });
    });
  };
  showTips = function(d, c, i) {
    var chartTip, coord, coord1, coord2;
    coord1 = parseInt(c.cx.animVal.value);
    coord2 = parseInt(c.cy.animVal.value);
    coord = [coord1, coord2];
    $("#graph").append("<div class='tip' id='" + d[i].__data__._id + "-" + i + "'></div>");
    chartTip = $("#" + d[i].__data__._id + "-" + i);
    if (i % 2) {
      chartTip.css("top", (coord[1] + 50) + "px");
    } else {
      chartTip.css("top", (coord[1] - 50) + "px");
    }
    chartTip.css("left", (coord[0] + 50) + "px").css("background", color(d[i].__data__._id));
    $("#" + d[i].__data__._id + "-" + i).html("" + (d[i].__data__._id.toUpperCase()) + "<br />\n# " + d[i].__data__.position + " <br />\n" + d[i].__data__.week);
    return $("#" + d[i].__data__._id + "-" + i).fadeIn(100);
  };
  mouseoutLegend = function(d, i) {
    d3.select(this).transition().duration(100).style("font-weight", "normal");
    d3.selectAll("g path, circle").transition().duration(100).style("opacity", 1).style("stroke-width", "1.5px").attr("r", 5);
    d3.selectAll("g ." + d._id + " circle").transition().duration(100).attr("r", 5);
    return hideData();
  };
  showData = function(dot, d) {
    var chartTip, coord;
    coord = d3.mouse(dot);
    $("#graph").append("<div class='tip'></div>");
    chartTip = d3.select(".tip");
    chartTip.style("left", (coord[0] + 15) + "px").style("top", (coord[1] - 50) + "px").style("background", color(d._id));
    $(".tip").html("Station: " + (d._id.toUpperCase()) + "<br />\nPosition: " + d.position + " <br />\nWeek: " + d.week);
    return $(".tip").fadeIn(100);
  };
  hideData = function() {
    return $(".tip").fadeOut(50).remove();
  };
  parse = function(collection) {
    var names, output, stations;
    output = [];
    stations = {};
    _.each(collection.models, function(model) {
      var appearances;
      appearances = model.get("appearancesCollection");
      return _.each(appearances.models, function(ap, i) {
        if (stations[ap.attributes.station]) {
          return stations[ap.attributes.station].appearances.push({
            position: ap.attributes.position,
            week: ap.attributes.week,
            score: 31 - ap.attributes.position
          });
        } else {
          return stations[ap.attributes.station] = {
            appearances: [
              {
                position: ap.attributes.position,
                week: ap.attributes.week,
                score: 31 - ap.attributes.position
              }
            ]
          };
        }
      });
    });
    names = Object.keys(stations);
    _.each(names, function(name) {
      return output.push({
        _id: name,
        appearances: stations[name].appearances
      });
    });
    return output.sort(function(a, b) {
      var stationA, stationB;
      stationA = info.findWhere({
        name: a._id.toUpperCase()
      });
      stationB = info.findWhere({
        name: b._id.toUpperCase()
      });
      a = stationA.get("postalCode");
      b = stationB.get("postalCode");
      if (a === b) {
        return 0;
      }
      if (a > b) {
        return -1;
      } else {
        return 1;
      }
    });
  };
  parseWeeks = function(collection) {
    var names, output, weeks;
    output = [];
    weeks = {};
    _.each(collection.models, function(model) {
      var appearances;
      appearances = model.get("appearancesCollection");
      return _.each(appearances.models, function(ap, i) {
        if (weeks[ap.attributes.week]) {
          return weeks[ap.attributes.week].appearances.push({
            station: ap.attributes.station,
            position: ap.attributes.position
          });
        } else {
          return weeks[ap.attributes.week] = {
            appearances: [
              {
                station: ap.attributes.station,
                position: ap.attributes.position
              }
            ]
          };
        }
      });
    });
    names = Object.keys(weeks);
    _.each(names, function(name) {
      return output.push({
        week: name,
        appearances: weeks[name].appearances
      });
    });
    return output;
  };
  draw = function(graph) {
    var area, barWidth, circle, hideInfo, infostring, legend, line, mouseover, pArray, pByW, showInfo, stack, station, stations, week, weeks, y2, y2Axis;
    stations = parse(collection);
    showInfo = function() {
      if ($(el).find(".info").length !== 0) {
        return $(".info").remove();
      } else {
        return $(el).append("<div class='tip text-center info'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 3 + "px").html(infostring).on("click", hideInfo).fadeIn(100);
      }
    };
    hideInfo = function() {
      $(el).find(".info").fadeOut(100);
      return $(".info").remove();
    };
    if ($(el).find(".infobox").length !== 0) {
      $(".infobox").remove();
    }
    $(el).prepend("<div class='button tiny radius infobox'></div>").find(".infobox").html("<i class='fi-info large'></i>").on("click", showInfo);
    $(el).find("svg").on("click", hideInfo);
    stations.forEach(function(d) {
      return d.appearances.forEach(function(c) {
        return c.date = parseDate(c.week);
      });
    });
    if (graph === "stations") {
      infostring = "<br />\nThis graph displays the number of stations " + collection.artist + " is charting\non over time.<br />\n<br />\n(Click anywhere to hide)\n<br />\n<br />";
      x = d3.time.scale().range([0, width - 140]);
      y = d3.scale.linear().range([0, height]);
      y2 = d3.scale.linear().range([0, height]);
      line = d3.svg.line().x(function(d) {
        return x(d.week);
      }).y(function(d) {
        var points;
        points = 0;
        _.each(d.appearances, function(a) {
          return points += 31 - a.position;
        });
        return y(points);
      });
      area = d3.svg.area().x(function(d) {
        return x(d.week);
      }).y0(function(d) {
        return y(d.y0);
      }).y1(function(d) {
        return y(d.y0 + d.y);
      });
      stack = d3.layout.stack().values(function(d) {
        return d.values;
      });
      weeks = parseWeeks(collection);
      weeks.forEach(function(d) {
        return d.week = parseDate(d.week);
      });
      pByW = {};
      _.each(weeks, function(w) {
        return _.each(w.appearances, function(a) {
          if (pByW[w.week]) {
            return pByW[w.week] += 31 - a.position;
          } else {
            return pByW[w.week] = 31 - a.position;
          }
        });
      });
      pArray = [];
      _.each(pByW, function(w, k) {
        return pArray.push({
          week: k,
          score: w
        });
      });
      console.log(stations);
      x.domain([
        d3.min(weeks, function(w) {
          return w.week;
        }), d3.max(weeks, function(w) {
          return w.week;
        })
      ]);
      y.domain([
        d3.max(pArray, function(p) {
          return p.score;
        }), 0
      ]);
      y2.domain([
        d3.max(weeks, function(w) {
          return w.appearances.length;
        }), 0
      ]);
      yAxis = d3.svg.axis().scale(y).orient("left");
      y2Axis = d3.svg.axis().scale(y2).orient("right");
      xAxis = d3.svg.axis().scale(x).orient("bottom");
      svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis);
      svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", "-3em").style("text-anchor", "end").text("Chartscore");
      svg.append("g").attr("class", "y2 axis").attr("transform", "translate(" + (width - margin.right) + ", 0)").call(y2Axis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", "-3em").style("text-anchor", "end").text("Number of Stations");
      week = svg.selectAll(".week").data(weeks).enter().append("g").attr("class", function(d) {
        return "week of " + d.week;
      });
      week.append("path").attr("class", "line").attr("d", function(d) {
        weeks.sort(function(a, b) {
          return a.week - b.week;
        });
        return line(weeks);
      }).style("stroke", function(d) {
        return color(d);
      }).on("mouseover", highlight).on("mouseout", mouseout);
      week.append("circle").attr("class", function(d) {
        return "dot " + d.week;
      }).style("fill", function(d, i) {
        return color(d._id);
      }).attr("r", 5).attr("cx", function(d) {
        return x(d.week);
      }).attr("cy", function(d) {
        return y2(d.appearances.length);
      });
      station = svg.selectAll(".station").data(weeks);
    }
    if (graph === "line") {
      infostring = "<br />\nThis graph displays all appearances of " + collection.artist + " over the\nselected time range, organized by station.<br />\nThe X-Axis is determined by the date of the appearance.<br />\nThe Y-Axis is determined by the album's position.<br />\nMouseover any dot or line for more information.<br />\n<br />\n(Click anywhere to hide)\n<br />\n<br />";
      line = d3.svg.line().x(function(d) {
        return x(d.date);
      }).y(function(d) {
        return y(d.position);
      });
      x.domain([
        d3.min(stations, function(c) {
          return d3.min(c.appearances, function(v) {
            return v.date;
          });
        }), d3.max(stations, function(c) {
          return d3.max(c.appearances, function(v) {
            return v.date;
          });
        })
      ]);
      y.domain([1, 30]);
      svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis);
      svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", "-3em").style("text-anchor", "end").text("Position");
      station = svg.selectAll(".station").data(stations).enter().append("g").attr("class", function(d) {
        return "station " + d._id;
      });
      station.append("path").attr("class", "line").attr("d", function(d) {
        d.appearances.sort(function(a, b) {
          return a.date - b.date;
        });
        return line(d.appearances);
      }).style("stroke", function(d, i) {
        return color(d._id);
      }).on("mouseover", highlight).on("mouseout", mouseout);
      circle = station.selectAll('circle').data(function(d, i) {
        d.appearances.forEach(function(c) {
          return c._id = d._id;
        });
        return d.appearances;
      }).enter().append("circle").attr("class", function(d) {
        return "dot " + d._id + " " + d.week;
      }).style("fill", function(d, i) {
        return color(d._id);
      }).attr("r", 5).attr("cx", function(d) {
        return x(d.date);
      }).attr("cy", function(d) {
        return y(d.position);
      }).on("mouseover", highlightCircle).on("click", click).on("mouseout", mouseoutCircle);
      legend = svg.selectAll(".legend").data(stations).enter().append("g").attr("class", function(d) {
        return "legend " + d;
      }).attr("transform", function(d, i) {
        if (i < 20) {
          return "translate(-70," + i * 20 + ")";
        } else if (i >= 20) {
          return "translate(5," + (i - 20) * 20 + ")";
        }
      });
      legend.append("rect").attr("x", width - 10).attr("width", 18).attr("height", 18).style("fill", function(d) {
        return color(d._id);
      });
      legend.append("text").attr("x", width - 15).attr("y", 9).attr("dy", ".35em").style("text-anchor", "end").text(function(d) {
        return d._id.toUpperCase();
      });
      legend.on("mouseover", highlightLegend).on("mouseout", mouseoutLegend);
    } else if (graph === "bar") {
      infostring = "<br />\nThis graph displays the number of appearances of " + collection.artist + "\nover the selected time range, organized by station.<br />\nThe X-Axis is determined by the station.<br />\nThe Y-Axis is determined by the number of appearances.<br />\nMouseover any bar for more information.<br />\n<br />\n(Click anywhere to hide)\n<br />\n<br />";
      margin.right = margin.left;
      barWidth = width / stations.length;
      x = d3.scale.linear().range([0, width - 75]);
      y = d3.scale.linear().range([height, 0]);
      yAxis = d3.svg.axis().scale(y).orient("left");
      x.domain([0, stations.length]);
      y.domain([
        0, d3.max(stations, function(c) {
          return c.appearances.length;
        })
      ]);
      svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", "-3em").style("text-anchor", "end").text("# of Appearances");
      mouseover = function(d, i) {
        d3.selectAll("g rect").transition().duration(100).style("opacity", 0.2);
        d3.select("g ." + d._id + " > rect").transition().duration(100).style("opacity", 1);
        d3.select("g ." + d._id + " > text").transition().duration(100).style("font-weight", "bold");
        return showData(d);
      };
      mouseout = function() {
        d3.selectAll("g rect").transition().duration(100).style("opacity", 1);
        d3.selectAll("g text").transition().duration(100).style("font-weight", "normal");
        return $(".tip").fadeOut(50).remove();
      };
      showData = function(d) {
        var chartTip;
        $("#graph").append("<div class='tip'></div>");
        chartTip = d3.select(".tip");
        chartTip.style("left", width - 100 + "px").style("top", 50 + "px").style("background", color(d._id));
        $(".tip").html("" + (d._id.toUpperCase()) + " <br />\nTotal Appearances: " + d.appearances.length + "<br />\nHighest Position: " + (d3.min(d.appearances, function(c) {
          return c.position;
        })) + "<br />\nFirst: " + (d3.min(d.appearances, function(c) {
          return c.week;
        })) + "<br />\nMost Recent: " + (d3.max(d.appearances, function(c) {
          return c.week;
        })));
        return $(".tip").fadeIn(100);
      };
      station = svg.selectAll(".station").data(stations).enter().append("g").attr("transform", function(d, i) {
        return "translate(" + i * barWidth + ",0 )";
      }).attr("class", function(d) {
        return "station " + d._id;
      });
      station.append("rect").attr("class", "bar").attr("width", barWidth - 1).attr("height", function(d) {
        return height - y(d.appearances.length);
      }).attr("y", function(d) {
        return 3 + y(d.appearances.length);
      }).style("fill", function(d, i) {
        return color(d._id);
      }).on("mouseover", mouseover).on("mouseout", mouseout).on("click", click);
      station.append("text").attr("y", barWidth / 2 - barWidth).attr("x", function(d) {
        return height;
      }).attr("dx", ".75em").text(function(d) {
        return d._id.toUpperCase();
      }).attr("transform", "rotate(90)");
    }
  };
  return draw(graph);
};

});

require.register("modules/artists/show/landingGraph.coffee", function(exports, require, module) {
var App, tuesify;

App = require("application");

tuesify = function(date) {
  var theDay, theTues, theWeek;
  theWeek = (function() {
    switch (false) {
      case !date:
        return moment(date);
      default:
        return moment();
    }
  })();
  theDay = theWeek.get('day');
  theTues = (function() {
    switch (false) {
      case theDay !== 0:
        return theWeek.day(-5);
      case theDay !== 1:
        return theWeek.day(-5);
      case theDay !== 2:
        return theWeek;
      case !(theDay > 2):
        return theWeek.day(2);
    }
  })();
  theTues = moment(theTues);
  return theTues.format('YYYY-MM-DD');
};

module.exports = function(el, collection, view) {
  var albumCircles, albums, click, color, height, hideInfo, margin, mouseout, mouseover, rScale, showData, showEmpty, showInfo, svg, width, x, xAxis, y, yAxis;
  margin = {
    top: 100,
    right: 120,
    bottom: 50,
    left: 50
  };
  width = $("#graph-region").width() - margin.left - margin.right;
  height = 500 - margin.top - margin.bottom;
  y = d3.scale.linear().range([0, height]);
  x = d3.scale.linear().range([0, width - 100]);
  color = require('colorList');
  xAxis = d3.svg.axis().scale(x).orient("bottom");
  yAxis = d3.svg.axis().scale(y).orient("left");
  svg = d3.select(el).append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + (margin.left + 20) + "," + margin.top + ")");
  albums = collection.models;
  rScale = d3.scale.linear();
  rScale.domain(d3.extent(albums, function(c) {
    return c.attributes.frontPoints;
  }));
  rScale.range([5, 130]);
  y.domain([
    d3.max(albums, function(c) {
      return c.attributes.appearances.length;
    }), d3.min(albums, function(c) {
      return c.attributes.appearances.length;
    })
  ]);
  x.domain(d3.extent(albums, function(c) {
    return c.attributes.frontPoints;
  }));
  svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis);
  if (albums.length !== 0) {
    svg.append("g").attr("class", "y axis").attr("transform", "translate(-10,0)").call(yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style("text-anchor", "end").text("# of Appearances");
  }
  mouseover = function(d, i) {
    d3.selectAll("g circle").transition().duration(100).style("opacity", 0.2);
    d3.select("g ." + d.attributes.slug).transition().duration(100).style("opacity", 1);
    return showData(this, d);
  };
  mouseout = function() {
    d3.selectAll("g circle").transition().duration(100).style("opacity", 1);
    return $(".tip").fadeOut(50).remove();
  };
  click = function(d) {
    var artist;
    artist = d.attributes.artist;
    return view.trigger("click:album:circle", artist);
  };
  showData = function(circle, d) {
    var chartTip, coord;
    coord = d3.mouse(circle);
    $("#graph").append("<div class='tip'></div>");
    chartTip = d3.select(".tip");
    chartTip.style("left", 150 + "px").style("top", 50 + "px").style("background", color(d.attributes.rank));
    $(".tip").html("#" + d.attributes.rank + ": " + d.attributes.artist + " <br />\n" + d.attributes.album + "<br />\nTotal Appearances: " + d.attributes.appearances.length + "<br />\nChartscore: " + d.attributes.frontPoints + "<br />\nFirst Appearance: " + d.attributes.firstWeek + "<br />\nAppeared on " + d.attributes.stations.length + " / " + d.attributes.totalStations + " stations");
    return $(".tip").fadeIn(100);
  };
  showEmpty = function() {
    return $(el).append("<div class='tip text-center'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 2 + "px").html("<br />\nSorry, No Data is available for the selected Time Range.\n<br />\n<br />").fadeIn(100);
  };
  showInfo = function() {
    if ($(el).find(".tip").length !== 0) {
      return $(".info").remove();
    } else {
      return $(el).append("<div class='tip text-center info'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 3 + "px").html("<br />\nThis graph displays the top albums for all stations over the selected time range.<br />\nThe X-Axis and the Radius of each circle is determined by the album's Chartscore.<br />\nThe Y-Axis is determined by the album's total number of appearances.<br />\n<br />\nMouseover any circle for more information.<br />\n<br />\n(Click anywhere to hide)\n<br />\n<br />").on("click", hideInfo).fadeIn(100);
    }
  };
  hideInfo = function() {
    $(el).find(".info").fadeOut(100);
    return $(".info").remove();
  };
  $(el).prepend("<div class='button tiny radius infobox'></div>").find(".infobox").html("<i class='fi-info large'></i>").on("click", showInfo);
  $(el).find("svg").on("click", hideInfo);
  albumCircles = svg.selectAll("circle").data(albums).enter().append("circle").attr("fill", function(d) {
    return color(d.attributes.rank);
  }).attr("class", function(d) {
    return "dot " + d.attributes.slug;
  }).attr("cy", function(d) {
    var num;
    num = d.attributes.appearances.length;
    return y(num);
  }).attr("cx", function(d, i) {
    return x(d.attributes.frontPoints);
  }).attr("r", function(d) {
    return rScale(d.attributes.frontPoints);
  });
  albumCircles.on("mouseover", mouseover).on("mouseout", mouseout).on("click", click);
  if (albums.length === 0) {
    return showEmpty();
  }
};

});

require.register("modules/artists/show/show_controller.coffee", function(exports, require, module) {
var App, ArtistsApp, Controllers,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require("application");

ArtistsApp = require("modules/artists/artists_app");

Controllers = require("controllers/baseController");

module.exports = App.module('ArtistsApp.Show', function(Show, App, Backbone, Marionette, $, _) {
  var _ref, _ref1, _ref10, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
  Show.Controller = (function(_super) {
    __extends(Controller, _super);

    function Controller() {
      this.mainView = __bind(this.mainView, this);
      _ref = Controller.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Controller.prototype.initialize = function(opts) {
      var artist,
        _this = this;
      this.opts = opts;
      artist = App.request("artist:entities", opts.artist);
      this.layout = this.getLayoutView();
      this.listenTo(this.layout, 'show', function() {
        return _this.mainView(artist);
      });
      return this.show(this.layout, {
        region: App.mainRegion,
        loading: false
      });
    };

    Controller.prototype.mainView = function(artist) {
      if (this.opts.artist) {
        return this.showArtist(artist);
      } else {
        return this.showStart();
      }
    };

    Controller.prototype.showArtist = function(artist) {
      var artistsView,
        _this = this;
      App.execute("when:fetched", artist, function() {
        $(document).foundation();
        if (artist.length === 0) {
          return _this.showEmpty();
        }
      });
      artistsView = this.getArtistsView(artist);
      this.show(artistsView, {
        region: this.layout.tableRegion,
        loading: true
      });
      this.showPanel(artist);
      this.showTitle(artist);
      return this.showGraph(artist);
    };

    Controller.prototype.showTitle = function(artist) {
      var titleView;
      titleView = this.getTitleView(artist);
      this.listenTo(titleView, "click:pop:station", function(e) {
        return App.navigate("station/" + e.text, {
          trigger: true
        });
      });
      return this.show(titleView, {
        region: this.layout.titleRegion,
        loading: true
      });
    };

    Controller.prototype.showGraph = function(artist) {
      var graphView;
      graphView = this.getGraphView(artist);
      this.listenTo(graphView, 'click:station:item', function(station) {
        station = encodeURIComponent(station);
        return App.navigate("station/" + station, {
          trigger: true
        });
      });
      return this.show(graphView, {
        region: this.layout.graphRegion,
        loading: true
      });
    };

    Controller.prototype.showEmpty = function() {
      var emptyView;
      emptyView = this.getEmptyView();
      this.listenTo(emptyView, 'click:search', function(artistVal) {
        artistVal = encodeURIComponent(artistVal);
        return App.navigate("artist/" + artistVal, {
          trigger: true
        });
      });
      return this.show(emptyView, {
        region: this.layout.tableRegion
      });
    };

    Controller.prototype.showStart = function() {
      var startView;
      startView = this.getStartView();
      this.listenTo(startView, 'click:search', function(artistVal) {
        artistVal = encodeURIComponent(artistVal);
        return App.navigate("artist/" + artistVal, {
          trigger: true
        });
      });
      return this.show(startView, {
        region: this.layout.tableRegion
      });
    };

    Controller.prototype.showPanel = function(artist) {
      var panelView;
      panelView = this.getPanelView(artist);
      this.slug = "";
      this.listenTo(panelView, "click:albumButton", function(slug) {
        if (slug === "cz_all") {
          this.slug = '';
          return artist.resetFilters();
        } else {
          this.slug = slug;
          return artist.resetAndAddFilter({
            slug: slug
          });
        }
      });
      return this.show(panelView, {
        region: this.layout.panelRegion,
        loading: true
      });
    };

    Controller.prototype.getTitleView = function(artist) {
      return new Show.Title({
        collection: artist
      });
    };

    Controller.prototype.getGraphView = function(artist) {
      return new Show.Graph({
        collection: artist
      });
    };

    Controller.prototype.getEmptyView = function() {
      return new Show.EmptyView;
    };

    Controller.prototype.getArtistsView = function(artists) {
      return new Show.Artist({
        collection: artists
      });
    };

    Controller.prototype.getStartView = function() {
      return new Show.Start;
    };

    Controller.prototype.getPanelView = function(artist) {
      return new Show.Panel({
        collection: artist
      });
    };

    Controller.prototype.getLayoutView = function() {
      return new Show.Layout;
    };

    return Controller;

  })(App.Controllers.Base);
  Show.Layout = (function(_super) {
    __extends(Layout, _super);

    function Layout() {
      _ref1 = Layout.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Layout.prototype.template = "modules/artists/show/templates/show_layout";

    Layout.prototype.regions = {
      titleRegion: "#title-region",
      panelRegion: "#panel-region",
      graphRegion: "#graph-region",
      tableRegion: "#table-region"
    };

    return Layout;

  })(Marionette.Layout);
  Show.Title = (function(_super) {
    __extends(Title, _super);

    function Title() {
      _ref2 = Title.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Title.prototype.template = "modules/artists/show/templates/title";

    Title.prototype.events = {
      "click #popStation": "popStation"
    };

    Title.prototype.popStation = function(e) {
      return this.trigger("click:pop:station", e.target);
    };

    return Title;

  })(Marionette.ItemView);
  Show.Panel = (function(_super) {
    __extends(Panel, _super);

    function Panel() {
      _ref3 = Panel.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    Panel.prototype.template = "modules/artists/show/templates/panel";

    Panel.prototype.className = "";

    Panel.prototype.events = {
      "click a.albumlink": "showGraph",
      "click a.button": "showFilters"
    };

    Panel.prototype.showGraph = function(e) {
      e.preventDefault();
      $(e.target).parent().parent().find('.active').removeClass("active");
      $(e.target).parent("dd").toggleClass("active");
      return this.trigger('click:albumButton', e.target.id);
    };

    Panel.prototype.showFilters = function(e) {
      e.preventDefault();
      if ($("#filters").hasClass("hide")) {
        $("#filters").slideDown().toggleClass("hide");
        return $(e.target).text("Hide Filters");
      } else {
        $("#filters").slideUp().toggleClass("hide");
        return $(e.target).text("Show Filters");
      }
    };

    return Panel;

  })(Marionette.ItemView);
  Show.Graph = (function(_super) {
    __extends(Graph, _super);

    function Graph() {
      _ref4 = Graph.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    Graph.prototype.template = "modules/artists/show/templates/graph";

    Graph.prototype.ui = {
      "typeSelect": "#type-select"
    };

    Graph.prototype.events = {
      "change @ui.typeSelect": "select"
    };

    Graph.prototype.selectOptions = {
      "Appearances By Station": "bar",
      "Appearances By Station Over Time": "line"
    };

    Graph.prototype.select = function(e) {
      e.preventDefault();
      this.graphType = this.ui.typeSelect.val();
      return this.graph(this.graphType);
    };

    Graph.prototype.buildGraph = require("modules/artists/show/graph");

    Graph.prototype.graphType = "bar";

    Graph.prototype.graph = function(type) {
      var _this = this;
      d3.select("svg").remove();
      return App.execute("when:fetched", this.stations, function() {
        return _this.buildGraph(_this.el, _this.collection, type, _this, _this.stations);
      });
    };

    Graph.prototype.id = "graph";

    Graph.prototype.collections = [];

    Graph.prototype.initialize = function() {
      var _this = this;
      this.stations = App.request("stations:entities");
      return App.execute("when:fetched", this.collection, function() {
        _.each(_this.collection.models, function(model) {
          return _this.collections.push(model.get("appearancesCollection"));
        });
        _.each(_this.collections, function(appearances) {
          return _this.listenTo(appearances, "filter", function() {
            return _this.render();
          });
        });
        return _this.listenTo(_this.collection, "filter", function() {
          return _this.render();
        });
      });
    };

    Graph.prototype.onRender = function() {
      if (matchMedia(Foundation.media_queries['medium']).matches) {
        this.ui.typeSelect.find("option[value='" + this.graphType + "']").attr("selected", true);
        return this.graph(this.graphType);
      }
    };

    return Graph;

  })(Marionette.ItemView);
  Show.Empty = (function(_super) {
    __extends(Empty, _super);

    function Empty() {
      _ref5 = Empty.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    Empty.prototype.template = "modules/artists/show/templates/empty";

    return Empty;

  })(Marionette.ItemView);
  Show.EmptyView = (function(_super) {
    __extends(EmptyView, _super);

    function EmptyView() {
      _ref6 = EmptyView.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    EmptyView.prototype.template = "modules/artists/show/templates/emptyview";

    EmptyView.prototype.ui = {
      'artistInput': '#artist_input'
    };

    EmptyView.prototype.events = {
      'submit': 'submit'
    };

    EmptyView.prototype.submit = function(e) {
      var artistVal;
      e.preventDefault();
      artistVal = $.trim(this.ui.artistInput.val());
      return this.trigger('click:search', artistVal);
    };

    return EmptyView;

  })(Marionette.ItemView);
  Show.Start = (function(_super) {
    __extends(Start, _super);

    function Start() {
      _ref7 = Start.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    Start.prototype.template = "modules/artists/show/templates/start";

    Start.prototype.ui = {
      'artistInput': '#artist_input'
    };

    Start.prototype.events = {
      'submit': 'submit'
    };

    Start.prototype.submit = function(e) {
      var artistVal;
      e.preventDefault();
      artistVal = $.trim(this.ui.artistInput.val());
      return this.trigger('click:search', artistVal);
    };

    return Start;

  })(Marionette.ItemView);
  Show.Appearance = (function(_super) {
    __extends(Appearance, _super);

    function Appearance() {
      _ref8 = Appearance.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    Appearance.prototype.template = "modules/artists/show/templates/appearance";

    Appearance.prototype.tagName = "tr";

    return Appearance;

  })(Marionette.ItemView);
  Show.Album = (function(_super) {
    __extends(Album, _super);

    function Album() {
      this.clickHeader = __bind(this.clickHeader, this);
      _ref9 = Album.__super__.constructor.apply(this, arguments);
      return _ref9;
    }

    Album.prototype.template = "modules/artists/show/templates/artistItem";

    Album.prototype.initialize = function() {
      return this.collection = this.model.get("appearancesCollection");
    };

    Album.prototype.itemView = Show.Appearance;

    Album.prototype.itemViewContainer = "tbody";

    Album.prototype.tagName = 'div';

    Album.prototype.events = {
      "click a": "clickStation",
      'click th': 'clickHeader'
    };

    Album.prototype.clickStation = function(e) {
      e.preventDefault();
      return App.navigate("station/" + (encodeURIComponent(e.target.text)), {
        trigger: true
      });
    };

    Album.prototype.sortUpIcon = "fi-arrow-down";

    Album.prototype.sortDnIcon = "fi-arrow-up";

    Album.prototype.onRender = function() {
      this.$el.find(".chosen-select").chosen();
      this.$("[column]").append($("<i>")).closest("th").find("i").addClass("fi-minus-circle size-18");
      this.$("[column='" + this.collection.sortAttr + "']").find("i").removeClass("fi-minus-circle").addClass(this.sortUpIcon);
      return this;
    };

    Album.prototype.clickHeader = function(e) {
      var $el, cs, ns;
      $el = $(e.currentTarget);
      ns = $el.attr("column");
      cs = this.collection.sortAttr;
      if (ns === cs) {
        this.collection.sortDir *= -1;
      } else {
        this.collection.sortDir = 1;
      }
      $("th").find("i").attr("class", "fi-minus-circle size-18");
      if (this.collection.sortDir === 1) {
        $el.find("i").removeClass("fi-minus-circle").addClass(this.sortUpIcon);
      } else {
        $el.find("i").removeClass("fi-minus-circle").addClass(this.sortDnIcon);
      }
      this.collection.sortCharts(ns);
    };

    return Album;

  })(Marionette.CompositeView);
  return Show.Artist = (function(_super) {
    __extends(Artist, _super);

    function Artist() {
      _ref10 = Artist.__super__.constructor.apply(this, arguments);
      return _ref10;
    }

    Artist.prototype.template = "modules/artists/show/templates/artists";

    Artist.prototype.itemView = Show.Album;

    Artist.prototype.emptyView = Show.Empty;

    Artist.prototype.itemViewContainer = "#theplace";

    Artist.prototype.ui = {
      "position": "#position",
      "station": "#station",
      "week": "#week",
      "clear": "#clearFilters"
    };

    Artist.prototype.events = {
      'change input': "submit",
      'change .chosen-select': "submit",
      "click @ui.clear": "clearFilters"
    };

    Artist.prototype.collections = [];

    Artist.prototype.initialize = function() {
      var subCollection,
        _this = this;
      this.filters = [];
      this.bigList = {};
      subCollection = "appearancesCollection";
      return App.execute("when:fetched", this.collection, function() {
        var model, _i, _len, _ref11;
        _this.collection.countPoints();
        $(document).foundation();
        _this.collection.initializeFilters();
        _ref11 = _this.collection.models;
        for (_i = 0, _len = _ref11.length; _i < _len; _i++) {
          model = _ref11[_i];
          _this.collections.push(model.get(subCollection));
        }
        return _.each(_this.collections, function(collection, i) {
          collection.initializeFilters();
          return _this.filters[i] = collection.getFilterLists();
        });
      });
    };

    Artist.prototype.onRender = function() {
      var filterFacets,
        _this = this;
      filterFacets = Object.keys(this.filters[0]);
      _.each(filterFacets, function(facet) {
        return _this.bigList[facet] = [];
      });
      _.each(this.filters, function(filterSet) {
        return _.each(filterFacets, function(facet, i) {
          return _this.bigList[facet].push(filterSet[facet]);
        });
      });
      _.each(filterFacets, function(facet) {
        _this.bigList[facet] = _.uniq(_.flatten(_.union(_this.bigList[facet])));
        return _this.bigList[facet].sort(function(a, b) {
          if (a === b) {
            return 0;
          }
          if (facet === "position") {
            if (+a > +b) {
              return 1;
            } else {
              return -1;
            }
          } else if (facet === "week") {
            if (moment(a) > moment(b)) {
              return 1;
            } else {
              return -1;
            }
          } else {
            if (a > b) {
              return 1;
            } else {
              return -1;
            }
          }
        });
      });
      _.each(this.bigList, function(bigSet, facet) {
        return _.each(bigSet, function(value) {
          return _this.$el.find("#" + facet).append("<option value='" + value + "'>" + (value.toUpperCase()) + "</option>").attr("disabled", false);
        });
      });
      this.$el.find(".chosen-select").chosen().trigger("chosen:updated");
      return this.collection.on("filter", function() {
        return _this.makeFilterLists();
      });
    };

    Artist.prototype.submit = function(e, params) {
      var facet, filter, value;
      e.preventDefault();
      filter = {};
      facet = e.target.id;
      value = params.selected ? params.selected : params.deselected;
      filter[facet] = value;
      if (params.selected) {
        return this.addFilter(filter);
      } else {
        return this.removeFilter(filter);
      }
    };

    Artist.prototype.clearFilters = function(e) {
      e.preventDefault();
      _.each(this.collections, function(collection) {
        return collection.resetFilters();
      });
      this.$el.find("option").attr("disabled", false);
      return this.$el.find(".chosen-select").val('[]').trigger('chosen:updated');
    };

    Artist.prototype.addFilter = function(filter) {
      _.each(this.collections, function(collection) {
        return collection.addFilter(filter);
      });
      return this.updateFilters(filter);
    };

    Artist.prototype.removeFilter = function(filter) {
      _.each(this.collections, function(collection) {
        return collection.removeFilter(filter);
      });
      return this.updateFilters(filter);
    };

    Artist.prototype.makeFilterLists = function() {
      var _this = this;
      this.$el.find("option").attr("disabled", true);
      _.each(this.collection.models, function(model) {
        var filterList;
        filterList = model.attributes.appearancesCollection.initializeFilterLists();
        return _.each(filterList, function(values, facet) {
          return _.each(values, function(value) {
            return _this.$el.find("option[value='" + value + "']").attr("disabled", false);
          });
        });
      });
      return this.$el.find(".chosen-select").chosen().trigger("chosen:updated");
    };

    Artist.prototype.updateFilters = function(filter) {
      var filterFacet,
        _this = this;
      filterFacet = Object.keys(filter);
      this.$el.find("option").attr("disabled", true);
      _.each(this.collections, function(collection, i, list) {
        var facets;
        facets = collection.getUpdatedFilterLists(filterFacet);
        return _.each(facets, function(values, facet) {
          return _.each(values, function(value) {
            return _this.$el.find("option[value='" + value + "']").attr("disabled", false);
          });
        });
      });
      return this.$el.find(".chosen-select").chosen().trigger("chosen:updated");
    };

    return Artist;

  })(Marionette.CompositeView);
});

});

require.register("modules/artists/show/templates/appearance.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression;
  return "<td>"
    + escapeExpression(((helper = (helper = helpers.position || (depth0 != null ? depth0.position : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"position","hash":{},"data":data}) : helper)))
    + "</td>\n<td><a>"
    + escapeExpression(((helpers.toUpper || (depth0 && depth0.toUpper) || helperMissing).call(depth0, (depth0 != null ? depth0.station : depth0), {"name":"toUpper","hash":{},"data":data})))
    + "</a></td>\n<td>"
    + escapeExpression(((helper = (helper = helpers.week || (depth0 != null ? depth0.week : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"week","hash":{},"data":data}) : helper)))
    + "</td>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/show/templates/artistItem.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"1":function(depth0,helpers,partials,data) {
  var lambda=this.lambda, escapeExpression=this.escapeExpression, helperMissing=helpers.helperMissing;
  return "\n    <tr>\n      <td>"
    + escapeExpression(lambda((depth0 != null ? depth0.position : depth0), depth0))
    + "</td>\n      <td><a>"
    + escapeExpression(((helpers.toUpper || (depth0 && depth0.toUpper) || helperMissing).call(depth0, (depth0 != null ? depth0.station : depth0), {"name":"toUpper","hash":{},"data":data})))
    + "</a></td>\n      <td>"
    + escapeExpression(lambda((depth0 != null ? depth0.week : depth0), depth0))
    + "</td>\n    </tr>\n  ";
},"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression, lambda=this.lambda, buffer = "<!-- <h4>"
    + escapeExpression(((helper = (helper = helpers.album || (depth0 != null ? depth0.album : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"album","hash":{},"data":data}) : helper)))
    + " - "
    + escapeExpression(((helper = (helper = helpers.label || (depth0 != null ? depth0.label : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"label","hash":{},"data":data}) : helper)))
    + "</h4> -->\n<div class=\"chart\">\n  <table width=\"100%\">\n    <thead>\n      <tr><th colspan=\"3\">"
    + escapeExpression(((helper = (helper = helpers.album || (depth0 != null ? depth0.album : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"album","hash":{},"data":data}) : helper)))
    + " - "
    + escapeExpression(((helper = (helper = helpers.label || (depth0 != null ? depth0.label : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"label","hash":{},"data":data}) : helper)))
    + " - "
    + escapeExpression(lambda(((stack1 = (depth0 != null ? depth0.appearances : depth0)) != null ? stack1.length : stack1), depth0))
    + " appearances</th></tr>\n      <th column=\"position\">Position</th>\n      <th column=\"station\">Station</th>\n      <th column=\"week\">Week</th>\n    </thead>\n    <tbody></tbody>\n  <!-- ";
  stack1 = ((helpers.each_sort_date || (depth0 && depth0.each_sort_date) || helperMissing).call(depth0, (depth0 != null ? depth0.appearances : depth0), "week", {"name":"each_sort_date","hash":{},"fn":this.program(1, data),"inverse":this.noop,"data":data}));
  if (stack1 != null) { buffer += stack1; }
  return buffer + " -->\n  </table>\n</div>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/show/templates/artists.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div id=\"filters\" class=\"hide \">\n  <div class=\"row\">\n    <form>\n      <div class=\"medium-3 columns\">\n        <select class=\"chosen-select\" id=\"position\" data-placeholder=\"Position\" multiple>\n        </select>\n      </div>\n      <div class=\"medium-4 columns\">\n        <select class=\"chosen-select\" id=\"station\" data-placeholder=\"Station\" multiple>\n        </select>\n      </div>\n      <div class=\"medium-4 columns\">\n        <select class=\"chosen-select\" id=\"week\" data-placeholder=\"Week\" multiple>\n        </select>\n      </div>\n      <div class=\"medium-1 column\">\n        <a class=\"button secondary tiny right\" id=\"clearFilters\" href=\"#\">Clear</a>\n      </div>\n  </form>\n  </div>\n</div>\n\n<div id=\"theplace\"></div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/show/templates/empty.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<th colspan=\"4\">Sorry, Nothing Found.</th>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/show/templates/emptyview.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div class=\"panel small-12 columns\">\n  <h4>Sorry, nothing found for that search.</h4>\n  <h5>Try again?</h5>\n  <form>\n    <div class=\"station-field\">\n      <label>Artist:<input type=\"text\" id=\"artist_input\"></input></label>\n    </div>\n      <button type=\"submit\">Search</button>\n  </form>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/show/templates/graph.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div class=\"show-for-small-only\">\n  <p class=\"lead\">For now, ChartZapp's graphs are only available on larger screens.</p>\n  <p>If you'd like to see more on a mobile device,\n  <a href=\"#\" data-reveal-id=\"feedback\">let me know!</a></p>\n\n</div>\n\n<div class=\"show-for-medium-up\">\n  <div class=\"row\">\n    <div class=\"small-4 columns\">\n      <h3 class=\"\">Visualizer:</h3>\n    </div>\n    <div class=\"small-4 columns end\">\n      <select id=\"type-select\">\n        <option value=\"bar\">Appearances By Station</option>\n        <option value=\"line\">Appearances By Station Over Time</option>\n      </select>\n    </div>\n  </div>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/show/templates/panel.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"1":function(depth0,helpers,partials,data) {
  var lambda=this.lambda, escapeExpression=this.escapeExpression;
  return "  <dd><a href=\"#\" id=\""
    + escapeExpression(lambda((depth0 != null ? depth0.slug : depth0), depth0))
    + "\" class=\"albumlink\">"
    + escapeExpression(lambda((depth0 != null ? depth0.album : depth0), depth0))
    + "</a></dd>\n";
},"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, buffer = "<a class=\"button tiny right\">Show Filters</a>\n<dl class=\"album-sub-nav\">\n  <dt>Albums:</dt>\n  <dd class=\"active\"><a href=\"#\" class=\"albumlink\" id=\"cz_all\">All</a></dd>\n";
  stack1 = helpers.each.call(depth0, (depth0 != null ? depth0.items : depth0), {"name":"each","hash":{},"fn":this.program(1, data),"inverse":this.noop,"data":data});
  if (stack1 != null) { buffer += stack1; }
  return buffer + "</dl>\n\n<!-- <form>\n  <div class=\"row\">\n    <div class=\"small-2 columns\">\n      <label for=\"position\" class=\"right inline\">Position</label>\n    </div>\n    <div class=\"small-4 columns\">\n      <select class=\"chosen-select\" id=\"position\" data-placeholder=\"Position\" multiple>\n      </select>\n    </div>\n    <div class=\"small-2 columns\">\n      <label for=\"station\" class=\"right inline\">Station</label>\n    </div>\n    <div class=\"small-4 columns\">\n      <select class=\"chosen-select\" id=\"station\" data-placeholder=\"Station\" multiple>\n      </select>\n    </div>\n  </div>\n  <div class=\"row\">\n    <div class=\"small-2 columns\">\n      <label for=\"week\" class=\"right inline\">Week</label>\n    </div>\n    <div class=\"small-4 columns\">\n      <select class=\"chosen-select\" id=\"week\" data-placeholder=\"Week\" multiple>\n      </select>\n    </div>\n    <div class=\"small-2 columns\">\n      <label for=\"graph\" class=\"right inline\">Visualizer</label>\n    </div>\n    <div class=\"small-4 columns\">\n      <select id=\"type-select\">\n        <option value=\"bar\">Appearances By Station</option>\n        <option value=\"line\">Appearances By Station Over Time</option>\n      </select>\n    </div>\n  </div>\n  <div class=\"row\">\n    <div class=\"small-1 column right\">\n      <a class=\"button tiny secondary right\" id=\"clearFilters\" href=\"#\">Clear</a>\n    </div>\n  </div>\n</form> -->\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/show/templates/show_layout.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div id=\"artist_layout\">\n  <div class=\"title-row\">\n    <div id=\"title-region\" class=\"small-12 columns\"></div>\n  </div>\n  <div class=\"graph-row\">\n    <div id=\"graph-region\" class=\"small-12 columns\"></div>\n  </div>\n  <div class=\"panel-row\">\n    <div class=\"row\">\n      <div id=\"panel-region\" class=\"small-12 columns\"></div>\n    </div>\n  </div>\n  <div class=\"graph-row\">\n    <div class=\"row\">\n    <div id=\"table-region\" class=\"small-12 columns\"></div>\n  </div>\n</div>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/show/templates/start.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div class=\"panel small-12 columns\">\n  <h4>Enter an artist to get started</h4>\n  <form>\n    <div class=\"station-field\">\n      <label>Artist:<input type=\"text\" id=\"artist_input\"></input></label>\n    </div>\n      <button type=\"submit\">Search</button>\n  </form>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/show/templates/startPanel.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression;
  return escapeExpression(((helper = (helper = helpers.desc || (depth0 != null ? depth0.desc : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"desc","hash":{},"data":data}) : helper)))
    + "\n<div class=\"row\">\n  <div class=\"large-8 columns\">\n    <div class=\"row collapse\">\n      <div class=\"small-2 columns\">\n        <span class=\"prefix radius\">Top</span>\n      </div>\n      <div class=\"small-8 columns\">\n        <input id=\"number\" type=\"number\" placeholder=\"30\"></input>\n      </div>\n      <div class=\"small-2 columns\">\n        <span class=\"postfix radius\"><i class=\"fi-record\"></i></span>\n      </div>\n    </div>\n  </div>\n  <!-- <div class=\"small-4 columns\">\n    <select id=\"time-select\">\n      <option>This Year</option>\n      <option>This Month</option>\n      <option>This Week</option>\n    </select>\n  </div> -->\n  <div class=\"large-4 columns\">\n    <div class=\"row collapse\">\n      <div class=\"small-10 columns\">\n        <input id=\"custom-range\" type=\"text\" placeholder=\"This Week\"></input>\n      </div>\n      <div class=\"small-2 columns\">\n        <span class=\"postfix radius\"><i id=\"custom-range\" class=\"fi-calendar\"></i></span>\n      </div>\n    </div>\n  </div>\n<!-- </div> -->\n</div>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/artists/show/templates/title.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"1":function(depth0,helpers,partials,data) {
  var lambda=this.lambda, escapeExpression=this.escapeExpression;
  return " <a class=\"label radius right\" id=\"popStation\">"
    + escapeExpression(lambda(depth0, depth0))
    + "</a>";
},"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, lambda=this.lambda, escapeExpression=this.escapeExpression, buffer = "<div class=\"row\">\n  <div class=\"small-8 columns\">\n    <h1 class=\"artist-title\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.artist : stack1), depth0))
    + "</h1>\n  </div>\n  <div class=\"small-4 columns\">\n    <h2 class=\"right\">Chartscore: <span class=\"header-label radius\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.totalChartScore : stack1), depth0))
    + "</span></h2>\n  </div>\n</div>\n<div class=\"row\">\n  <div class=\"small-6 columns\">\n    <ul class=\"no-bullet\">\n      <li>Most Charted: <span class=\"label radius right\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.popAlbum : stack1), depth0))
    + "</span></li>\n      <li>Most Charted on:";
  stack1 = helpers.each.call(depth0, ((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.popStation : stack1), {"name":"each","hash":{},"fn":this.program(1, data),"inverse":this.noop,"data":data});
  if (stack1 != null) { buffer += stack1; }
  return buffer + "</li>\n      <!-- <li>ChartScore: <span class=\"label radius right\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.totalChartScore : stack1), depth0))
    + "</span></li> -->\n    </ul>\n  </div>\n  <div class=\"small-6 columns\">\n    <ul class=\"no-bullet\">\n      <li>Albums: <span class=\"label radius right\">"
    + escapeExpression(lambda(((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1.length : stack1), depth0))
    + "</span></li>\n      <li>Appearances: <span class=\"label radius right\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.totalAppearances : stack1), depth0))
    + "</span></li>\n\n    </ul>\n  </div>\n</div>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/footer/footer_app.coffee", function(exports, require, module) {
var App;

App = require('application');

module.exports = App.module("FooterApp", function(FooterApp, App, Backbone, Marionette, $, _) {
  var API;
  FooterApp.startWithParent = false;
  FooterApp.Show = require('modules/footer/show/show_controller');
  API = {
    showFooter: function() {
      return new FooterApp.Show.Controller({
        region: App.footerRegion
      });
    }
  };
  return FooterApp.on("start", function() {
    return API.showFooter();
  });
});

});

require.register("modules/footer/show/show_controller.coffee", function(exports, require, module) {
var App, Controllers, FooterApp,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('application');

FooterApp = require('modules/footer/footer_app');

Controllers = require('controllers/baseController');

module.exports = App.module("FooterApp.Show", function(Show, App, Backbone, Marionette, $, _) {
  var _ref, _ref1;
  Show.Footer = (function(_super) {
    __extends(Footer, _super);

    function Footer() {
      _ref = Footer.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Footer.prototype.template = 'views/templates/footer';

    return Footer;

  })(Marionette.ItemView);
  return Show.Controller = (function(_super) {
    __extends(Controller, _super);

    function Controller() {
      _ref1 = Controller.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Controller.prototype.initialize = function() {
      var footerView;
      footerView = this.getFooterView();
      return this.show(footerView);
    };

    Controller.prototype.getFooterView = function() {
      return new Show.Footer;
    };

    return Controller;

  })(App.Controllers.Base);
});

});

require.register("modules/header/header_app.coffee", function(exports, require, module) {
var App;

App = require('application');

module.exports = App.module('HeaderApp', function(HeaderApp, App, Backbone, Marionette, $, _) {
  var API;
  HeaderApp.startWithParent = false;
  HeaderApp.List = require('modules/header/list/list_controller');
  API = {
    listHeader: function() {
      var listController;
      return listController = new HeaderApp.List.Controller({
        region: App.headerRegion
      });
    }
  };
  return HeaderApp.on('start', function() {
    return API.listHeader();
  });
});

});

require.register("modules/header/list/list_controller.coffee", function(exports, require, module) {
var App, HeaderApp,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('application');

HeaderApp = require('modules/header/header_app');

module.exports = App.module('HeaderApp.List', function(List, App, Backbone, Marionette, $, _) {
  var _ref, _ref1, _ref2;
  List.Header = (function(_super) {
    __extends(Header, _super);

    function Header() {
      _ref = Header.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Header.prototype.template = "modules/header/list/templates/header";

    Header.prototype.tagName = "li";

    Header.prototype.events = {
      'click': 'nav'
    };

    Header.prototype.nav = function(e) {
      var route;
      e.preventDefault();
      route = this.model.get('path');
      if (route.substring(0, 4) === "http") {
        return window.open(route);
      } else {
        return App.navigate(route, {
          trigger: true
        });
      }
    };

    return Header;

  })(Marionette.ItemView);
  List.Headers = (function(_super) {
    __extends(Headers, _super);

    function Headers() {
      _ref1 = Headers.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Headers.prototype.template = 'modules/header/list/templates/headers';

    Headers.prototype.itemView = List.Header;

    Headers.prototype.itemViewContainer = "ul.links";

    Headers.prototype.events = {
      "click a#home": "home"
    };

    Headers.prototype.onRender = function() {
      var _this = this;
      $(document).on('open', '#feedback', function() {
        ga('send', 'event', 'click', 'open feedback');
        $("a#clear").on("click", function(e) {
          ga('send', 'event', 'click', 'clear feedback');
          $("input, textarea").val('');
          $("form div").removeClass("error");
          $("form label").removeClass("error");
          return $("form")[0].reset();
        });
        return $("#feedback-form").on("invalid", function() {
          var invalid_fields;
          invalid_fields = $(this).find("[data-invalid]");
          return ga('send', 'event', 'form', 'feedback form invalid');
        }).on("valid", Foundation.utils.debounce(function(e) {
          return _this.send(e);
        }, 300, true));
      });
      return $(document).on('close', '#feedback', function() {
        $("div#alert-container").fadeOut();
        $("form div").removeClass("error");
        $("form label").removeClass("error");
        return $("form")[0].reset();
      });
    };

    Headers.prototype.send = function(e) {
      e.preventDefault();
      return $.post("/api/feedback", $("#feedback-form").serialize(), function(data) {
        ga('send', 'event', 'submit', 'submit feedback');
        $("input, textarea").val('');
        return $("div#alert-container").fadeIn('slow').removeClass("hide");
      });
    };

    Headers.prototype.home = function(e) {
      var route;
      e.preventDefault();
      route = "home";
      return App.navigate(route, {
        trigger: true
      });
    };

    Headers.prototype.clear = function(e) {
      e.preventDefault();
      return console.log("clicked");
    };

    return Headers;

  })(Marionette.CompositeView);
  return List.Controller = (function(_super) {
    __extends(Controller, _super);

    function Controller() {
      _ref2 = Controller.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Controller.prototype.initialize = function() {
      this.listHeader();
      return $(document).foundation();
    };

    Controller.prototype.listHeader = function() {
      var headerView, links;
      links = App.request("header:entities");
      window.links = links;
      headerView = this.getHeaderView(links);
      return this.show(headerView);
    };

    Controller.prototype.getHeaderView = function(links) {
      return new List.Headers({
        collection: links
      });
    };

    return Controller;

  })(App.Controllers.Base);
});

});

require.register("modules/header/list/templates/header.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression;
  return "<a><i class=\""
    + escapeExpression(((helper = (helper = helpers.icon || (depth0 != null ? depth0.icon : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"icon","hash":{},"data":data}) : helper)))
    + "\"></i>  "
    + escapeExpression(((helper = (helper = helpers.name || (depth0 != null ? depth0.name : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"name","hash":{},"data":data}) : helper)))
    + "</a>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/header/list/templates/headers.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div id=\"feedback\" class=\"reveal-modal small\" data-reveal>\n  <h2>Thanks for trying out ChartZapp!</h2>\n  <p class=\"lead\">The project is currently under active development,\n    and I'd love to hear your thoughts about it!</p>\n    <div class=\"hide\" id=\"alert-container\">\n      <div data-alert id=\"success\" class=\"hide alert-box success radius\">\n        Thanks for your feedback!\n        <a href=\"#\" class=\"close\">&times;</a>\n      </div>\n    </div>\n  <form id=\"feedback-form\" data-abide=\"ajax\">\n    <div class=\"name-field\">\n      <input type=\"text\" placeholder=\"Name\" id=\"name\" name=\"name\" required></input>\n      <small class=\"error\">Please enter your name</small>\n    </div>\n    <div class=\"email-field\">\n      <input type=\"email\" placeholder=\"Email\" id=\"email\" name=\"email\" required></input>\n      <small class=\"error\">I can't respond without your email!</small>\n    </div>\n    <div class=\"message-field\">\n      <textarea id=\"message\" placeholder=\"Thoughts...\" rows=\"10\" name=\"message\" required></textarea>\n      <small class=\"error\">A message is kind of the point...</small>\n    </div>\n    <button id=\"form-submit\" type=\"submit\">Submit</button>\n    <a class=\"button secondary\" id=\"clear\">Clear</a>\n  </form>\n  <a class=\"close-reveal-modal\">&#215;</a>\n</div>\n\n<div class=\"fixed\">\n  <nav class=\"top-bar\" data-topbar>\n    <ul class=\"title-area\">\n      <li class=\"name\"><h1><a id=\"home\">!earshot :: ChartZapp!</a></h1></li>\n      <li class=\"toggle-topbar menu-icon\"><a href=\"#\"></a></li>\n    </ul>\n    <section class=\"top-bar-section\">\n      <ul class=\"right links\">\n        <li class=\"has-form right\">\n          <a href=\"#\" class=\"button radius\" data-reveal-id=\"feedback\"><i class=\"fi-mail\"></i> Feedback!</a>\n        </li>\n      </ul>\n    </section>\n  </nav>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/landing/landing_app.coffee", function(exports, require, module) {
var App,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('application');

module.exports = App.module('LandingApp', function(LandingApp, App, Backbone, Marionette, $, _) {
  var API, _ref;
  LandingApp.Router = (function(_super) {
    __extends(Router, _super);

    function Router() {
      _ref = Router.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Router.prototype.appRoutes = {
      "home": "landing"
    };

    return Router;

  })(Marionette.AppRouter);
  LandingApp.startWithParent = false;
  LandingApp.Show = require('modules/landing/showLanding/showLanding_controller');
  API = {
    landing: function() {
      new LandingApp.Show.Controller({
        region: App.mainRegion
      });
      return $(document).foundation();
    }
  };
  return App.addInitializer(function() {
    return new LandingApp.Router({
      controller: API
    });
  });
});

});

require.register("modules/landing/showLanding/labelsGraph.coffee", function(exports, require, module) {
var App, slugify, tuesify;

App = require("application");

slugify = function(Text) {
  var isNumber;
  isNumber = function(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
  };
  if (isNumber(Text.charAt(0))) {
    Text = "_" + Text;
  }
  return Text.toLowerCase().replace(RegExp(" ", "g"), "-").replace(/[^\w-]+/g, "");
};

tuesify = function(date) {
  var theDay, theTues, theWeek;
  theWeek = (function() {
    switch (false) {
      case !date:
        return moment(date);
      default:
        return moment();
    }
  })();
  theDay = theWeek.get('day');
  theTues = (function() {
    switch (false) {
      case theDay !== 0:
        return theWeek.day(-5);
      case theDay !== 1:
        return theWeek.day(-5);
      case theDay !== 2:
        return theWeek;
      case !(theDay > 2):
        return theWeek.day(2);
    }
  })();
  theTues = moment(theTues);
  return theTues.format('YYYY-MM-DD');
};

module.exports = function(el, collection, view) {
  var aByL, albums, arc, bA, click, color, g, height, lA, labelPie, labels, margin, mouseout, mouseover, others, radius, showData, showEmpty, svg, tA, topLabels, width;
  margin = {
    top: 50,
    right: 50,
    bottom: 50,
    left: 50
  };
  width = ($("#circles-region").width() - margin.left - margin.right) / 3;
  height = 500 - margin.top - margin.bottom;
  radius = Math.min(width, height) / 2;
  color = require('colorList');
  arc = d3.svg.arc().outerRadius(radius - 10).innerRadius(radius - 100);
  labelPie = d3.layout.pie().sort(null).value(function(d) {
    return d.chartScore;
  });
  svg = d3.select(el).select("#labels").append("svg").attr("width", width + margin.left + margin.right).attr("height", height).append("g").attr("transform", "translate(" + (width / 2) + ", " + (height / 2) + ")");
  albums = collection.models;
  labels = {};
  lA = [];
  aByL = {};
  _.each(albums, function(album) {
    var label;
    if (album.attributes.album !== '') {
      label = album.get('label');
      if (aByL[label]) {
        aByL[label].push(album.get('album'));
      } else {
        aByL[label] = [album.get('album')];
      }
      if (labels[label]) {
        return _.each(album.attributes.appearances, function(ap) {
          return labels[label].push(ap);
        });
      } else {
        labels[label] = [];
        return _.each(album.attributes.appearances, function(ap) {
          return labels[label].push(ap);
        });
      }
    }
  });
  _.each(aByL, function(ar, l) {
    return ar = _.uniq(ar);
  });
  _.each(labels, function(array, label) {
    return lA.push({
      label: label,
      appearances: array,
      albums: aByL[label]
    });
  });
  _.each(lA, function(label) {
    label.chartScore = 0;
    return _.each(label.appearances, function(ap) {
      return label.chartScore += 31 - +ap.position;
    });
  });
  lA = lA.sort(function(a, b) {
    a = a.chartScore;
    b = b.chartScore;
    if (a === b) {
      return 0;
    }
    if (a > b) {
      return -1;
    } else {
      return 1;
    }
  });
  tA = lA.slice(0, 30);
  bA = lA.slice(30);
  topLabels = [];
  others = {
    labels: [],
    chartScore: 0,
    label: "",
    appearances: [],
    albums: []
  };
  _.each(bA, function(label) {
    others.labels.push(label.label);
    others.albums.push(label.albums);
    return _.each(label.appearances, function(ap) {
      return others.appearances.push(ap);
    });
  });
  _.each(tA, function(label) {
    return topLabels.push(label);
  });
  others.label = "" + others.labels.length + " Others";
  others.albums = _.flatten(others.albums);
  _.each(others.appearances, function(ap) {
    return others.chartScore += 31 - ap.position;
  });
  topLabels.push(others);
  mouseover = function(d, i) {
    d3.selectAll("g.arc").transition().duration(100).style("opacity", 0.2);
    d3.select("g ." + (slugify(d.data.label))).transition().duration(100).style("opacity", 1);
    return showData(this, d);
  };
  mouseout = function() {
    d3.selectAll("g.arc").transition().duration(100).style("opacity", 1);
    return $(".tip").fadeOut(50).remove();
  };
  click = function(d) {
    var artist;
    artist = d.attributes.artist;
    return view.trigger("click:album:circle", artist);
  };
  showData = function(circle, d) {
    var chartTip, coord;
    coord = d3.mouse(circle);
    $("#labels").append("<div class='tip'></div>");
    chartTip = d3.select(".tip");
    chartTip.style("right", 1.25 + "rem").style("top", 50 + "px").style("background", color(d.data.label));
    $(".tip").html("" + d.data.label + "<br />\n# of Albums: " + d.data.albums.length + "<br />\n# of Appearances: " + d.data.appearances.length + "<br />\nChartscore: " + d.data.chartScore);
    return $(".tip").fadeIn(100);
  };
  showEmpty = function() {
    return $(el).append("<div class='tip text-center'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 2 + "px").html("<br />\nSorry, No Data is available for the selected Time Range.\n<br />\n<br />").fadeIn(100);
  };
  g = svg.selectAll(".arc").data(labelPie(topLabels)).enter().append("g").attr("class", function(d) {
    return "arc " + (slugify(d.data.label));
  });
  g.append("path").attr("d", arc).style("fill", function(d) {
    return color(d.data.label);
  });
  g.on("mouseover", mouseover).on('mouseout', mouseout);
  if (albums.length === 0) {
    return showEmpty();
  }
};

});

require.register("modules/landing/showLanding/landingGraph.coffee", function(exports, require, module) {
var App, tuesify;

App = require("application");

tuesify = function(date) {
  var theDay, theTues, theWeek;
  theWeek = (function() {
    switch (false) {
      case !date:
        return moment(date);
      default:
        return moment();
    }
  })();
  theDay = theWeek.get('day');
  theTues = (function() {
    switch (false) {
      case theDay !== 0:
        return theWeek.day(-5);
      case theDay !== 1:
        return theWeek.day(-5);
      case theDay !== 2:
        return theWeek;
      case !(theDay > 2):
        return theWeek.day(2);
    }
  })();
  theTues = moment(theTues);
  return theTues.format('YYYY-MM-DD');
};

module.exports = function(el, collection, view) {
  var albumCircles, albums, click, color, height, hideInfo, margin, mouseout, mouseover, rScale, showData, showEmpty, showInfo, svg, width, x, xAxis, y, yAxis;
  margin = {
    top: 100,
    right: 120,
    bottom: 50,
    left: 50
  };
  width = $("#graph-region").width() - margin.left - margin.right;
  height = 500 - margin.top - margin.bottom;
  y = d3.scale.linear().range([0, height]);
  x = d3.scale.linear().range([0, width - 100]);
  color = require('colorList');
  xAxis = d3.svg.axis().scale(x).orient("bottom");
  yAxis = d3.svg.axis().scale(y).orient("left");
  svg = d3.select(el).append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + (margin.left + 20) + "," + margin.top + ")");
  albums = collection.models;
  albums = albums.slice(0, 30);
  rScale = d3.scale.linear();
  rScale.domain(d3.extent(albums, function(c) {
    return c.attributes.frontPoints;
  }));
  rScale.range([5, 130]);
  y.domain([
    d3.max(albums, function(c) {
      return c.attributes.appearances.length;
    }), d3.min(albums, function(c) {
      return c.attributes.appearances.length;
    })
  ]);
  x.domain(d3.extent(albums, function(c) {
    return c.attributes.frontPoints;
  }));
  svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis);
  if (albums.length !== 0) {
    svg.append("g").attr("class", "y axis").attr("transform", "translate(-10,0)").call(yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style("text-anchor", "end").text("# of Appearances");
  }
  mouseover = function(d, i) {
    d3.selectAll("g circle").transition().duration(100).style("opacity", 0.2);
    d3.select("g ." + d.attributes.slug).transition().duration(100).style("opacity", 1);
    return showData(this, d);
  };
  mouseout = function() {
    d3.selectAll("g circle").transition().duration(100).style("opacity", 1);
    return $(".tip").fadeOut(50).remove();
  };
  click = function(d) {
    var artist;
    artist = d.attributes.artist;
    return view.trigger("click:album:circle", artist);
  };
  showData = function(circle, d) {
    var chartTip, coord;
    coord = d3.mouse(circle);
    $("#graph").append("<div class='tip'></div>");
    chartTip = d3.select(".tip");
    chartTip.style("left", 150 + "px").style("top", 50 + "px").style("background", color(d.attributes.rank));
    $(".tip").html("#" + d.attributes.rank + ": " + d.attributes.artist + " <br />\n" + d.attributes.album + "<br />\nTotal Appearances: " + d.attributes.appearances.length + "<br />\nChartscore: " + d.attributes.frontPoints + "<br />\nFirst Appearance: " + d.attributes.firstWeek + "<br />\nAppeared on " + d.attributes.stations.length + " / " + d.attributes.totalStations + " stations");
    return $(".tip").fadeIn(100);
  };
  showEmpty = function() {
    return $(el).append("<div class='tip text-center'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 2 + "px").html("<br />\nSorry, No Data is available for the selected Time Range.\n<br />\n<br />").fadeIn(100);
  };
  showInfo = function() {
    if ($(el).find(".tip").length !== 0) {
      return $(".info").remove();
    } else {
      return $(el).append("<div class='tip text-center info'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 3 + "px").html("<br />\nThis graph displays the top albums for all stations over the selected time range.<br />\nThe X-Axis and the Radius of each circle is determined by the album's Chartscore.<br />\nThe Y-Axis is determined by the album's total number of appearances.<br />\n<br />\nMouseover any circle for more information.<br />\n<br />\n(Click anywhere to hide)\n<br />\n<br />").on("click", hideInfo).fadeIn(100);
    }
  };
  hideInfo = function() {
    $(el).find(".info").fadeOut(100);
    return $(".info").remove();
  };
  $(el).prepend("<div class='button tiny radius infobox'></div>").find(".infobox").html("<i class='fi-info large'></i>").on("click", showInfo);
  $(el).find("svg").on("click", hideInfo);
  albumCircles = svg.selectAll("circle").data(albums).enter().append("circle").attr("fill", function(d) {
    return color(d.attributes.rank);
  }).attr("class", function(d) {
    return "dot " + d.attributes.slug;
  }).attr("cy", function(d) {
    var num;
    num = d.attributes.appearances.length;
    return y(num);
  }).attr("cx", function(d, i) {
    return x(d.attributes.frontPoints);
  }).attr("r", function(d) {
    return rScale(d.attributes.frontPoints);
  });
  albumCircles.on("mouseover", mouseover).on("mouseout", mouseout).on("click", click);
  if (albums.length === 0) {
    return showEmpty();
  }
};

});

require.register("modules/landing/showLanding/newAlbumsGraph.coffee", function(exports, require, module) {
var App, slugify, tuesify;

App = require("application");

slugify = function(Text) {
  var isNumber;
  isNumber = function(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
  };
  if (isNumber(Text.charAt(0))) {
    Text = "_" + Text;
  }
  return Text.toLowerCase().replace(RegExp(" ", "g"), "-").replace(/[^\w-]+/g, "");
};

tuesify = function(date) {
  var theDay, theTues, theWeek;
  theWeek = (function() {
    switch (false) {
      case !date:
        return moment(date);
      default:
        return moment();
    }
  })();
  theDay = theWeek.get('day');
  theTues = (function() {
    switch (false) {
      case theDay !== 0:
        return theWeek.day(-5);
      case theDay !== 1:
        return theWeek.day(-5);
      case theDay !== 2:
        return theWeek;
      case !(theDay > 2):
        return theWeek.day(2);
    }
  })();
  theTues = moment(theTues);
  return theTues.format('YYYY-MM-DD');
};

module.exports = function(el, collection, view) {
  var albums, arc, click, color, g, height, margin, mouseout, mouseover, newPie, oldVNew, pie, radius, showData, showEmpty, svg, width;
  margin = {
    top: 50,
    right: 50,
    bottom: 50,
    left: 50,
    gutter: 30
  };
  width = ($("#circles-region").width() - margin.left - margin.right) / 3 - (margin.gutter * 4);
  height = 500 - margin.top - margin.bottom;
  radius = Math.min(width, height) / 2;
  color = require('colorList');
  arc = d3.svg.arc().outerRadius(radius - 10).innerRadius(0);
  pie = d3.layout.pie().value(function(d) {
    return d.length;
  });
  newPie = d3.layout.pie().value(function(d) {
    return d.length;
  });
  svg = d3.select(el).select("#newAlbums").append("svg").attr("width", width + margin.left + margin.right).attr("height", height).append("g").attr("transform", "translate(" + (width / 2 + margin.gutter * 1.75) + ", " + (height / 2) + ")");
  albums = collection.models;
  oldVNew = [];
  oldVNew[0] = _.filter(albums, function(album) {
    return _.indexOf(collection.potentialA, album.attributes.firstWeek) !== -1;
  });
  oldVNew[1] = _.filter(albums, function(album) {
    return _.indexOf(collection.potentialA, album.attributes.firstWeek) === -1;
  });
  _.each(oldVNew, function(array) {
    return array.sort(function(a, b) {
      a = a.get('frontPoints');
      b = b.get('frontPoints');
      if (a === b) {
        return 0;
      }
      if (a > b) {
        return -1;
      } else {
        return 1;
      }
    });
  });
  mouseover = function(d, i) {
    d3.selectAll("g.arc").transition().duration(100).style("opacity", 0.2);
    d3.select("g ._" + i).transition().duration(100).style("opacity", 1);
    return showData(this, d, i);
  };
  mouseout = function() {
    d3.selectAll("g.arc").transition().duration(100).style("opacity", 1);
    return $(".tip").fadeOut(50).remove();
  };
  click = function(d, i) {
    var $this, choice;
    $this = d3.select(this);
    if ($this.classed("arc _0")) {
      if ($this.classed("selected")) {
        view.trigger("switch:all");
        $this.attr("class", "arc _0");
      } else {
        view.trigger("switch:debuts");
        $this.attr("class", "arc _0 selected");
        d3.select("g ._1").attr("class", "arc _1");
      }
    } else {
      view.trigger("switch:all");
      d3.select("g ._0").attr("class", "arc _0");
    }
    return choice = ["debuts", "all"];
  };
  showData = function(circle, d, i) {
    var chartTip, coord;
    coord = d3.mouse(circle);
    $("#newAlbums").append("<div class='tip'></div>");
    chartTip = d3.select(".tip");
    chartTip.style("right", 1.25 + "rem").style("top", 50 + "px").style("background", color(i));
    $(".tip").html("" + (i === 0 ? "New This Week" : "Previously Appeared") + "<br />\nAlbums: " + d.data.length + "<br />\n" + ((+d.data.length / +albums.length * 100).toFixed(0)) + "%<br />\n#1: " + (d.data[0].get('artist')) + " - " + (d.data[0].get('album')));
    return $(".tip").fadeIn(100);
  };
  showEmpty = function() {
    return $(el).append("<div class='tip text-center'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 2 + "px").html("<br />\nSorry, No Data is available for the selected Time Range.\n<br />\n<br />").fadeIn(100);
  };
  g = svg.selectAll(".arc").data(pie(oldVNew)).enter().append("g").attr("class", function(d, i) {
    return "arc _" + i;
  });
  g.append("path").attr("d", arc).style("fill", function(d, i) {
    return color(i);
  });
  g.on("mouseover", mouseover).on('mouseout', mouseout).on('click', click);
  if (albums.length === 0) {
    return showEmpty();
  }
};

});

require.register("modules/landing/showLanding/reportingGraph.coffee", function(exports, require, module) {
var App, slugify, tuesify;

App = require("application");

slugify = function(Text) {
  var isNumber;
  isNumber = function(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
  };
  if (isNumber(Text.charAt(0))) {
    Text = "_" + Text;
  }
  return Text.toLowerCase().replace(RegExp(" ", "g"), "-").replace(/[^\w-]+/g, "");
};

tuesify = function(date) {
  var theDay, theTues, theWeek;
  theWeek = (function() {
    switch (false) {
      case !date:
        return moment(date);
      default:
        return moment();
    }
  })();
  theDay = theWeek.get('day');
  theTues = (function() {
    switch (false) {
      case theDay !== 0:
        return theWeek.day(-5);
      case theDay !== 1:
        return theWeek.day(-5);
      case theDay !== 2:
        return theWeek;
      case !(theDay > 2):
        return theWeek.day(2);
    }
  })();
  theTues = moment(theTues);
  return theTues.format('YYYY-MM-DD');
};

module.exports = function(el, collection, view) {
  var albums, arc, click, color, data, g, height, margin, mouseout, mouseover, pie, radius, showData, showEmpty, stations, svg, width;
  margin = {
    top: 50,
    right: 50,
    bottom: 50,
    left: 50
  };
  width = $("#circles-region").width() / 3 - margin.left - margin.right;
  height = 500 - margin.top - margin.bottom;
  radius = Math.min(width, height) / 2;
  color = require('colorList');
  arc = d3.svg.arc().outerRadius(radius - 10).innerRadius(radius - 30);
  pie = d3.layout.pie().value(function(d) {
    return d;
  });
  svg = d3.select(el).select("#reporting").append("svg").attr("width", width + margin.left + margin.right).attr("height", height).append("g").attr("transform", "translate(" + (width / 2 + 30) + ", " + (height / 2) + ")");
  albums = collection.models;
  stations = collection.stations;
  data = [stations.length, 49 - stations.length];
  mouseover = function(d, i) {
    d3.selectAll("g.arc").transition().duration(100).style("opacity", 0.2);
    d3.select("g ._" + d.data).transition().duration(100).style("opacity", 1);
    return showData(this, d, i);
  };
  mouseout = function() {
    d3.selectAll("g.arc").transition().duration(100).style("opacity", 1);
    return $(".tip").fadeOut(50).remove();
  };
  click = function(d) {
    var artist;
    artist = d.attributes.artist;
    return view.trigger("click:album:circle", artist);
  };
  showData = function(circle, d, i) {
    var chartTip, coord;
    coord = d3.mouse(circle);
    $("#reporting").append("<div class='tip'></div>");
    chartTip = d3.select(".tip");
    chartTip.style("right", 1.25 + "rem").style("top", 50 + "px").style("background", color(i));
    $(".tip").html("" + (i === 0 ? "Reporting Stations" : "Not Reporting") + "<br />\nStations: " + d.data + "<br />\n" + ((+d.data / 49 * 100).toFixed(0)) + "%\n");
    return $(".tip").fadeIn(100);
  };
  showEmpty = function() {
    return $(el).append("<div class='tip text-center'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 2 + "px").html("<br />\nSorry, No Data is available for the selected Time Range.\n<br />\n<br />").fadeIn(100);
  };
  g = svg.selectAll(".arc").data(pie(data)).enter().append("g").attr("class", function(d, i) {
    return "arc _" + d.data;
  });
  g.append("path").attr("d", arc).style("fill", function(d, i) {
    return color(i);
  });
  g.on("mouseover", mouseover).on('mouseout', mouseout);
  if (albums.length === 0) {
    return showEmpty();
  }
};

});

require.register("modules/landing/showLanding/showLanding_controller.coffee", function(exports, require, module) {
var App, Controllers,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

App = require("application");

Controllers = require("controllers/baseController");

module.exports = App.module('LandingApp.Show', function(Show, App, Backbone, Marionette, $, _) {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
  Show.Controller = (function(_super) {
    __extends(Controller, _super);

    function Controller() {
      _ref = Controller.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Controller.prototype.initialize = function(opts) {
      var stations,
        _this = this;
      this.layout = this.getLayoutView();
      stations = App.request("stations:entities");
      this.startDate = '';
      this.endDate = '';
      this.request = '';
      this.number = 30;
      this.listenTo(this.layout, 'show', function() {
        _this.showChart();
        return _this.showList(stations);
      });
      this.listenTo(this.layout, 'change:time', function(time) {
        var search;
        search = {};
        search.request = time;
        _this.request = time;
        return _this.showChart(search);
      });
      this.listenTo(this.layout, 'change:number', function(number) {
        _this.number = number;
        topCharts.trigger("filter");
        return _this.showChart(number);
      });
      this.show(this.layout, {
        loading: true
      });
      return $(document).foundation();
    };

    Controller.prototype.showChart = function(search) {
      var chartView, lCharts, startDate, topCharts,
        _this = this;
      if (search == null) {
        search = {};
      }
      startDate = moment();
      if (startDate.day() === 2) {
        startDate.day(-5);
        if (!search.endDate) {
          search.endDate = startDate;
        }
      }
      if (!search.startDate) {
        search.startDate = startDate;
      }
      topCharts = App.request('topx:entities', search);
      lCharts = topCharts.clone();
      chartView = this.getChartView(lCharts);
      this.showGraph(topCharts);
      this.showInfo(topCharts);
      if (search.request) {
        this.show(chartView, {
          region: this.layout.tableRegion,
          loading: {
            loadingType: "opacity"
          }
        });
      } else {
        this.show(chartView, {
          region: this.layout.tableRegion,
          loading: true
        });
      }
      App.execute("when:fetched", topCharts, function() {
        topCharts.initializeFilters();
        topCharts.sort();
        lCharts.initializeFilters();
        lCharts.set(topCharts.first(_this.number));
        return $(document).foundation();
      });
      return topCharts.on("filter", function() {
        return lCharts.reset(topCharts.first(this.number));
      });
    };

    Controller.prototype.showInfo = function(topCharts) {
      var infoView,
        _this = this;
      infoView = this.getInfoView(topCharts);
      this.listenTo(infoView, 'change:range', function(time) {
        var search, string;
        search = {};
        search.request = 1;
        _this.request = '';
        search.number = _this.number;
        search.startDate = moment(time.date1);
        _this.startDate = search.startDate;
        search.endDate = moment(time.date2);
        _this.endDate = search.endDate;
        console.log(search);
        string = "" + (search.startDate.format('YYYY-MM-DD')) + " - " + (search.endDate.format('YYYY-MM-DD'));
        ga('send', 'event', 'change:date', string);
        return _this.showChart(search);
      });
      this.listenTo(infoView, 'click:week', function(req) {
        var currentWeek, now, reqWeek, search;
        currentWeek = moment(req.week);
        now = moment();
        switch (req.dir) {
          case "next":
            reqWeek = currentWeek.day(9);
            if (reqWeek > now) {
              reqWeek = now;
            }
            break;
          case "prev":
            reqWeek = currentWeek.day(-5);
            break;
          default:
            reqWeek = currentWeek;
        }
        search = {
          startDate: reqWeek.format("YYYY-MM-DD"),
          endDate: reqWeek.format('YYYY-MM-DD')
        };
        return _this.showChart(search);
      });
      return this.show(infoView, {
        region: this.layout.infoRegion,
        loading: true
      });
    };

    Controller.prototype.showSearch = function(stations) {
      var searchView;
      searchView = this.getSearchView(stations);
      this.listenTo(searchView, 'click:search', function(newSearch) {
        switch (newSearch.kind) {
          case "artist":
            return App.navigate("/artist/" + newSearch.keyword, {
              trigger: true
            });
          case "station":
            return App.navigate("/station/" + newSearch.keyword, {
              trigger: true
            });
        }
      });
      this.show(searchView, {
        region: this.layout.searchRegion,
        loading: true
      });
      return $(document).foundation();
    };

    Controller.prototype.showGraph = function(topCharts) {
      var circlesView, graphView;
      graphView = this.getGraphView(topCharts);
      circlesView = this.getCirclesView(topCharts);
      this.listenTo(graphView, 'click:album:circle', function(d) {
        return App.navigate("/artist/" + (encodeURIComponent(d)), {
          trigger: true
        });
      });
      this.listenTo(circlesView, 'switch:debuts', function(d) {
        var newFilters;
        topCharts.resetFilters();
        newFilters = [];
        if (topCharts.potentialA.length > 1) {
          _.each(topCharts.potentialA, function(week) {
            return newFilters.push({
              firstWeek: week
            });
          });
          return topCharts.addFilters(newFilters);
        } else {
          return topCharts.addFilter({
            firstWeek: topCharts.potentialA[0]
          });
        }
      });
      this.listenTo(circlesView, 'switch:all', function() {
        return topCharts.resetFilters();
      });
      this.show(graphView, {
        region: this.layout.graphRegion,
        loading: true
      });
      return this.show(circlesView, {
        region: this.layout.circlesRegion,
        loading: true
      });
    };

    Controller.prototype.showList = function(stations) {
      var listView;
      listView = this.getListView(stations);
      return this.show(listView, {
        region: this.layout.listRegion,
        loading: true
      });
    };

    Controller.prototype.getSearchView = function(stations) {
      return new Show.Search({
        collection: stations
      });
    };

    Controller.prototype.getLayoutView = function() {
      return new Show.Layout;
    };

    Controller.prototype.getGraphView = function(topCharts) {
      return new Show.Graph({
        collection: topCharts
      });
    };

    Controller.prototype.getCirclesView = function(topCharts) {
      return new Show.Circles({
        collection: topCharts
      });
    };

    Controller.prototype.getListView = function(stations) {
      return new Show.StationList({
        collection: stations
      });
    };

    Controller.prototype.getInfoView = function(topCharts) {
      return new Show.Info({
        model: new Backbone.Model(topCharts)
      });
    };

    Controller.prototype.getChartView = function(topCharts) {
      return new Show.Chart({
        collection: topCharts
      });
    };

    return Controller;

  })(App.Controllers.Base);
  Show.Layout = (function(_super) {
    __extends(Layout, _super);

    function Layout() {
      _ref1 = Layout.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Layout.prototype.template = "modules/landing/showLanding/templates/show_layout";

    Layout.prototype.id = "landing-page";

    Layout.prototype.ui = {
      "timeSelect": "#time-select",
      "range": "input#custom-range",
      "icon": "i#custom-range",
      "number": "#number"
    };

    Layout.prototype.events = {
      "change @ui.timeSelect": "select",
      "change @ui.number": "changeNumber"
    };

    Layout.prototype.changeNumber = function(e) {
      return this.trigger('change:number', this.ui.number.val());
    };

    Layout.prototype.select = function(e) {
      return this.trigger('change:time', this.ui.timeSelect.val());
    };

    Layout.prototype.regions = {
      titleRegion: "#title_region",
      blurbRegion: "#blurb_region",
      infoRegion: "#info-region",
      graphRegion: "#graph-region",
      circlesRegion: "#circles-region",
      tableRegion: "#table_region",
      listRegion: "#list_region"
    };

    return Layout;

  })(Marionette.Layout);
  Show.Info = (function(_super) {
    __extends(Info, _super);

    function Info() {
      _ref2 = Info.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Info.prototype.template = "modules/landing/showLanding/templates/info";

    Info.prototype.ui = {
      "timeSelect": "#time-select",
      "range": "input#custom-range",
      "icon": "i#custom-range",
      "number": "#number",
      "text": "#text"
    };

    Info.prototype.events = {
      'click .next': 'clickNext'
    };

    Info.prototype.clickNext = function(e) {
      var request;
      e.preventDefault();
      request = {
        week: $(e.target).data("week"),
        dir: e.target.id
      };
      return this.trigger('click:week', request);
    };

    Info.prototype.onRender = function() {
      var _this = this;
      this.ui.text.on("click", function(e) {
        e.stopPropagation();
        return _this.ui.icon.click();
      });
      return this.ui.icon.dateRangePicker({
        startDate: "2014-01-01",
        endDate: moment(),
        batchMode: false,
        shortcuts: {
          'prev': ['week', 'month', 'year'],
          'prev-days': [7, 14],
          'next-days': false,
          'next': false
        }
      }).bind('datepicker-change', function(event, obj) {
        return _this.trigger('change:range', obj);
      });
    };

    return Info;

  })(Marionette.ItemView);
  Show.Search = (function(_super) {
    __extends(Search, _super);

    function Search() {
      _ref3 = Search.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    Search.prototype.template = "modules/landing/showLanding/templates/search";

    Search.prototype.ui = {
      'searchInput': '#search_input',
      'kind': '#kind_input'
    };

    Search.prototype.events = {
      'submit': 'submit'
    };

    Search.prototype.submit = function(e) {
      var search;
      e.preventDefault();
      search = {};
      search.keyword = $.trim(this.ui.searchInput.val());
      search.kind = $.trim(this.ui.kind.val());
      return this.trigger('click:search', search);
    };

    return Search;

  })(Marionette.ItemView);
  Show.Graph = (function(_super) {
    __extends(Graph, _super);

    function Graph() {
      _ref4 = Graph.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    Graph.prototype.template = "modules/landing/showLanding/templates/graph";

    Graph.prototype.buildGraph = require("modules/landing/showLanding/landingGraph");

    Graph.prototype.graph = function() {
      return this.buildGraph(this.el, this.collection, this);
    };

    Graph.prototype.id = "graph";

    Graph.prototype.initialize = function() {
      return this.collection.on("filter", this.render);
    };

    Graph.prototype.onRender = function() {
      if (matchMedia(Foundation.media_queries['medium']).matches) {
        return this.graph();
      }
    };

    return Graph;

  })(Marionette.ItemView);
  Show.Circles = (function(_super) {
    __extends(Circles, _super);

    function Circles() {
      _ref5 = Circles.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    Circles.prototype.template = "modules/landing/showLanding/templates/circles";

    Circles.prototype.newAlbums = require('modules/landing/showLanding/newAlbumsGraph');

    Circles.prototype.labelsGraph = require('modules/landing/showLanding/labelsGraph');

    Circles.prototype.reportingGraph = require('modules/landing/showLanding/reportingGraph');

    Circles.prototype.className = "text-center";

    Circles.prototype.id = "circles";

    Circles.prototype.labels = function() {
      this.$el.find("#labels").find("svg").remove();
      return this.labelsGraph(this.el, this.collection, this);
    };

    Circles.prototype.initialize = function() {
      var _this = this;
      return this.collection.on("filter", function() {
        return _this.labels();
      });
    };

    Circles.prototype.graph = function() {
      this.newAlbums(this.el, this.collection, this);
      this.labelsGraph(this.el, this.collection, this);
      return this.reportingGraph(this.el, this.collection, this);
    };

    Circles.prototype.onRender = function() {
      if (matchMedia(Foundation.media_queries['medium']).matches) {
        return this.graph();
      }
    };

    return Circles;

  })(Marionette.ItemView);
  Show.StationList = (function(_super) {
    __extends(StationList, _super);

    function StationList() {
      _ref6 = StationList.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    StationList.prototype.template = "modules/landing/showLanding/templates/stationList";

    StationList.prototype.className = " small-12 columns";

    StationList.prototype.events = {
      'click a': 'clickStation'
    };

    StationList.prototype.clickStation = function(e) {
      e.preventDefault();
      if ($(e.target).hasClass("button")) {
        return App.navigate("station/", {
          trigger: true
        });
      } else {
        return App.navigate("station/" + e.target.text, {
          trigger: true
        });
      }
    };

    return StationList;

  })(Marionette.ItemView);
  Show.ChartItem = (function(_super) {
    __extends(ChartItem, _super);

    function ChartItem() {
      _ref7 = ChartItem.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    ChartItem.prototype.template = "modules/landing/showLanding/templates/chartItem";

    ChartItem.prototype.tagName = 'tr';

    ChartItem.prototype.initialize = function() {
      return this.model = this.model.set({
        index: this.options.index
      });
    };

    ChartItem.prototype.events = {
      'click a': 'clickItem'
    };

    ChartItem.prototype.clickItem = function(e) {
      var artist;
      e.preventDefault();
      artist = encodeURIComponent(e.target.text);
      return App.navigate("artist/" + artist, {
        trigger: true
      });
    };

    return ChartItem;

  })(Marionette.ItemView);
  Show.Empty = (function(_super) {
    __extends(Empty, _super);

    function Empty() {
      _ref8 = Empty.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    Empty.prototype.template = "modules/landing/showLanding/templates/empty";

    Empty.prototype.tagName = 'tr';

    return Empty;

  })(Marionette.ItemView);
  return Show.Chart = (function(_super) {
    __extends(Chart, _super);

    function Chart() {
      this.clickHeader = __bind(this.clickHeader, this);
      _ref9 = Chart.__super__.constructor.apply(this, arguments);
      return _ref9;
    }

    Chart.prototype.template = "modules/landing/showLanding/templates/chart";

    Chart.prototype.itemView = Show.ChartItem;

    Chart.prototype.emptyView = Show.Empty;

    Chart.prototype.className = "small-12 columns";

    Chart.prototype.itemViewContainer = "#thecharts";

    Chart.prototype.itemViewOptions = function(model) {
      return {
        index: this.collection.indexOf(model) + 1
      };
    };

    Chart.prototype.initialize = function() {};

    Chart.prototype.events = {
      'click th': 'clickHeader'
    };

    Chart.prototype.sortUpIcon = "fi-arrow-down";

    Chart.prototype.sortDnIcon = "fi-arrow-up";

    Chart.prototype.onRender = function() {
      this.$("th").append($("<i>")).closest("th").find("i").addClass("fi-minus-circle size-18");
      this.$("[column='" + this.collection.sortAttr + "']").find("i").removeClass("fi-minus-circle").addClass(this.sortUpIcon);
      return this;
    };

    Chart.prototype.clickHeader = function(e) {
      var $el, cs, ns;
      $el = $(e.currentTarget);
      ns = $el.attr("column");
      cs = this.collection.sortAttr;
      if (ns === cs) {
        this.collection.sortDir *= -1;
      } else {
        this.collection.sortDir = 1;
      }
      $("th").find("i").attr("class", "fi-minus-circle size-18");
      if (this.collection.sortDir === 1) {
        $el.find("i").removeClass("fi-minus-circle").addClass(this.sortUpIcon);
      } else {
        $el.find("i").removeClass("fi-minus-circle").addClass(this.sortDnIcon);
      }
      this.collection.sortCharts(ns);
    };

    return Chart;

  })(Marionette.CompositeView);
});

});

require.register("modules/landing/showLanding/templates/chart.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div class=\"chart\">\n  <table width=\"100%\" class=\"\">\n    <thead>\n      <th column='rank'>Rank </th>\n      <th column=\"artist\">Artist </th>\n      <th column=\"album\">Album </th>\n      <th column=\"label\">Label </th>\n  <!--     <th column=\"appearances\">Appearances </th> -->\n    </thead>\n    <tbody id=\"thecharts\">\n    </tbody>\n  </table>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/landing/showLanding/templates/chartItem.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression, lambda=this.lambda;
  return "<td>"
    + escapeExpression(((helper = (helper = helpers.rank || (depth0 != null ? depth0.rank : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"rank","hash":{},"data":data}) : helper)))
    + "</td>\n<td><a href=\"#\">"
    + escapeExpression(lambda(((stack1 = (depth0 != null ? depth0._id : depth0)) != null ? stack1.artist : stack1), depth0))
    + "</a></td>\n<td>"
    + escapeExpression(lambda(((stack1 = (depth0 != null ? depth0._id : depth0)) != null ? stack1.album : stack1), depth0))
    + "</td>\n<td>"
    + escapeExpression(lambda(((stack1 = (depth0 != null ? depth0._id : depth0)) != null ? stack1.label : stack1), depth0))
    + "</td>\n<!-- <td>"
    + escapeExpression(lambda(((stack1 = (depth0 != null ? depth0.appearances : depth0)) != null ? stack1.length : stack1), depth0))
    + "</td> -->\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/landing/showLanding/templates/circles.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div class=\"medium-4 columns\" id=\"labels\">\n  <h1>Labels</h1>\n</div>\n<div class=\"medium-4 columns\" id=\"newAlbums\">\n  <h1>Debuts</h1>\n</div>\n<div class=\"medium-4 columns\" id=\"reporting\">\n  <h1>Reporting Stations</h1>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/landing/showLanding/templates/empty.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<td colspan='100%' class=\"text-center\"><strong>Sorry, Nothing Found.</strong></th>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/landing/showLanding/templates/graph.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div class=\"show-for-small-only\">\n  <p class=\"lead\">For now, ChartZapp's graphs are only available on larger screens.</p>\n  <p>If you'd like to see more on a mobile device,\n  <a href=\"#\" data-reveal-id=\"feedback\">let me know!</a></p>\n\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/landing/showLanding/templates/info.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"1":function(depth0,helpers,partials,data) {
  var helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression;
  return "  <div class=\"large-4 columns\">\n    <ul class=\"inline-list right\">\n      <li><a class=\"next\" data-week=\""
    + escapeExpression(((helper = (helper = helpers.week || (depth0 != null ? depth0.week : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"week","hash":{},"data":data}) : helper)))
    + "\" id=\"prev\"><i class=\"fi-arrow-left\"></i> Prev</a></li>\n      <li><a class=\"next\" data-week=\""
    + escapeExpression(((helper = (helper = helpers.week || (depth0 != null ? depth0.week : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"week","hash":{},"data":data}) : helper)))
    + "\" id=\"next\">Next <i class=\"fi-arrow-right\"></i></a></li>\n    </ul>\n  </div>\n";
},"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression, buffer = "\n<div class=\"row\">\n  <div class=\"large-8 columns\">\n    <h1 id=\"text\"><i id=\"custom-range\" class=\"fi-calendar fi-large\"></i> "
    + escapeExpression(((helper = (helper = helpers.desc || (depth0 != null ? depth0.desc : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"desc","hash":{},"data":data}) : helper)))
    + "</h1>\n  </div>\n";
  stack1 = helpers['if'].call(depth0, (depth0 != null ? depth0.week : depth0), {"name":"if","hash":{},"fn":this.program(1, data),"inverse":this.noop,"data":data});
  if (stack1 != null) { buffer += stack1; }
  return buffer + "  <!-- <div class=\"large-4 columns\">\n    <div class=\"row collapse\">\n      <div class=\"small-10 columns\">\n        <input id=\"custom-range\" type=\"text\" placeholder=\"This Week\"></input>\n      </div>\n      <div class=\"small-2 columns\">\n        <span class=\"postfix radius\"><i id=\"custom-range\" class=\"fi-calendar\"></i></span>\n      </div>\n    </div>\n  </div> -->\n<!-- </div> -->\n</div>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/landing/showLanding/templates/search.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"1":function(depth0,helpers,partials,data) {
  var lambda=this.lambda, escapeExpression=this.escapeExpression;
  return "          <option value=\""
    + escapeExpression(lambda((depth0 != null ? depth0.name : depth0), depth0))
    + "\">"
    + escapeExpression(lambda((depth0 != null ? depth0.name : depth0), depth0))
    + "</option>\n";
},"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, buffer = "<!-- <div class=\"row\"> -->\n<div class=\"panel radius\">\n  <h3>Search</h3>\n  <p>What are you waiting for? Search Away!</p>\n  <form id=\"searchForm\" data-abide>\n<!--     <div class=\"station-select\">\n      <select form=\"#searchForm\" width=\"100%\" data-placeholder=\"Choose a Station...\" class=\"chosen-select\" id=\"search_input\">\n        <option value=\"\"></option>\n";
  stack1 = helpers.each.call(depth0, (depth0 != null ? depth0.items : depth0), {"name":"each","hash":{},"fn":this.program(1, data),"inverse":this.noop,"data":data});
  if (stack1 != null) { buffer += stack1; }
  return buffer + "      </select>\n    </div> -->\n    <p>I'm looking for...</p>\n    <div class=\"row\">\n      <div class=\"small-6 columns\">\n        <input type=\"text\" id=\"search_input\"></input>\n      </div>\n      <div class=\"small-6 columns\">\n        <select form=\"#searchForm\" id=\"kind_input\">\n          <option value=\"artist\">an Artist</option>\n          <option value=\"station\">a Station</option>\n        </select>\n      </div>\n    </div>\n      <button type=\"submit\">Search</button>\n  </form>\n</div>\n<!-- </div> -->\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/landing/showLanding/templates/show_layout.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div class='title-row' data-equalizer>\n  <div class=\"row\" >\n    <div id=\"title_region\" class=\"small-9 large-10 columns\" data-equalizer-watch>\n    <!-- <div class=\"panel\"> -->\n      <h1 class=\"main-title\">ChartZapp!</h1>\n    </div>\n    <div class=\"small-3 medium-1 large-1 end columns\" id=\"logos\" data-equalizer-watch>\n      <div class=\"row\">\n        <!-- <div class=\"small-6 columns\"><img src=\"img/earshot-logo.png\"></div>\n        <div class=\"small-6 columns\"><img src=\"img/ncra-logo.png\"></div> -->\n\n        <a href=\"http://www.ncra.ca\" target=\"blank\"><img src=\"img/ncra-logo.png\"></a>\n        <a href=\"http://www.earshot-online.com\" target=\"blank\"><img src=\"img/earshot-logo.png\"></a>\n      </div>\n    </div>\n  </div>\n</div>\n<div class='panel-row'>\n  <div class=\"row\">\n  <div id=\"blurb_region\" class=\"small-12 columns\">\n    <p class=\"lead\">This is ChartZapp, a new way of analyzing Canadian\n      Campus-Community Radio Charts.</p>\n    <p>It's currently in Beta, and for now\n      the database only extends to the beginning of 2014.</p>\n      <p>If you have questions, suggestions, or find a bug, please\n      <a href=\"#\" data-reveal-id=\"feedback\">let me know!</a>\n      </p>\n    </p>\n  </div>\n</div>\n</div>\n<div class=\"panel-row\">\n  <div id=\"info-region\" class=\"small-12 columns\">\n    <!-- <div class=\"panel\"> -->\n\n  </div>\n</div>\n<div class=\"graph-row\">\n  <div id=\"graph-region\" class=\"small-12 columns\"></div>\n</div>\n<div class=\"panel-row\">\n  <div id=\"circles-region\" class=\"small-12 columns\"></div>\n</div>\n\n<div class=\"graph-row\">\n  <div id=\"table_region\" class=\"row\"></div>\n</div>\n<div class=\"panel-row\">\n  <div id=\"list_region\" class=\"row\"></div>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/landing/showLanding/templates/stationList.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"1":function(depth0,helpers,partials,data) {
  var lambda=this.lambda, escapeExpression=this.escapeExpression;
  return "  <li><a href=\"#\">"
    + escapeExpression(lambda((depth0 != null ? depth0.name : depth0), depth0))
    + "</a></li>\n";
},"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, buffer = "<ul class=\"inline-list text-justify\">\n";
  stack1 = helpers.each.call(depth0, (depth0 != null ? depth0.items : depth0), {"name":"each","hash":{},"fn":this.program(1, data),"inverse":this.noop,"data":data});
  if (stack1 != null) { buffer += stack1; }
  return buffer + "</ul>\n<div class=\"text-center\">\n  <a href=\"#\" class=\"button\">See All Stations</a>\n</div>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/showStation_controller.coffee", function(exports, require, module) {
var App, Controllers, StationApp, colorList,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require("application");

StationApp = require("modules/station/station_app");

Controllers = require("controllers/baseController");

colorList = require('colorList');

module.exports = App.module('StationApp.Show', function(Show, App, Backbone, Marionette, $, _) {
  var _ref, _ref1, _ref10, _ref11, _ref12, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
  Show.Controller = (function(_super) {
    __extends(Controller, _super);

    function Controller() {
      this.showRecent = __bind(this.showRecent, this);
      this.mainView = __bind(this.mainView, this);
      _ref = Controller.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Controller.prototype.initialize = function(opts) {
      var station,
        _this = this;
      this.opts = opts;
      this.opts.loadingType = "spinner";
      this.layout = this.getLayoutView();
      this.initStation = App.request('topx:entities', opts);
      station = App.request('topx:entities', opts);
      this.stations = App.request('stations:entities');
      App.execute("when:fetched", this.stations, function() {
        return _this.stations.initializeFilters();
      });
      this.listenTo(this.layout, 'show', function() {
        return _this.mainView(station);
      });
      return this.show(this.layout, {
        loading: true
      });
    };

    Controller.prototype.mainView = function(search) {
      if (search == null) {
        search = null;
      }
      if (search.station) {
        return this.showStation(search);
      } else {
        return this.showStart(this.stations);
      }
    };

    Controller.prototype.showRecent = function(search) {
      var d, station, stationName;
      stationName = search;
      search = {};
      search.station = stationName;
      d = new Date;
      search.startDate = d.yyyymmdd();
      search.endDate = search.startDate;
      station = App.request('topx:entities', search);
      return this.showStation(station);
    };

    Controller.prototype.showStation = function(station) {
      var stationView,
        _this = this;
      stationView = this.getStationView(station);
      this.showPanel();
      this.showGraph(station);
      this.showTitle(station);
      App.execute("when:fetched", station, function() {
        if (station.length === 0) {
          return _this.showTitle(_this.initStation);
        }
      });
      this.show(stationView, {
        region: this.layout.tableRegion,
        loading: {
          loadingType: this.opts.loadingType
        }
      });
      return this.listenTo(stationView, 'click:week', function(req) {
        var currentWeek, newWeek, now, reqWeek, search;
        _this.opts.loadingType = "opacity";
        currentWeek = moment(req.week);
        now = moment();
        switch (req.dir) {
          case "next":
            reqWeek = currentWeek.day(9);
            if (reqWeek > now) {
              reqWeek = now;
            }
            break;
          case "prev":
            reqWeek = currentWeek.day(-5);
            break;
          default:
            reqWeek = currentWeek;
        }
        search = {
          station: _this.opts.station,
          startDate: reqWeek.format("YYYY-MM-DD"),
          endDate: reqWeek.format('YYYY-MM-DD')
        };
        newWeek = App.request('topx:entities', search);
        return _this.showStation(newWeek);
      });
    };

    Controller.prototype.showTitle = function(station) {
      var titleView;
      titleView = this.getTitleView(station);
      return this.show(titleView, {
        region: this.layout.titleRegion,
        loading: {
          loadingType: this.opts.loadingType
        }
      });
    };

    Controller.prototype.showGraph = function(station) {
      var graphView;
      graphView = this.getGraphView(station);
      this.listenTo(graphView, 'click:album:circle', function(d) {
        return App.navigate("/artist/" + (encodeURIComponent(d)), {
          trigger: true
        });
      });
      return this.show(graphView, {
        region: this.layout.graphRegion,
        loading: {
          loadingType: this.opts.loadingType
        }
      });
    };

    Controller.prototype.showPanel = function() {
      var panelView,
        _this = this;
      panelView = this.getPanelView();
      this.show(panelView, {
        region: this.layout.panelRegion
      });
      this.listenTo(panelView, 'click:mostRecent', function(station) {
        _this.opts.loadingType = "opacity";
        return _this.showRecent(_this.opts.station);
      });
      this.listenTo(panelView, 'click:thisYear', function(search) {
        var station;
        if (search == null) {
          search = {};
        }
        _this.opts.loadingType = "opacity";
        search.station = _this.opts.station;
        search.startDate = moment().subtract(1, 'years');
        search.endDate = moment;
        station = App.request('topx:entities', search);
        return _this.showStation(station);
      });
      return this.listenTo(panelView, 'click:other', function(search) {
        var station;
        _this.opts.loadingType = "opacity";
        search.station = _this.opts.station;
        station = App.request('topx:entities', search);
        return _this.showStation(station);
      });
    };

    Controller.prototype.showEmpty = function(stations) {
      var emptyView;
      emptyView = this.getEmptyView(stations);
      this.show(emptyView, {
        region: this.layout.tableRegion
      });
      $(".chosen-select").chosen();
      return this.listenTo(emptyView, 'pick:station', function(search) {
        return App.navigate("station/" + search.station, {
          trigger: true
        });
      });
    };

    Controller.prototype.showStart = function(stations) {
      var graphView, startPanel, startTitle, startView;
      startTitle = this.getStartTitle(stations);
      startPanel = this.getStartPanel(stations);
      graphView = this.getGraphView(stations);
      this.show(graphView, {
        region: this.layout.graphRegion,
        loading: true
      });
      this.show(startTitle, {
        region: this.layout.titleRegion,
        loading: true
      });
      this.show(startPanel, {
        region: this.layout.panelRegion,
        loading: true
      });
      startView = this.getStartView(stations);
      this.show(startView, {
        region: this.layout.tableRegion,
        loading: true
      });
      $(".chosen-select").chosen();
      this.listenTo(startView, 'pick:station', function(search) {
        return App.navigate("station/" + search.station, {
          trigger: true
        });
      });
      return this.listenTo(startView, 'itemview:pick:station', function(item, search) {
        return App.navigate("station/" + search, {
          trigger: true
        });
      });
    };

    Controller.prototype.getTitleView = function(station) {
      return new Show.Title({
        collection: station
      });
    };

    Controller.prototype.getEmptyView = function(stations) {
      return new Show.EmptyView({
        collection: stations
      });
    };

    Controller.prototype.getStartView = function(stations) {
      return new Show.StartView({
        collection: stations
      });
    };

    Controller.prototype.getStationView = function(station) {
      return new Show.Chart({
        collection: station,
        model: new App.Entities.Station(station)
      });
    };

    Controller.prototype.getPanelView = function() {
      return new Show.Panel;
    };

    Controller.prototype.getStartPanel = function(stations) {
      return new Show.StartPanel({
        collection: stations
      });
    };

    Controller.prototype.getStartTitle = function(stations) {
      return new Show.StartTitle({
        collection: stations
      });
    };

    Controller.prototype.getGraphView = function(station) {
      return new Show.Graph({
        collection: station
      });
    };

    Controller.prototype.getLayoutView = function() {
      return new Show.Layout;
    };

    return Controller;

  })(App.Controllers.Base);
  Show.Layout = (function(_super) {
    __extends(Layout, _super);

    function Layout() {
      _ref1 = Layout.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Layout.prototype.template = "modules/station/showStation/templates/show_layout";

    Layout.prototype.regions = {
      titleRegion: "#title-region",
      graphRegion: "#graph-region",
      panelRegion: "#panel-region",
      topRegion: "#topthree-region",
      tableRegion: "#table-region"
    };

    return Layout;

  })(Marionette.Layout);
  Show.Panel = (function(_super) {
    __extends(Panel, _super);

    function Panel() {
      _ref2 = Panel.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Panel.prototype.template = "modules/station/showStation/templates/panel";

    Panel.prototype.ui = {
      'mostRecent': '#mostRecent',
      'thisYear': '#thisYear',
      'startDate': '#startDate',
      'endDate': '#endDate',
      'range': '#dateRange'
    };

    Panel.prototype.events = {
      'click @ui.mostRecent': 'mostRecent',
      'click @ui.thisYear': 'thisYear'
    };

    Panel.prototype.onRender = function() {
      var _this = this;
      return this.ui.range.dateRangePicker({
        startDate: "2014-01-01",
        endDate: moment(),
        shortcuts: {
          'prev': ['week', 'month', 'year'],
          'prev-days': [7, 14],
          'next-days': false,
          'next': false
        }
      }).bind('datepicker-change', function(event, obj) {
        var search;
        search = {};
        search.startDate = obj.date1;
        search.endDate = obj.date2;
        return _this.trigger('click:other', search);
      });
    };

    Panel.prototype.mostRecent = function(e) {
      e.preventDefault();
      return this.trigger('click:mostRecent');
    };

    Panel.prototype.thisYear = function(e) {
      e.preventDefault();
      return this.trigger('click:thisYear');
    };

    return Panel;

  })(Marionette.ItemView);
  Show.Title = (function(_super) {
    __extends(Title, _super);

    function Title() {
      _ref3 = Title.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    Title.prototype.template = "modules/station/showStation/templates/title";

    return Title;

  })(Marionette.ItemView);
  Show.Graph = (function(_super) {
    __extends(Graph, _super);

    function Graph() {
      _ref4 = Graph.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    Graph.prototype.template = "modules/station/showStation/templates/graph";

    Graph.prototype.buildGraph = require("modules/station/showStation/stationGraph");

    Graph.prototype.buildMap = require('modules/station/showStation/stationMap');

    Graph.prototype.graph = function() {
      d3.select("svg").remove();
      return this.buildGraph(this.el, this.collection, this);
    };

    Graph.prototype.mapGraph = function() {
      return this.buildMap(this.el, this.collection, this);
    };

    Graph.prototype.id = "graph";

    Graph.prototype.initialize = function() {
      var _this = this;
      return this.collection.on('filter', function() {
        return _this.render();
      });
    };

    Graph.prototype.onRender = function() {
      if (matchMedia(Foundation.media_queries['medium']).matches) {
        if (this.collection.station) {
          return this.graph();
        } else {
          return this.mapGraph();
        }
      }
    };

    return Graph;

  })(Marionette.ItemView);
  Show.Empty = (function(_super) {
    __extends(Empty, _super);

    function Empty() {
      _ref5 = Empty.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    Empty.prototype.template = "modules/station/showStation/templates/empty";

    Empty.prototype.tagName = 'tr';

    return Empty;

  })(Marionette.ItemView);
  Show.EmptyView = (function(_super) {
    __extends(EmptyView, _super);

    function EmptyView() {
      _ref6 = EmptyView.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    EmptyView.prototype.template = "modules/station/showStation/templates/emptyview";

    EmptyView.prototype.className = "small-12 columns";

    EmptyView.prototype.ui = {
      'stationPicker': '#station-select'
    };

    EmptyView.prototype.events = {
      'submit': 'submit'
    };

    EmptyView.prototype.submit = function(e) {
      var search;
      e.preventDefault();
      search = {};
      search.station = $.trim(this.ui.stationPicker.val());
      return this.trigger('pick:station', search);
    };

    return EmptyView;

  })(Marionette.ItemView);
  Show.StartTitle = (function(_super) {
    __extends(StartTitle, _super);

    function StartTitle() {
      _ref7 = StartTitle.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    StartTitle.prototype.template = "modules/station/showStation/templates/startTitle";

    StartTitle.prototype.onRender = function() {
      var _this = this;
      return this.collection.on("filter", function() {
        return _this.render();
      });
    };

    return StartTitle;

  })(Marionette.ItemView);
  Show.StartPanel = (function(_super) {
    __extends(StartPanel, _super);

    function StartPanel() {
      _ref8 = StartPanel.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    StartPanel.prototype.template = "modules/station/showStation/templates/startPanel";

    StartPanel.prototype.onRender = function() {
      var list,
        _this = this;
      this.collection.on('filter', function() {
        return _this.updateFilters(_.last(_this.collection.filters));
      });
      list = this.collection.getFilterLists();
      _.each(list, function(filters, facet) {
        return _.each(filters, function(filter) {
          return _this.$el.find("#" + facet).append("<option value=\"" + filter + "\">" + filter + "</option>");
        });
      });
      return this.$el.find(".chosen-select").chosen().trigger('chosen:updated');
    };

    StartPanel.prototype.events = {
      'change .chosen-select': 'submit',
      'click #clearFilters': 'clearFilters'
    };

    StartPanel.prototype.submit = function(e, params) {
      var facet, filter, value;
      e.preventDefault();
      filter = {};
      facet = e.target.id;
      value = params.selected ? params.selected : params.deselected;
      filter[facet] = value;
      if (params.selected) {
        return this.addFilter(filter);
      } else {
        return this.removeFilter(filter);
      }
    };

    StartPanel.prototype.addFilter = function(filter) {
      return this.collection.addFilter(filter);
    };

    StartPanel.prototype.removeFilter = function(filter) {
      return this.collection.removeFilter(filter);
    };

    StartPanel.prototype.updateFilters = function(filter) {
      var filterFacet, newList,
        _this = this;
      if (filter) {
        filterFacet = Object.keys(filter);
        this.$el.find("option").attr("disabled", true);
        this.$el.find("option[value='" + filter[filterFacet] + "']").attr("selected", true);
        newList = this.collection.getUpdatedFilterLists(filterFacet);
        _.each(newList, function(filters, facet) {
          return _.each(filters, function(value) {
            return _this.$el.find("option[value='" + value + "']").attr("disabled", false);
          });
        });
        return this.$el.find(".chosen-select").chosen().trigger('chosen:updated');
      }
    };

    StartPanel.prototype.clearFilters = function(e) {
      e.preventDefault();
      this.collection.resetFilters();
      this.$el.find("option").attr("disabled", false);
      this.$el.find('option').attr("selected", false);
      return this.$el.find(".chosen-select").val('[]').trigger('chosen:updated');
    };

    return StartPanel;

  })(Marionette.ItemView);
  Show.SingleStation = (function(_super) {
    __extends(SingleStation, _super);

    function SingleStation() {
      _ref9 = SingleStation.__super__.constructor.apply(this, arguments);
      return _ref9;
    }

    SingleStation.prototype.template = "modules/station/showStation/templates/singleStation";

    SingleStation.prototype.events = {
      "click": "nav",
      "mouseover": "hover",
      "mouseout": "mouseout"
    };

    SingleStation.prototype.mouseout = function() {
      return $(".panel").css("opacity", 1);
    };

    SingleStation.prototype.hover = function(e) {
      $(".panel").css("opacity", 0.5);
      e.preventDefault();
      return $(e.target).closest(".panel").css("opacity", 1);
    };

    SingleStation.prototype.nav = function(e) {
      e.preventDefault();
      return this.trigger('pick:station', this.model.get('name'));
    };

    SingleStation.prototype.onRender = function() {
      var color;
      color = colorList(this.model.get('name'));
      return this.$el.find('.panel').css('background', color);
    };

    return SingleStation;

  })(Marionette.ItemView);
  Show.StartView = (function(_super) {
    __extends(StartView, _super);

    function StartView() {
      _ref10 = StartView.__super__.constructor.apply(this, arguments);
      return _ref10;
    }

    StartView.prototype.itemView = Show.SingleStation;

    StartView.prototype.template = "modules/station/showStation/templates/start";

    StartView.prototype.itemViewContainer = "#stations";

    StartView.prototype.ui = {
      'stationPicker': '#station-select'
    };

    StartView.prototype.events = {
      'submit': 'submit'
    };

    StartView.prototype.submit = function(e) {
      var search;
      e.preventDefault();
      search = {};
      search.station = $.trim(this.ui.stationPicker.val());
      return this.trigger('pick:station', search);
    };

    return StartView;

  })(Marionette.CompositeView);
  Show.ChartItem = (function(_super) {
    __extends(ChartItem, _super);

    function ChartItem() {
      _ref11 = ChartItem.__super__.constructor.apply(this, arguments);
      return _ref11;
    }

    ChartItem.prototype.template = "modules/station/showStation/templates/chartItem";

    ChartItem.prototype.tagName = 'tr';

    ChartItem.prototype.events = {
      'click a': 'clickArtist'
    };

    ChartItem.prototype.clickArtist = function(e) {
      var artist;
      artist = encodeURIComponent(e.target.text);
      return App.navigate("artist/" + artist, {
        trigger: true
      });
    };

    return ChartItem;

  })(Marionette.ItemView);
  return Show.Chart = (function(_super) {
    __extends(Chart, _super);

    function Chart() {
      this.clickHeader = __bind(this.clickHeader, this);
      _ref12 = Chart.__super__.constructor.apply(this, arguments);
      return _ref12;
    }

    Chart.prototype.template = "modules/station/showStation/templates/chart";

    Chart.prototype.className = "small-12 columns";

    Chart.prototype.itemView = Show.ChartItem;

    Chart.prototype.emptyView = Show.Empty;

    Chart.prototype.itemViewContainer = "#thechart";

    Chart.prototype.events = {
      'click th': 'clickHeader',
      'click .next': 'clickNext'
    };

    Chart.prototype.clickNext = function(e) {
      var request;
      e.preventDefault();
      request = {
        week: $(e.target).data("week"),
        dir: e.target.id
      };
      return this.trigger('click:week', request);
    };

    Chart.prototype.sortUpIcon = "fi-arrow-down";

    Chart.prototype.sortDnIcon = "fi-arrow-up";

    Chart.prototype.onRender = function() {
      this.$("th").append($("<i>")).closest("th").find("i").addClass("fi-minus-circle size-18");
      this.$("[column='" + this.collection.sortAttr + "']").find("i").removeClass("fi-minus-circle").addClass(this.sortUpIcon);
      return this;
    };

    Chart.prototype.clickHeader = function(e) {
      var $el, cs, ns;
      $el = $(e.currentTarget);
      ns = $el.attr("column");
      cs = this.collection.sortAttr;
      if (ns === cs) {
        this.collection.sortDir *= -1;
      } else {
        this.collection.sortDir = 1;
      }
      $("th").find("i").attr("class", "fi-minus-circle size-18");
      if (this.collection.sortDir === 1) {
        $el.find("i").removeClass("fi-minus-circle").addClass(this.sortUpIcon);
      } else {
        $el.find("i").removeClass("fi-minus-circle").addClass(this.sortDnIcon);
      }
      this.collection.sortCharts(ns);
    };

    return Chart;

  })(Marionette.CompositeView);
});

});

require.register("modules/station/showStation/stationGraph.coffee", function(exports, require, module) {
var App;

App = require("application");

module.exports = function(el, collection, view) {
  var album, albums, barWidth, click, color, height, hideInfo, margin, mouseout, mouseover, rScale, showData, showEmpty, showInfo, svg, width, x, xAxis, y, yAxis;
  margin = {
    top: 100,
    right: 100,
    bottom: 50,
    left: 100
  };
  width = $("#graph-region").width() - margin.left - margin.right;
  height = 500 - margin.top - margin.bottom;
  y = d3.scale.linear().range([0, height]);
  x = d3.scale.linear().range([0, width]);
  color = d3.scale.category10();
  xAxis = d3.svg.axis().scale(x).orient("bottom");
  yAxis = d3.svg.axis().scale(y).orient("left");
  svg = d3.select(el).append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
  albums = collection.models;
  albums = albums.slice(0, 10);
  barWidth = width / albums.length;
  rScale = d3.scale.linear();
  rScale.domain(d3.extent(albums, function(c) {
    return c.attributes.frontPoints;
  }));
  rScale.range([5, 130]);
  y.domain([
    d3.max(albums, function(c) {
      return c.attributes.frontPoints;
    }), d3.min(albums, function(c) {
      return c.attributes.frontPoints;
    }) - 10
  ]);
  x.domain([0, 11]);
  if (albums.length !== 0) {
    svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 4).attr("dy", "-4em").style("text-anchor", "end").text("Chartscore");
  }
  color.domain(albums);
  mouseover = function(d, i) {
    d3.selectAll("g rect").transition().duration(100).style("opacity", 0.2);
    d3.select("g ." + d.attributes.slug + " > rect").transition().duration(100).style("opacity", 1);
    return showData(this, d);
  };
  mouseout = function() {
    d3.selectAll("g rect").transition().duration(100).style("opacity", 1);
    return $(".tip").fadeOut(50).remove();
  };
  click = function(d) {
    var artist;
    artist = d.attributes.artist;
    return view.trigger("click:album:circle", artist);
  };
  showData = function(i, d) {
    var chartTip;
    $("#graph").append("<div class='tip'></div>");
    chartTip = d3.select(".tip");
    chartTip.style("left", width - 150 + "px").style("top", 50 + "px").style("background", color(d.cid));
    $(".tip").html("" + d.attributes.artist + " <br />\n" + d.attributes.album + "<br />\nTotal Appearances: " + d.attributes.appearances.length + "<br />\nChartscore: " + d.attributes.frontPoints);
    return $(".tip").fadeIn(100);
  };
  showEmpty = function() {
    return $(el).append("<div class='tip text-center'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 2 + "px").html("<br />\nSorry, No Data is available for the selected Time Range.\n<br />\n<br />").fadeIn(100);
  };
  showInfo = function() {
    if ($(el).find(".tip").length !== 0) {
      return $(".info").remove();
    } else {
      return $(el).append("<div class='tip text-center info'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 3 + "px").html("<br />\nThis graph displays the top 10 albums on " + collection.station + " over the selected time range.<br />\nThe X-Axis is determined by the album's rank.<br />\nThe Y-Axis is determined by the album's Chartscore.<br />\nMouseover any bar for more information.<br />\n<br />\n(Click anywhere to hide)\n<br />\n<br />").on("click", hideInfo).fadeIn(100);
    }
  };
  hideInfo = function() {
    $(el).find(".info").fadeOut(100);
    return $(".info").remove();
  };
  $(el).prepend("<div class='button tiny radius infobox'></div>").find(".infobox").html("<i class='fi-info large'></i>").on("click", showInfo);
  $(el).find("svg").on("click", hideInfo);
  album = svg.selectAll(".album").data(albums).enter().append("g").attr("transform", function(d, i) {
    return "translate(" + i * barWidth + ",0 )";
  }).attr("class", function(d) {
    return "album " + d.attributes.slug;
  });
  album.append("rect").attr("class", "bar").attr("width", barWidth - 1).attr("height", function(d) {
    return height - y(d.attributes.frontPoints);
  }).attr("y", function(d) {
    return 3 + y(d.attributes.frontPoints);
  }).style("fill", function(d, i) {
    return color(d.cid);
  });
  album.append("text").attr("y", height + 20).attr("x", function(d) {
    return (barWidth / 2) - 10;
  }).text(function(d, i) {
    return "#" + (i + 1);
  });
  album.on("mouseover", mouseover).on("mouseout", mouseout).on("click", click);
  if (albums.length === 0) {
    return showEmpty();
  }
};

});

require.register("modules/station/showStation/stationMap.coffee", function(exports, require, module) {
module.exports = function(el, collection, view) {
  var color, colorBox, height, margin, svg, width;
  margin = {
    top: 50,
    right: 50,
    bottom: 50,
    left: 50
  };
  color = require('../../../colorList');
  width = $("#graph-region").width() - margin.left - margin.right;
  height = 600 - margin.top - margin.bottom;
  svg = d3.select(el).append("svg").attr("width", width).attr("height", height);
  colorBox = {
    BC: ['#8ad08c', '#80c47e', '#77b972', '#6fad66', '#67a25b', '#609651', '#598b48', '#52803e', '#4c7436', '#45692e'],
    AB: ['#ebe06e', '#e4da74', '#ddd479', '#d7ce7d', '#d0c881'],
    SK: ['#e7DEB2'],
    MB: ['#cc9f61', '#ca6400', '#9e8752', '#877949'],
    ON: ['#eba294', '#e99d8f', '#e7988a', '#e59386', '#e38e81', '#e1897d', '#df8478', '#dd8074', '#db7b70', '#d9766c', '#d77167', '#d66c63', '#d4675f', '#d2625b', '#d05d57', '#ce5853', '#cc5450', '#ca4f4c', '#c84a48', '#c64544'],
    QC: ['#d768db', '#c566d1', '#b564c6', '#a562bc', '#975fb1', '#8a5ca7', '#7d589c', '#725592', '#675187', '#5c4c7d'],
    NS: ['#20a3fe', '#40c8fe', '#60e4fd', '#7ff8fd', '#9ffcf5'],
    NB: ['#0165e4', '#025bc9', '#0351ae', '#044593', '#043a78'],
    NF: ['#22fc32', '#4efa44', '#7ff765', '#a7f585', '#c6f2a5']
  };
  colorBox.BC.reverse();
  colorBox.ON.reverse();
  return d3.json("canada.json", function(error, canada) {
    var b, cities, clickCity, clickProv, data, foundCities, hideData, hideInfo, ids, mouseout, mouseoutCity, mouseover, mouseoverCity, newData, path, projection, provinces, s, sByC, sByP, sCbP, showData, showInfo, subunits, t;
    if (error) {
      return console.error(error);
    }
    subunits = topojson.feature(canada, canada.objects.prov);
    sByC = {};
    sByP = {};
    cities = [];
    provinces = [];
    collection.sort();
    collection.each(function(model) {
      cities.push(model.get('city'));
      provinces.push(model.get('province'));
      if (sByP[model.get('province')]) {
        sByP[model.get('province')].push(model.get('name'));
      } else {
        sByP[model.get('province')] = [model.get('name')];
      }
      if (sByC[model.get('city')]) {
        return sByC[model.get('city')].push(model.get('name'));
      } else {
        return sByC[model.get('city')] = [model.get('name')];
      }
    });
    provinces = _.uniq(provinces);
    cities = _.uniq(cities);
    sCbP = {};
    ids = [];
    _.each(provinces, function(prov) {
      if (prov === "NF") {
        prov = "NL";
      }
      return ids.push("CA-" + prov);
    });
    subunits.features = _.filter(subunits.features, function(feature) {
      if (_.indexOf(ids, feature.id) !== -1) {
        return feature;
      }
    });
    projection = d3.geo.conicConformal().scale(1).rotate([105, 0]).translate([0, 0]);
    path = d3.geo.path().projection(projection);
    b = path.bounds(subunits);
    s = .95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height);
    t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2];
    projection.scale(s).translate(t);
    mouseover = function(d) {
      d3.select("#" + d.id).transition().duration(100).style("opacity", 0.5);
    };
    mouseout = function(d) {
      d3.selectAll("path").transition().duration(100).style("opacity", 1);
    };
    mouseoverCity = function(d) {
      var size;
      size = d3.select(this).attr("r");
      d3.select(this).transition().duration(100).attr("r", function(d) {
        return size * 2;
      });
      return showData(this, d);
    };
    mouseoutCity = function(d) {
      d3.selectAll("circle").transition().duration(100).attr("r", function(d) {
        var val;
        val = sByC[d.properties.name].length;
        return 6 * val;
      });
      return hideData();
    };
    showData = function(i, d) {
      var chartTip, stationString;
      $("#graph").append("<div class='tip'></div>");
      stationString = '';
      _.each(sByC[d.properties.name], function(station) {
        return stationString += " " + station;
      });
      stationString.trim();
      chartTip = d3.select(".tip");
      chartTip.style("left", width - 150 + "px").style("top", 50 + "px").style("background", color(d.properties.name));
      $(".tip").html("City: " + d.properties.name + " <br />\nStations: " + stationString + "<br />");
      return $(".tip").fadeIn(100);
    };
    hideData = function() {
      return $(".tip").fadeOut().remove();
    };
    clickProv = function() {
      var filter;
      filter = {
        province: $(this).attr('id').split('-')[1]
      };
      if (filter.province === 'NL') {
        filter.province = "NF";
      }
      return collection.addFilter(filter);
    };
    clickCity = function() {
      var filter;
      filter = {
        city: _.reduceRight($(this).attr("class").split(" ").slice(1), function(word, memo) {
          return memo += " " + word;
        })
      };
      return collection.addFilter(filter);
    };
    data = topojson.feature(canada, canada.objects.cplaces).features;
    newData = _.filter(data, function(city) {
      if (city.properties.name === "Windsor" && city.properties.province !== "Ontario") {
        return false;
      }
      if (_.indexOf(cities, city.properties.name) !== -1) {
        return city;
      }
    });
    foundCities = _.map(newData, function(item) {
      return item.properties.name;
    });
    svg.selectAll(".subunit").data(subunits.features).enter().append("path").attr("class", function(d) {
      return "subunit " + d.id;
    }).attr("id", function(d) {
      return d.id;
    }).attr("d", path).on("mouseover", mouseover).on("mouseout", mouseout).on("click", clickProv);
    svg.selectAll('.city').data(newData).enter().append("circle").attr("class", function(d) {
      return "city " + d.properties.name;
    }).attr("r", function(d) {
      var val;
      val = sByC[d.properties.name].length;
      return 6 * val;
    }).style("fill", function(d) {
      return color("" + d.properties.name);
    }).attr("transform", function(d) {
      return "translate(" + projection(d.geometry.coordinates) + ")";
    }).on("mouseover", mouseoverCity).on("mouseout", mouseoutCity).on("click", clickCity);
    showInfo = function() {
      if ($(el).find(".tip").length !== 0) {
        return $(".info").remove();
      } else {
        return $(el).append("<div class='tip text-center info'></div>").find(".tip").css("width", width + margin.left + margin.right + "px").css("margin", "auto").css("top", height / 3 + "px").html("<br />\nThis map displays all the cities in Canada with Campus Community stations that report to Earshot.<br />\nThe size of each dot is relative to the number of stations in that city. <br />\nUsing the filters will redraw the map to the selected location(s).<br />\nThere are no Earshot reporting stations in the three territories, or on PEI, so they are not displayed. <br />\nMouseover any city for more information.<br />\n<br />\n(Click anywhere to hide)\n<br />\n<br />").on("click", hideInfo).fadeIn(100);
      }
    };
    hideInfo = function() {
      $(el).find(".info").fadeOut(100);
      return $(".info").remove();
    };
    $(el).prepend("<div class='button tiny radius infobox'></div>").find(".infobox").html("<i class='fi-info large'></i>").on("click", showInfo);
    return $(el).find("svg").on("click", hideInfo);
  });
};

});

require.register("modules/station/showStation/templates/chart.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"1":function(depth0,helpers,partials,data) {
  var stack1, helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression, buffer = "<div class=\"panel\"><span>"
    + escapeExpression(((helper = (helper = helpers.desc || (depth0 != null ? depth0.desc : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"desc","hash":{},"data":data}) : helper)))
    + "</span>\n";
  stack1 = helpers['if'].call(depth0, (depth0 != null ? depth0.week : depth0), {"name":"if","hash":{},"fn":this.program(2, data),"inverse":this.noop,"data":data});
  if (stack1 != null) { buffer += stack1; }
  return buffer + "</div>\n<div class=\"chart\">\n  <table width=\"100%\">\n    <thead>\n      <th column='rank'>Rank </th>\n      <th column=\"artist\">Artist </th>\n      <th column=\"album\">Album </th>\n      <th column=\"label\">Label </th>\n      <th column=\"appearances\">Appearances </th>\n    </thead>\n    <tbody id=\"thechart\">\n    </tbody>\n  </table>\n</div>\n";
},"2":function(depth0,helpers,partials,data) {
  var helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression;
  return "  <ul class=\"inline-list right\">\n    <li><a class=\"next\" data-week=\""
    + escapeExpression(((helper = (helper = helpers.week || (depth0 != null ? depth0.week : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"week","hash":{},"data":data}) : helper)))
    + "\" id=\"prev\"><i class=\"fi-arrow-left\"></i> Prev</a></li>\n    <li><a class=\"next\" data-week=\""
    + escapeExpression(((helper = (helper = helpers.week || (depth0 != null ? depth0.week : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"week","hash":{},"data":data}) : helper)))
    + "\" id=\"next\">Next <i class=\"fi-arrow-right\"></i></a></li>\n  </ul>\n";
},"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, buffer = "";
  stack1 = helpers.unless.call(depth0, ((stack1 = ((stack1 = ((stack1 = (depth0 != null ? depth0.models : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.attributes : stack1)) != null ? stack1.isNull : stack1), {"name":"unless","hash":{},"fn":this.program(1, data),"inverse":this.noop,"data":data});
  if (stack1 != null) { buffer += stack1; }
  return buffer;
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/chartItem.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression, lambda=this.lambda;
  return "<td>"
    + escapeExpression(((helper = (helper = helpers.rank || (depth0 != null ? depth0.rank : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"rank","hash":{},"data":data}) : helper)))
    + "</td>\n<td><a>"
    + escapeExpression(((helper = (helper = helpers.artist || (depth0 != null ? depth0.artist : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"artist","hash":{},"data":data}) : helper)))
    + "</a></td>\n<td>"
    + escapeExpression(((helper = (helper = helpers.album || (depth0 != null ? depth0.album : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"album","hash":{},"data":data}) : helper)))
    + "</td>\n<td>"
    + escapeExpression(((helper = (helper = helpers.label || (depth0 != null ? depth0.label : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"label","hash":{},"data":data}) : helper)))
    + "</td>\n<td>"
    + escapeExpression(lambda(((stack1 = (depth0 != null ? depth0.appearances : depth0)) != null ? stack1.length : stack1), depth0))
    + "</td>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/empty.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<td colspan='100%' class=\"text-center\"><strong>Sorry, Nothing Found.</strong></td>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/emptyview.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"1":function(depth0,helpers,partials,data) {
  var lambda=this.lambda, escapeExpression=this.escapeExpression;
  return "        <option value=\""
    + escapeExpression(lambda((depth0 != null ? depth0.name : depth0), depth0))
    + "\">"
    + escapeExpression(lambda((depth0 != null ? depth0.name : depth0), depth0))
    + "</option>\n";
},"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, buffer = "<div class=\"panel\">\n  <h3>Sorry, nothing found for that search.</h3>\n  <h4>Pick a station:</h4>\n  <form id=\"stationForm\">\n  <div class=\"station-select\">\n    <select width=\"100%\" form-id=\"#stationForm\" data-placeholder=\"Choose a Station...\" class=\"chosen-select\" id=\"station-select\">\n      <option value=\"\"></option>\n";
  stack1 = helpers.each.call(depth0, (depth0 != null ? depth0.items : depth0), {"name":"each","hash":{},"fn":this.program(1, data),"inverse":this.noop,"data":data});
  if (stack1 != null) { buffer += stack1; }
  return buffer + "    </select>\n  </div>\n  <button id=\"pickStation\" type=\"submit\" class=\"small\">Go!</button>\n</form>\n</div>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/graph.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div class=\"show-for-small-only\">\n  <p class=\"lead\">For now, ChartZapp's graphs are only available on larger screens.</p>\n  <p>If you'd like to see more on a mobile device,\n  <a href=\"#\" data-reveal-id=\"feedback\">let me know!</a></p>\n\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/panel.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<ul class=\"medium-block-grid-3 text-center\">\n  <li><button class=\"tiny\" id=\"mostRecent\">Most Recent</button></li>\n  <li><button class=\"tiny\" id='thisYear'>This Year</button></li>\n  <li>\n    <span class=\"tiny button dropdown\" id=\"dateRange\">Other</span>\n  </li>\n</ul>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/show_layout.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div id=\"station_layout\">\n  <div class=\"title-row\">\n    <div class=\"row\">\n      <div id=\"title-region\" class=\"small-12 columns\"></div>\n    </div>\n  </div>\n  <div class=\"graph-row\">\n    <div id=\"graph-region\" class=\"small-12 columns\"></div>\n  </div>\n  <div class=\"panel-row\">\n    <div class=\"row\">\n      <div id=\"panel-region\" class=\"small-12 columns\"></div>\n    </div>\n  </div>\n  <!-- <div class=\"graph-row\">\n    <div class=\"row\" id=\"topthree-region\">\n    </div>\n  </div> -->\n  <div class=\"graph-row\" >\n    <div class=\"row\" id=\"table-region\">\n    </div>\n  </div>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/singleStation.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression;
  return "<div class=\"panel small-6 large-4 columns\">\n  <h1 class=\"artist-title\">"
    + escapeExpression(((helper = (helper = helpers.name || (depth0 != null ? depth0.name : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"name","hash":{},"data":data}) : helper)))
    + "</h1>\n  <h3>"
    + escapeExpression(((helper = (helper = helpers.city || (depth0 != null ? depth0.city : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"city","hash":{},"data":data}) : helper)))
    + ", "
    + escapeExpression(((helper = (helper = helpers.province || (depth0 != null ? depth0.province : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"province","hash":{},"data":data}) : helper)))
    + "</h3>\n<!-- <p>"
    + escapeExpression(((helper = (helper = helpers.streetAddress || (depth0 != null ? depth0.streetAddress : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"streetAddress","hash":{},"data":data}) : helper)))
    + "</p>\n<p>"
    + escapeExpression(((helper = (helper = helpers.postalCode || (depth0 != null ? depth0.postalCode : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"postalCode","hash":{},"data":data}) : helper)))
    + "</p> -->\n</div>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/start.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "\n<ul class=\"small-block-grid-2 medium-block-grid-3\" id=\"stations\"></ul>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/startPanel.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div id=\"filters\" class=\" \">\n  <div class=\"row\">\n    <form>\n      <div class=\"medium-3 columns\">\n        <select class=\"chosen-select\" id=\"name\" data-placeholder=\"Station\" multiple>\n        </select>\n      </div>\n      <div class=\"medium-4 columns\">\n        <select class=\"chosen-select\" id=\"province\" data-placeholder=\"Province\" multiple>\n        </select>\n      </div>\n      <div class=\"medium-4 columns\">\n        <select class=\"chosen-select\" id=\"city\" data-placeholder=\"City\" multiple>\n        </select>\n      </div>\n      <div class=\"medium-1 column\">\n        <a class=\"button secondary tiny right\" id=\"clearFilters\" href=\"#\">Clear</a>\n      </div>\n  </form>\n  </div>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/startTitle.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, lambda=this.lambda, escapeExpression=this.escapeExpression;
  return "<div class=\"row\">\n  <div class=\"small-8 columns\">\n    <h1 class=\"artist-title\">Stations</h1>\n  </div>\n  <div class=\"small-4 columns\">\n    <h2 class=\"right\">Total: <span class=\"header-label radius\">"
    + escapeExpression(lambda(((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1.length : stack1), depth0))
    + "</span></h2>\n  </div>\n</div>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/title.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression, lambda=this.lambda;
  return "<div class=\"row\">\n  <div class=\"small-8 columns\">\n    <h1 class=\"artist-title\">"
    + escapeExpression(((helpers.toUpper || (depth0 && depth0.toUpper) || helperMissing).call(depth0, ((stack1 = ((stack1 = ((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.appearances : stack1)) != null ? stack1['0'] : stack1)) != null ? stack1.station : stack1), {"name":"toUpper","hash":{},"data":data})))
    + "</h1>\n    <!-- <h2>"
    + escapeExpression(lambda(((stack1 = ((stack1 = ((stack1 = ((stack1 = ((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.info : stack1)) != null ? stack1.models : stack1)) != null ? stack1['0'] : stack1)) != null ? stack1.attributes : stack1)) != null ? stack1.city : stack1), depth0))
    + ", "
    + escapeExpression(lambda(((stack1 = ((stack1 = ((stack1 = ((stack1 = ((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.info : stack1)) != null ? stack1.models : stack1)) != null ? stack1['0'] : stack1)) != null ? stack1.attributes : stack1)) != null ? stack1.province : stack1), depth0))
    + "</h2> -->\n  </div>\n  <div class=\"small-4 columns\">\n    <h2 class=\"right\">Charts: <span class=\"header-label radius\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.totalWeeks : stack1)) != null ? stack1.length : stack1), depth0))
    + "</span></h2>\n    <h4 class=\"right\">Submitting Average: <span class=\"header-label radius\">."
    + escapeExpression(lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.percentage : stack1), depth0))
    + "</span></h4>\n  </div>\n</div>\n<div class=\"row\">\n  <div class=\"small-6 columns\">\n    <ul class=\"no-bullet\">\n      <li>Location: <span class=\"label radius right\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = ((stack1 = ((stack1 = ((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.info : stack1)) != null ? stack1.models : stack1)) != null ? stack1['0'] : stack1)) != null ? stack1.attributes : stack1)) != null ? stack1.city : stack1), depth0))
    + ", "
    + escapeExpression(lambda(((stack1 = ((stack1 = ((stack1 = ((stack1 = ((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.info : stack1)) != null ? stack1.models : stack1)) != null ? stack1['0'] : stack1)) != null ? stack1.attributes : stack1)) != null ? stack1.province : stack1), depth0))
    + "</span></li>\n      <li>Most Charted Artist: <span class=\"label radius right\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.artist : stack1), depth0))
    + "</span></li>\n\n      <!-- <li>ChartScore: <span class=\"label radius right\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.totalChartScore : stack1), depth0))
    + "</span></li> -->\n    </ul>\n  </div>\n  <div class=\"small-6 columns\">\n    <ul class=\"no-bullet\">\n      <!-- <li>Charts Submitted: <span class=\"label radius right\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.totalWeeks : stack1)) != null ? stack1.length : stack1), depth0))
    + "</span></li> -->\n      <li>Albums Charted: <span class=\"label radius right\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.totalAlbums : stack1), depth0))
    + "</span></li>\n      <li>Most Charted Album: <a class=\"label radius right\" id=\"popStation\">"
    + escapeExpression(lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.items : depth0)) != null ? stack1['0'] : stack1)) != null ? stack1.album : stack1), depth0))
    + "</a></li>\n    </ul>\n  </div>\n</div>\n";
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/topItem.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"1":function(depth0,helpers,partials,data) {
  return "Sorry, No Chart for this Week";
  },"3":function(depth0,helpers,partials,data) {
  var helper, functionType="function", helperMissing=helpers.helperMissing, escapeExpression=this.escapeExpression;
  return "  <h2>#"
    + escapeExpression(((helper = (helper = helpers.rank || (depth0 != null ? depth0.rank : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"rank","hash":{},"data":data}) : helper)))
    + ":</h2>\n  <h3><a>"
    + escapeExpression(((helper = (helper = helpers.artist || (depth0 != null ? depth0.artist : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"artist","hash":{},"data":data}) : helper)))
    + "</a></h3>\n  <h4>"
    + escapeExpression(((helper = (helper = helpers.album || (depth0 != null ? depth0.album : depth0)) != null ? helper : helperMissing),(typeof helper === functionType ? helper.call(depth0, {"name":"album","hash":{},"data":data}) : helper)))
    + "</h4>\n  <br /><br /><br />\n";
},"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  var stack1, buffer = "";
  stack1 = helpers['if'].call(depth0, (depth0 != null ? depth0.isNull : depth0), {"name":"if","hash":{},"fn":this.program(1, data),"inverse":this.noop,"data":data});
  if (stack1 != null) { buffer += stack1; }
  buffer += "\n\n";
  stack1 = helpers.unless.call(depth0, (depth0 != null ? depth0.isNull : depth0), {"name":"unless","hash":{},"fn":this.program(3, data),"inverse":this.noop,"data":data});
  if (stack1 != null) { buffer += stack1; }
  return buffer;
},"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/showStation/templates/topthree.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div id=\"topthree\" data-equalizer></div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("modules/station/station_app.coffee", function(exports, require, module) {
var App,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = require('application');

module.exports = App.module('StationApp', function(StationApp, App, Backbone, Marionette, $, _) {
  var API, _ref;
  StationApp.Router = (function(_super) {
    __extends(Router, _super);

    function Router() {
      _ref = Router.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Router.prototype.appRoutes = {
      "station(/)(:station)": "showStation"
    };

    return Router;

  })(Marionette.AppRouter);
  StationApp.startWithParent = false;
  StationApp.Show = require('modules/station/showStation/showStation_controller');
  API = {
    showStation: function(station) {
      new StationApp.Show.Controller({
        region: App.mainRegion,
        station: station ? station : void 0
      });
      return $(document).foundation();
    }
  };
  return App.addInitializer(function() {
    return new StationApp.Router({
      controller: API
    });
  });
});

});

require.register("views/AppLayout.coffee", function(exports, require, module) {
var AppLayout, application, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

application = require('application');

module.exports = AppLayout = (function(_super) {
  __extends(AppLayout, _super);

  function AppLayout() {
    _ref = AppLayout.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  AppLayout.prototype.template = 'views/templates/appLayout';

  AppLayout.prototype.el = "body";

  return AppLayout;

})(Backbone.Marionette.Layout);

});

require.register("views/templates/appLayout.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div id=\"wrap\">\n  <div id=\"header-region\"></div>\n  <div id=\"main-region\" class=\"container row\"></div>\n  <div id=\"push\"></div>\n</div>\n<div id=\"footer-region\"></div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/templates/footer.hbs", function(exports, require, module) {
var __templateData = Handlebars.template({"compiler":[6,">= 2.0.0-beta.1"],"main":function(depth0,helpers,partials,data) {
  return "<div id=\"footer\">\n	<div class=\"container\">\n		<div class='row'>\n			<div class='small-12 columns text-center'>\n				<h1 class=\"footer-title\">ChartZapp!</h1>\n				<h4>Chart data collected and compiled by\n					<a href=\"http://www.earshot-online.com/\" target=\"blank\">\n						!Earshot Online\n					</a>\n					and published by\n					<a href=\"http://www.ncra.ca/\" target=\"blank\">the NCRA</a>\n				</h4>\n				<h4>Made by hand with\n					<i class=\"fi-heart large\"></i>\n					 in Montréal by\n					<a href=\"http://dorianlistens.com\" class=\"dl\" target=\"blank\">\n						Dorian Listens\n					</a>\n				</h4>\n			</div>\n		</div>\n	</div>\n</div>\n";
  },"useData":true});
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("___globals___", function(exports, require, module) {
  
});})();require('___globals___');


//# sourceMappingURL=app.js.map