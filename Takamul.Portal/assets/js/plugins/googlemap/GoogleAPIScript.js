

//creating function to load initial MAP when page loading 
function LoadGoogleMAP() {
    var markers = [];
    var map = new google.maps.Map(document.getElementById('divloadMap'), {
        mapTypeId: google.maps.MapTypeId.ROADMAP
    });

    var defaultBounds = new google.maps.LatLngBounds(
      new google.maps.LatLng(23.5859, 58.4059),
      new google.maps.LatLng(23.614328, 58.545284));
    map.fitBounds(defaultBounds);

    // Create the search box and link it to the UI element.
    var input = (document.getElementById('txtsearch'));
    map.controls[google.maps.ControlPosition.TOP_CENTER].push(input);

    var searchBox = new google.maps.places.SearchBox((input));


    // Listen for the event fired when the user selects an item from the
    // pick list. Retrieve the matching places for that item.
    google.maps.event.addListener(searchBox, 'places_changed', function () {
        var places = searchBox.getPlaces();

        if (places.length == 0) {
            return;
        }
        for (var i = 0, marker; marker = markers[i]; i++) {
            marker.setMap(null);
        }

        // For each place, get the icon, place name, and location.
        markers = [];
        var bounds = new google.maps.LatLngBounds();
        for (var i = 0, place; place = places[i]; i++) {
            var image = {
                url: place.icon,
                size: new google.maps.Size(71, 71),
                origin: new google.maps.Point(0, 0),
                anchor: new google.maps.Point(17, 34),
                scaledSize: new google.maps.Size(25, 25)
            };

            // Create a marker for each place.
            var marker = new google.maps.Marker({
                map: map,
                icon: image,
                title: place.name,
                position: place.geometry.location
            });

            markers.push(marker);

            bounds.extend(place.geometry.location);
        }

        map.fitBounds(bounds);
    });

    // double click event
    google.maps.event.addListener(map, 'dblclick', function (e) {
        clearOverlays();

        var positionDoubleclick = e.latLng;
        var lat = positionDoubleclick.lat();
        var lng = positionDoubleclick.lng();
        var myLatLng = { lat: lat, lng: lng };
        var marker = new google.maps.Marker({
            position: myLatLng,
            map: map
        });

        marker.setPosition(positionDoubleclick);

        markers.push(marker);

        $("#EVENT_LATITUDE").val(lat.toFixed(4));
        $("#EVENT_LONGITUDE").val(lng.toFixed(4));

        // if you don't do this, the map will zoom in
        //e.stopPropagation();
    });

    // current map's viewport.
    google.maps.event.addListener(map, 'bounds_changed', function () {
        var bounds = map.getBounds();
        searchBox.setBounds(bounds);
    });

    function clearOverlays() {
        for (var i = 0; i < markers.length; i++) {
            markers[i].setMap(null);
        }
        markers.length = 0;
    }
}

google.maps.event.addDomListener(window, 'load', LoadGoogleMAP);