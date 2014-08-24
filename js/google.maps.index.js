// Script to load google maps and zoom in to san srancisco.
var sanFrancisco = new google.maps.LatLng(37.758895, -122.41472420000002);

var map;

function initialize() {
  var mapOptions = {
    zoom: 12,
    center: sanFrancisco
  };

  map = new google.maps.Map(document.getElementById('map-canvas'),
          mapOptions);
}

google.maps.event.addDomListener(window, 'load', initialize);
