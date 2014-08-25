###
###
jQuery ->

  class GoogleMaps

    @dropMarker: (latitude, longitude, animation='DROP', letter='Z') ->
      switch animation
        when 'BOUNCE'
          animation = google.maps.Animation.BOUNCE

        when 'DROP'
          animation = google.maps.Animation.DROP

        else
          animation = google.maps.Animation.DROP

      position = new google.maps.LatLng(latitude, longitude)
      marker = new google.maps.Marker
        position: position
        map: map
        draggable: false
        animation: animation
        icon: "http://maps.google.com/mapfiles/marker#{letter}.png"


  class ResultModel extends Backbone.Model

    defaults:
      part1: 'Hello'
      part2: 'Backbone'

  class Results extends Backbone.Collection

    model: ResultModel


  class ResultView extends Backbone.View

    initialize: ->
      _.bindAll @

      @model.bind 'change', @render
      @model.bind 'remove', @unrender

    render: =>
      $(@el).html """

        <div class="panel panel-default">
          <div class="panel-heading">
            <i class="fa fa-truck"></i>
            <a href="">#{@model.get 'applicant'}</a>
            <span class="badge pull-right"> #{@model.get 'facilitytype'}</span>
          </div>
        </div>
        <p>#{@model.get('status')}</p>
        <p><i class="fa fa-spoon"></i><i class="fa fa-cutlery"></i> #{@model.get('fooditems').replace(/:/g, ',')}</p>

        <p>
            <img src="http://maps.google.com/mapfiles/marker#{@model.get 'letter'}.png"/>
          <span class="location">
            <a href="#" letter=#{@model.get 'letter'} longitude=#{@model.get 'longitude'} latitude=#{@model.get 'latitude'}>
              #{@model.get 'address'}
              <i class="fa fa-location-arrow"></i>
            </a>
          </span>
        </p>
        <p>#{@model.get('locationdescription')}</p>

        <p>
          <span>
            <i class="fa fa-clock-o"></i>
            <a href="#{@model.get 'schedule'}">
              Schedule
            </a>
          </span>
        </p>

        <hr>
      """

      @

    unrender: =>
      $(@el).remove()

    onClickLocation: (e) ->
      latitude = e.target.getAttribute('latitude')
      longitude = e.target.getAttribute('longitude')
      letter = e.target.getAttribute('letter')
      GoogleMaps.dropMarker(latitude, longitude, 'BOUNCE', letter)

    remove: -> @model.destroy()

    # `ResultView`s now respond to click actions for each `Item`.
    events:
      'click .location': 'onClickLocation'


  class ResultsView extends Backbone.View

    el: $ 'span#results'

    initialize: ->
      _.bindAll @

      @collection = new Results
      @collection.bind 'add', @appendItem

      @counter = 0
      @render()
      @locationMarkers = []

    render: ->
      $(@el).append '<ul id="movies"></ul>'

    renderNoResult: ->
      $('#reverse-geo').html """
      <h4>Please select a location.</h4>
      """

      $(@el).html """
      <span id="no-result">
         <div class="panel panel-default">
            <div class="panel-heading">
              <a href="">No Results</a>
              <span class="badge pull-right">0</span>
            </div>
          </div>
          <p><i class="fa fa-keyboard-o"></i> Click on a location in map</p>
          <p><i class="fa fa-chevron-down fa-3"></i>   or   <i class="fa fa-chevron-up fa-3"></i></p>
          <p><i class="fa fa-hand-o-up"></i> Click one from below</p>
          <ul id="search-suggestions">
            <li><a latitude="37.8018" longitude="-122.4198" href="#">Russian Hill</a></li>
            <li><a latitude="37.7952" longitude="-122.4029" href="#">Financial District</a></li>
            <li><a latitude="37.793230" longitude="-122.414480" href="#">Nob Hill</a></li>
            <li><a latitude="37.778448826783546" longitude="-122.40564800798893" href="#">South of Market</a></li>
            <li><a latitude="37.759179946191786" longitude="-122.38921143114567" href="#">Dogpatch</a></li>
          </ul>
      <span>
      """

    removeNoReuslt: ->
      $('#no-result').remove()

    createResult: (resultData) =>
      resultModel = new ResultModel(resultData)
      locationMarker = GoogleMaps.dropMarker(resultData.latitude.toString(), resultData.longitude.toString(), 'DROP', resultData.letter)
      @locationMarkers.push(locationMarker)

      @collection.add resultModel
      resultModel

    appendItem: (resultModel) ->
      item_view = new ResultView model: resultModel
      $('span#results').append item_view.render().el

    reset: =>
      ###
      Clears all locationMarkers and destroys all models1
      ###
      for locationMarker in @locationMarkers
        locationMarker.setMap(null)

      @collection.each((model) -> model.destroy())
      @renderNoResult()


  class SearchController extends Backbone.View
    el: $ 'body'
    searchFieldEl: $('#search-field')
    searchFieldOptionsEl: $('#search-field-options')
    searchTextEl: $('#search-text')

    SEARCH_FIELDS:
      DIRECTOR:
        label: 'Director'
        value: 'director'

      RELEASE_YEAR:
        label: 'Release year'
        value: 'release_year'

      TITLE:
        label: 'Title'
        value: 'title'

      ADDRESS:
        label: 'Address'
        value: 'addresses'

      ACTOR:
        label: 'Actors'
        value: 'actors'

      WRITE:
        label: 'Writer'
        value: 'writer'

      PRODUCTION_COMPANY:
        label: 'Production Company'
        value: 'production_company'

      DISTRIBUTOR:
        label: 'Distributor'
        value: 'distributor'

      FUN_FACTS:
        label: 'Fun Facts'
        value: 'fun_facts'


    initialize: ->
      @resultsView = new ResultsView
      @resultsView.renderNoResult()
      @searchField = @SEARCH_FIELDS.TITLE
      google.maps.event.addListener(map, 'click', @onClickMap)
      @render()

    render: =>
      @searchFieldEl.html """
       #{@searchField.label} <span class="glyphicon glyphicon-chevron-down"></span>
      """

    onClickSearchField: (e) =>
      fieldName = e.target.getAttribute('field')
      @_setField(fieldName)

    _setField: (fieldName) ->
      @searchField = @SEARCH_FIELDS[fieldName]
      @render()

    _setQuery: (query) =>
      @searchTextEl.val(query)

    onClickSearchSuggestions: (e) =>
      latitude = e.target.getAttribute('latitude')
      longitude = e.target.getAttribute('longitude')
      @search(latitude, longitude)

    debounceSearch: =>
      @_debounceSearch ?= _.debounce(@search, 500)
      @_debounceSearch()

    addSuggestions: (movies)->
      $('#suggestions').html('')
      suggestions = []
      for movie in movies
        suggestions = if @searchField.value in ['actors', 'addresses']
          suggestions.concat(movie[@searchField.value])
        else if @searchField.value is 'fun_facts'
          _suggestions = (suggestion[0..50] for suggestion in movie[@searchField.value])
          suggestions.concat(_suggestions)
        else
          suggestions.concat([movie[@searchField.value]])

      for suggestion in _.uniq(suggestions)
        $('#suggestions').append "<option value=\"#{suggestion}\">"

    reverseGeocoder: (latitude, longitude) =>
      geocoder = new google.maps.Geocoder();

      latlng = new google.maps.LatLng(latitude, longitude)

      geocoder.geocode {latLng:latlng}, (data,status) =>
        if status is google.maps.GeocoderStatus.OK
          $('#reverse-geo').html """
            <h5>Food trucks near</h5>
            <h5>#{data[1].formatted_address}</h5>
          """

    search: (latitude=37.758895, longitude=-122.41472420000002) =>
      @reverseGeocoder(latitude, longitude)
      center = new google.maps.LatLng(latitude, longitude)
      map.setCenter(center)
      map.setZoom(15)

      $.ajax
        # url: "/movies?query=#{searchText}&field=#{@searchField.value}"
        url: "/facility?latitude=#{latitude}&longitude=#{longitude}"
        dataType: "json"
        error: (jqXHR, textStatus, errorThrown) ->
          console.error jqXHR, textStatus, errorThrown

        success: (searchResults, textStatus, jqXHR) =>
          console.log searchResults, textStatus, jqXHR
          @resultsView.reset()
          @resultsView.removeNoReuslt() if searchResults.facilities.length > 0
          # @addSuggestions(searchResults.movies)
          for resultData in searchResults.facilities[0..10]
            # console.log resultData
            # GoogleMaps.dropMarker(resultData.latitude.toString(), resultData.longitude.toString())
            @resultsView.createResult(resultData)

    onClickMap: (e) =>
      latitude = e.latLng.lat()
      longitude = e.latLng.lng()
      console.log latitude, longitude
      @search(latitude, longitude)

    events:
      'keyup :input#search-text': 'debounceSearch'
      'click #search-field-options': 'onClickSearchField'
      'click #search-suggestions': 'onClickSearchSuggestions'

  # We'll override
  # [`Backbone.sync`](http://documentcloud.github.com/backbone/#Sync)
  Backbone.sync = (method, model, success, error) ->

    # Perform a NOOP when we successfully change our model. In our example,
    # this will happen when we remove each Item view.
    success()

  _initialize = ->
    searchController = new SearchController()


  google.maps.event.addDomListener(window, 'load', _initialize)