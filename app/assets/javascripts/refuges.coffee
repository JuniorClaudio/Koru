@loadMapWithLocations = (locations) ->
  lima =
    lat: -12.0431800
    lng: -77.0282400
  map = new (google.maps.Map)(document.getElementById('refuges-map'),
    zoom: 12
    center: lima)
  locations = locations
  infowindow = new (google.maps.InfoWindow)
  markers = []
  for location in locations
    marker = new (google.maps.Marker)(
      position: new (google.maps.LatLng)(location[1], location[2])
      content: location[0]
      id: location[3]
      city: location[4]
      country: location[5]
      status: location[6]
      map: map)
    markers.push marker
    google.maps.event.addListener marker, 'mouseover', do (marker) ->
      ->
        infowindow.setContent marker.content
        infowindow.open map, marker
        return
    google.maps.event.addListener marker, 'mouseout', ((marker) ->
      ->
        infowindow.close()
        return
    )()
  bounds = new (google.maps.LatLngBounds)
  j = 0

  if sessionStorage["new_locations"] != undefined && sessionStorage["new_locations"] != ""
    new_markers = sessionStorage["new_locations"].split("),(")
    last = new_markers.pop().slice(0, -1)
    new_markers.push(last)
    first = new_markers.shift().substring(1);
    new_markers.unshift(first)
    if new_markers != undefined
      while j < new_markers.length
        new_marker = new_markers[j]
        lat = parseFloat(new_marker.split(", ")[0])
        long = parseFloat(new_marker.split(", ")[1])
        new_marker = new google.maps.LatLng(lat, long)
        bounds.extend new_marker
        j++
      map.fitBounds bounds
  else
    for location in locations
      lat = location[1]
      lng = location[2]
      marker = new google.maps.LatLng(lat, lng)
      bounds.extend marker
    map.fitBounds bounds

  sidebar = document.getElementById("list-refuges")
  google.maps.event.addListener map, 'bounds_changed', ->
    sidebar.innerHTML = ""
    results = new Array
    new_locations = new Array
    i = 0
    while i < markers.length
      if map.getBounds().contains(markers[i].getPosition())
        results.push markers[i]
      i++
    if results.length == 0
      sidebar.innerHTML = '<li><a href="#"><div><h4>No refuges found in the location in the map.</h4></div><a></li>'
    else
      for result in results
        refuge_status = ""
        new_locations.push result.getPosition()
        if result.status == "good"
          refuge_status = "refuge-good"
        else
          refuge_status = "refuge-bad"
        li = document.createElement('li')
        link_to = document.createElement('a')
        table = document.createElement('table')
        tr_name = document.createElement('tr')
        td_status_icon = document.createElement('td')
        td_status_icon.setAttribute("rowspan", "2")
        i = document.createElement('i')
        i.setAttribute("class", "glyphicon glyphicon-certificate " + refuge_status)
        td_status_icon.appendChild(i)
        td_name = document.createElement('td')
        td_name.appendChild(document.createTextNode(result.content))
        tr_name.appendChild(td_status_icon)
        tr_name.appendChild(td_name)
        tr_address = document.createElement('tr')
        td_address = document.createElement('td')
        h6_address = document.createElement('h6')
        h6_address.appendChild(document.createTextNode(result.city + ", " + result.country))
        td_address.appendChild(h6_address)
        tr_address.appendChild(td_address)
        table.appendChild(tr_name)
        table.appendChild(tr_address)
        link_to.append(table)
        link_to.setAttribute("href", "/refuges/" + result.id + "/detail")
        link_to.setAttribute("data-method", "get")
        link_to.setAttribute("data-remote", "true")
        li.appendChild(link_to)
        sidebar.appendChild(li)
      sessionStorage["refuges_list"] = sidebar.innerHTML
    sessionStorage["new_locations"] = new_locations
    return

  # Search for google maps
  input = document.getElementById('input-search')
  searchBox = new (google.maps.places.SearchBox)(input)
  map.addListener 'bounds_changed', ->
    searchBox.setBounds map.getBounds()
    return
  new_markers = []
  searchBox.addListener 'places_changed', ->
    places = searchBox.getPlaces()
    if places.length == 0
      return
    new_markers.forEach (marker) ->
      marker.setMap null
      return
    new_markers = []
    new_bounds = new (google.maps.LatLngBounds)
    places.forEach (place) ->
      if !place.geometry
        console.log 'Returned place contains no geometry'
        return
      icon =
        url: place.icon
        size: new (google.maps.Size)(71, 71)
        origin: new (google.maps.Point)(0, 0)
        anchor: new (google.maps.Point)(17, 34)
        scaledSize: new (google.maps.Size)(25, 25)
      new_markers.push new (google.maps.Marker)(
        map: map
        icon: icon
        title: place.name
        position: place.geometry.location)
      if place.geometry.viewport
        new_bounds.union place.geometry.viewport
      else
        new_bounds.extend place.geometry.location
      return
    map.fitBounds new_bounds
    return

@initialize_refuges = ->
  $('#refuges-map').css('height', $('#sidebar-nav').height())

document.addEventListener "turbolinks:load", ->
  initialize_refuges()
  $("#search-button").on 'click', ->
    input = document.getElementById('input-search')
    google.maps.event.trigger input, 'focus'
    google.maps.event.trigger input, 'keydown', keyCode: 13
    return