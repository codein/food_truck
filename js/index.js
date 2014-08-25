
/*
 */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  jQuery(function() {
    var GoogleMaps, ResultModel, ResultView, Results, ResultsView, SearchController, _initialize;
    GoogleMaps = (function() {
      function GoogleMaps() {}

      GoogleMaps.dropMarker = function(latitude, longitude, animation, letter) {
        var marker, position;
        if (animation == null) {
          animation = 'DROP';
        }
        if (letter == null) {
          letter = 'Z';
        }
        switch (animation) {
          case 'BOUNCE':
            animation = google.maps.Animation.BOUNCE;
            break;
          case 'DROP':
            animation = google.maps.Animation.DROP;
            break;
          default:
            animation = google.maps.Animation.DROP;
        }
        position = new google.maps.LatLng(latitude, longitude);
        return marker = new google.maps.Marker({
          position: position,
          map: map,
          draggable: false,
          animation: animation,
          icon: "http://maps.google.com/mapfiles/marker" + letter + ".png"
        });
      };

      return GoogleMaps;

    })();
    ResultModel = (function(_super) {
      __extends(ResultModel, _super);

      function ResultModel() {
        return ResultModel.__super__.constructor.apply(this, arguments);
      }

      ResultModel.prototype.defaults = {
        part1: 'Hello',
        part2: 'Backbone'
      };

      return ResultModel;

    })(Backbone.Model);
    Results = (function(_super) {
      __extends(Results, _super);

      function Results() {
        return Results.__super__.constructor.apply(this, arguments);
      }

      Results.prototype.model = ResultModel;

      return Results;

    })(Backbone.Collection);
    ResultView = (function(_super) {
      __extends(ResultView, _super);

      function ResultView() {
        this.unrender = __bind(this.unrender, this);
        this.render = __bind(this.render, this);
        return ResultView.__super__.constructor.apply(this, arguments);
      }

      ResultView.prototype.initialize = function() {
        _.bindAll(this);
        this.model.bind('change', this.render);
        return this.model.bind('remove', this.unrender);
      };

      ResultView.prototype.render = function() {
        $(this.el).html("\n<div class=\"panel panel-default\">\n  <div class=\"panel-heading\">\n    <i class=\"fa fa-truck\"></i>\n    <a href=\"\">" + (this.model.get('applicant')) + "</a>\n    <span class=\"badge pull-right\"> " + (this.model.get('facilitytype')) + "</span>\n  </div>\n</div>\n<p><i class=\"fa fa-spoon\"></i><i class=\"fa fa-cutlery\"></i> " + (this.model.get('fooditems').replace(/:/g, ',')) + "</p>\n\n<p>\n    <img src=\"http://maps.google.com/mapfiles/marker" + (this.model.get('letter')) + ".png\"/>\n  <span class=\"location\">\n    <a href=\"#\" letter=" + (this.model.get('letter')) + " longitude=" + (this.model.get('longitude')) + " latitude=" + (this.model.get('latitude')) + ">\n      " + (this.model.get('address')) + "\n      <i class=\"fa fa-location-arrow\"></i>\n    </a>\n  </span>\n</p>\n\n<p>\n  <span>\n    <i class=\"fa fa-clock-o\"></i>\n    <a href=\"" + (this.model.get('schedule')) + "\">\n      Schedule\n    </a>\n  </span>\n</p>\n\n<hr>");
        return this;
      };

      ResultView.prototype.unrender = function() {
        return $(this.el).remove();
      };

      ResultView.prototype.onClickLocation = function(e) {
        var latitude, letter, longitude;
        latitude = e.target.getAttribute('latitude');
        longitude = e.target.getAttribute('longitude');
        letter = e.target.getAttribute('letter');
        return GoogleMaps.dropMarker(latitude, longitude, 'BOUNCE', letter);
      };

      ResultView.prototype.remove = function() {
        return this.model.destroy();
      };

      ResultView.prototype.events = {
        'click .location': 'onClickLocation'
      };

      return ResultView;

    })(Backbone.View);
    ResultsView = (function(_super) {
      __extends(ResultsView, _super);

      function ResultsView() {
        this.reset = __bind(this.reset, this);
        this.createResult = __bind(this.createResult, this);
        return ResultsView.__super__.constructor.apply(this, arguments);
      }

      ResultsView.prototype.el = $('span#results');

      ResultsView.prototype.initialize = function() {
        _.bindAll(this);
        this.collection = new Results;
        this.collection.bind('add', this.appendItem);
        this.counter = 0;
        this.render();
        return this.locationMarkers = [];
      };

      ResultsView.prototype.render = function() {
        return $(this.el).append('<ul id="movies"></ul>');
      };

      ResultsView.prototype.renderNoResult = function() {
        $('#reverse-geo').html("<h4>No location selected</h4>");
        return $(this.el).html("<span id=\"no-result\">\n   <div class=\"panel panel-default\">\n      <div class=\"panel-heading\">\n        <a href=\"\">No Results</a>\n        <span class=\"badge pull-right\">0</span>\n      </div>\n    </div>\n    <p><i class=\"fa fa-keyboard-o\"></i> Click on a location in map</p>\n    <p><i class=\"fa fa-chevron-down fa-3\"></i>   or   <i class=\"fa fa-chevron-up fa-3\"></i></p>\n    <p><i class=\"fa fa-hand-o-up\"></i> Click one from below</p>\n    <ul id=\"search-suggestions\">\n      <li><a latitude=\"37.8018\" longitude=\"-122.4198\" href=\"#\">Russian Hill</a></li>\n      <li><a latitude=\"37.7952\" longitude=\"-122.4029\" href=\"#\">Financial District</a></li>\n      <li><a latitude=\"37.793230\" longitude=\"-122.414480\" href=\"#\">Nob Hill</a></li>\n      <li><a latitude=\"37.778448826783546\" longitude=\"-122.40564800798893\" href=\"#\">South of Market</a></li>\n      <li><a latitude=\"37.759179946191786\" longitude=\"-122.38921143114567\" href=\"#\">Dogpatch</a></li>\n    </ul>\n<span>");
      };

      ResultsView.prototype.removeNoReuslt = function() {
        return $('#no-result').remove();
      };

      ResultsView.prototype.createResult = function(resultData) {
        var locationMarker, resultModel;
        resultModel = new ResultModel(resultData);
        locationMarker = GoogleMaps.dropMarker(resultData.latitude.toString(), resultData.longitude.toString(), 'DROP', resultData.letter);
        this.locationMarkers.push(locationMarker);
        this.collection.add(resultModel);
        return resultModel;
      };

      ResultsView.prototype.appendItem = function(resultModel) {
        var item_view;
        item_view = new ResultView({
          model: resultModel
        });
        return $('span#results').append(item_view.render().el);
      };

      ResultsView.prototype.reset = function() {

        /*
        Clears all locationMarkers and destroys all models1
         */
        var locationMarker, _i, _len, _ref;
        _ref = this.locationMarkers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          locationMarker = _ref[_i];
          locationMarker.setMap(null);
        }
        this.collection.each(function(model) {
          return model.destroy();
        });
        return this.renderNoResult();
      };

      return ResultsView;

    })(Backbone.View);
    SearchController = (function(_super) {
      __extends(SearchController, _super);

      function SearchController() {
        this.onClickMap = __bind(this.onClickMap, this);
        this.search = __bind(this.search, this);
        this.reverseGeocoder = __bind(this.reverseGeocoder, this);
        this.debounceSearch = __bind(this.debounceSearch, this);
        this.onClickSearchSuggestions = __bind(this.onClickSearchSuggestions, this);
        this._setQuery = __bind(this._setQuery, this);
        this.onClickSearchField = __bind(this.onClickSearchField, this);
        this.render = __bind(this.render, this);
        return SearchController.__super__.constructor.apply(this, arguments);
      }

      SearchController.prototype.el = $('body');

      SearchController.prototype.searchFieldEl = $('#search-field');

      SearchController.prototype.searchFieldOptionsEl = $('#search-field-options');

      SearchController.prototype.searchTextEl = $('#search-text');

      SearchController.prototype.SEARCH_FIELDS = {
        DIRECTOR: {
          label: 'Director',
          value: 'director'
        },
        RELEASE_YEAR: {
          label: 'Release year',
          value: 'release_year'
        },
        TITLE: {
          label: 'Title',
          value: 'title'
        },
        ADDRESS: {
          label: 'Address',
          value: 'addresses'
        },
        ACTOR: {
          label: 'Actors',
          value: 'actors'
        },
        WRITE: {
          label: 'Writer',
          value: 'writer'
        },
        PRODUCTION_COMPANY: {
          label: 'Production Company',
          value: 'production_company'
        },
        DISTRIBUTOR: {
          label: 'Distributor',
          value: 'distributor'
        },
        FUN_FACTS: {
          label: 'Fun Facts',
          value: 'fun_facts'
        }
      };

      SearchController.prototype.initialize = function() {
        this.resultsView = new ResultsView;
        this.resultsView.renderNoResult();
        this.searchField = this.SEARCH_FIELDS.TITLE;
        google.maps.event.addListener(map, 'click', this.onClickMap);
        return this.render();
      };

      SearchController.prototype.render = function() {
        return this.searchFieldEl.html("" + this.searchField.label + " <span class=\"glyphicon glyphicon-chevron-down\"></span>");
      };

      SearchController.prototype.onClickSearchField = function(e) {
        var fieldName;
        fieldName = e.target.getAttribute('field');
        return this._setField(fieldName);
      };

      SearchController.prototype._setField = function(fieldName) {
        this.searchField = this.SEARCH_FIELDS[fieldName];
        return this.render();
      };

      SearchController.prototype._setQuery = function(query) {
        return this.searchTextEl.val(query);
      };

      SearchController.prototype.onClickSearchSuggestions = function(e) {
        var latitude, longitude;
        latitude = e.target.getAttribute('latitude');
        longitude = e.target.getAttribute('longitude');
        return this.search(latitude, longitude);
      };

      SearchController.prototype.debounceSearch = function() {
        if (this._debounceSearch == null) {
          this._debounceSearch = _.debounce(this.search, 500);
        }
        return this._debounceSearch();
      };

      SearchController.prototype.addSuggestions = function(movies) {
        var movie, suggestion, suggestions, _i, _j, _len, _len1, _ref, _ref1, _results, _suggestions;
        $('#suggestions').html('');
        suggestions = [];
        for (_i = 0, _len = movies.length; _i < _len; _i++) {
          movie = movies[_i];
          suggestions = (_ref = this.searchField.value) === 'actors' || _ref === 'addresses' ? suggestions.concat(movie[this.searchField.value]) : this.searchField.value === 'fun_facts' ? (_suggestions = (function() {
            var _j, _len1, _ref1, _results;
            _ref1 = movie[this.searchField.value];
            _results = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              suggestion = _ref1[_j];
              _results.push(suggestion.slice(0, 51));
            }
            return _results;
          }).call(this), suggestions.concat(_suggestions)) : suggestions.concat([movie[this.searchField.value]]);
        }
        _ref1 = _.uniq(suggestions);
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          suggestion = _ref1[_j];
          _results.push($('#suggestions').append("<option value=\"" + suggestion + "\">"));
        }
        return _results;
      };

      SearchController.prototype.reverseGeocoder = function(latitude, longitude) {
        var geocoder, latlng;
        geocoder = new google.maps.Geocoder();
        latlng = new google.maps.LatLng(latitude, longitude);
        return geocoder.geocode({
          latLng: latlng
        }, (function(_this) {
          return function(data, status) {
            if (status === google.maps.GeocoderStatus.OK) {
              return $('#reverse-geo').html("<h5>Food trucks near</h5>\n<h5>" + data[1].formatted_address + "</h5>");
            }
          };
        })(this));
      };

      SearchController.prototype.search = function(latitude, longitude) {
        var center;
        if (latitude == null) {
          latitude = 37.758895;
        }
        if (longitude == null) {
          longitude = -122.41472420000002;
        }
        this.reverseGeocoder(latitude, longitude);
        center = new google.maps.LatLng(latitude, longitude);
        map.setCenter(center);
        map.setZoom(15);
        return $.ajax({
          url: "/facility?latitude=" + latitude + "&longitude=" + longitude,
          dataType: "json",
          error: function(jqXHR, textStatus, errorThrown) {
            return console.error(jqXHR, textStatus, errorThrown);
          },
          success: (function(_this) {
            return function(searchResults, textStatus, jqXHR) {
              var resultData, _i, _len, _ref, _results;
              console.log(searchResults, textStatus, jqXHR);
              _this.resultsView.reset();
              if (searchResults.facilities.length > 0) {
                _this.resultsView.removeNoReuslt();
              }
              _ref = searchResults.facilities.slice(0, 11);
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                resultData = _ref[_i];
                _results.push(_this.resultsView.createResult(resultData));
              }
              return _results;
            };
          })(this)
        });
      };

      SearchController.prototype.onClickMap = function(e) {
        var latitude, longitude;
        latitude = e.latLng.lat();
        longitude = e.latLng.lng();
        console.log(latitude, longitude);
        return this.search(latitude, longitude);
      };

      SearchController.prototype.events = {
        'keyup :input#search-text': 'debounceSearch',
        'click #search-field-options': 'onClickSearchField',
        'click #search-suggestions': 'onClickSearchSuggestions'
      };

      return SearchController;

    })(Backbone.View);
    Backbone.sync = function(method, model, success, error) {
      return success();
    };
    _initialize = function() {
      var searchController;
      return searchController = new SearchController();
    };
    return google.maps.event.addDomListener(window, 'load', _initialize);
  });

}).call(this);
