###
SF Food Truck UI, includes models and views
###
jQuery ->

  class GoogleMaps
    ###
    A container to hold all google map interactions.
    ###
    @locationMarkers = []

    @dropMarker: (latitude, longitude, animation='DROP', letter='Z') ->
      ###
      Given latitude, longitude, animation='DROP', letter='Z'
      drops a marker with the appropriate animation on maps
      ###
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

      @locationMarkers.push(marker)
      marker

    @clearAllMarkers: ->
      ###clear all markers###
      for locationMarker in @locationMarkers
        locationMarker.setMap(null)

  class ResultModel extends Backbone.Model
    ###
    Search Result model
    a instance of this model is created for each record returned from the server.
    ###
    defaults:
      part1: 'Hello'
      part2: 'Backbone'


  class Results extends Backbone.Collection
    ###
    A Collection container to hold previously defined ResultModel
    ###
    model: ResultModel


  class ResultView extends Backbone.View
    ###
    A view corresponding to each ResultModel instance
    ###
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
      ###
      function fired in response to the onClick event for a location
      this animates the corresponding marker for this address.
      ###
      latitude = e.target.getAttribute('latitude')
      longitude = e.target.getAttribute('longitude')
      letter = e.target.getAttribute('letter')
      GoogleMaps.dropMarker(latitude, longitude, 'BOUNCE', letter)

    remove: -> @model.destroy()

    # `ResultView`s now respond to click actions for each `Item`.
    events:
      'click .location': 'onClickLocation'


  class ResultsView extends Backbone.View
    ###
    The contained holding all individual result views.
    ###
    el: $ 'span#results'

    initialize: ->
      _.bindAll @

      @collection = new Results
      @collection.bind 'add', @appendItem

      @counter = 0
      @render()

    render: ->
      $(@el).append '<ul id="movies"></ul>'

    renderNoResult: ->
      ###
      Renders the no result section when no models have yet been retrieved.
      This section all so includes few location suggestions
      ###
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
      ###
      Given a resultData obj, creates a resultModel.
      ###
      resultModel = new ResultModel(resultData)
      GoogleMaps.dropMarker(resultData.latitude.toString(), resultData.longitude.toString(), 'DROP', resultData.letter)

      @collection.add resultModel
      resultModel

    appendItem: (resultModel) ->
      ###
      This function is fired in-respond to a new model addtion to this collection.
      It renders the result view for this model and appends the view to the results listing.
      ###
      item_view = new ResultView model: resultModel
      $('span#results').append item_view.render().el

    reset: =>
      ###
      Clears all locationMarkers and destroys all models
      ###
      GoogleMaps.clearAllMarkers()

      @collection.each((model) -> model.destroy())
      @renderNoResult()


  class SearchController extends Backbone.View
    ###
    Master App controller responsible for
    1. intializing all underlying view/controllers.
    2. Fetch searchResults from server for user requests.
    3. Finally add searchResults to the resultsView.
    ###

    el: $ 'body'

    initialize: ->
      @resultsView = new ResultsView
      @resultsView.renderNoResult()
      google.maps.event.addListener(map, 'click', @onClickMap)

    reverseGeocoder: (latitude, longitude) =>
      ###
      Retreives human readable address for a user requested co-ordinates.
      ###
      geocoder = new google.maps.Geocoder();

      latlng = new google.maps.LatLng(latitude, longitude)

      geocoder.geocode {latLng:latlng}, (data,status) =>
        if status is google.maps.GeocoderStatus.OK
          $('#reverse-geo').html """
            <h5>Food trucks near</h5>
            <h5>#{data[1].formatted_address}</h5>
          """

    search: (latitude=37.758895, longitude=-122.41472420000002) =>
      ###
      Trigger for every user request
      Firstly, fetches searchResults from server for user requests.
      on success adds searchResults to the resultsView.
      ###
      @reverseGeocoder(latitude, longitude)

      #zoom into to the user requested location on map
      center = new google.maps.LatLng(latitude, longitude)
      map.setCenter(center)
      map.setZoom(15)

      # fire the ajax request to fetch searchResults from API endpoint
      $.ajax
        url: "/facility?latitude=#{latitude}&longitude=#{longitude}"
        dataType: "json"
        error: (jqXHR, textStatus, errorThrown) ->
          console.error jqXHR, textStatus, errorThrown

        success: (searchResults, textStatus, jqXHR) =>
          #on success adds searchResults to the resultsView.
          @resultsView.reset()
          @resultsView.removeNoReuslt() if searchResults.facilities.length > 0
          for resultData in searchResults.facilities[0..10]
            @resultsView.createResult(resultData)

    onClickSearchSuggestions: (e) =>
      ###
      function trigger when user clicks on any of the suggested locations.
      ###
      latitude = e.target.getAttribute('latitude')
      longitude = e.target.getAttribute('longitude')
      @search(latitude, longitude)

    onClickMap: (e) =>
      ###
      triggered when user clicks on a location in the map
      call the search function for user requested co-ordinates
      ###
      latitude = e.latLng.lat()
      longitude = e.latLng.lng()
      @search(latitude, longitude)

    events:
      'click #search-suggestions': 'onClickSearchSuggestions'

  # We'll override
  # [`Backbone.sync`](http://documentcloud.github.com/backbone/#Sync)
  Backbone.sync = (method, model, success, error) ->

    # Perform a NOOP when we successfully change our model. In our example,
    # this will happen when we remove each Item view.
    success()

  _initialize = ->
    # initializa the app once google maps has loaded.
    searchController = new SearchController()

  google.maps.event.addDomListener(window, 'load', _initialize)