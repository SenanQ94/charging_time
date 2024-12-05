import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapProvider extends ChangeNotifier {
  final MapController mapController = MapController();
  loc.LocationData? currentLocation;
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  List<Marker> gasStationMarkers = [];
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  bool isRouteVisible = false;
  bool isDrawerVisible = false;
  bool isLoading = false;

  double mapZoom = 10.0;
  LatLng mapCenter = const LatLng(50.5, 30.51);
  LatLng? lastMapCenter;
  List<dynamic> gasStations = [];
  List<dynamic> nearbyPlaces = [];
  Map<String, List<Map<String, dynamic>>> gasStationNearbyPlaces = {};
  final String orsApiKey;

  MapProvider(this.orsApiKey) {
    _getCurrentLocation();
  }

  /// Swap the text in the start and end controllers
  void swapLocations() {
    final temp = startController.text;
    startController.text = endController.text;
    endController.text = temp;
    notifyListeners();
  }

  /// Get current user location
  Future<void> _getCurrentLocation() async {
    var location = loc.Location();

    try {
      var userLocation = await location.getLocation();
      currentLocation = userLocation;
      mapCenter = LatLng(userLocation.latitude!, userLocation.longitude!);
      lastMapCenter = mapCenter;
      markers.add(Marker(
        width: 60.0,
        height: 60.0,
        point: mapCenter,
        child: const Icon(Icons.my_location, color: Colors.blue, size: 30.0),
      ));
      notifyListeners();
    } on Exception {
      currentLocation = null;
    }

    location.onLocationChanged.listen((loc.LocationData newLocation) {
      currentLocation = newLocation;
      mapCenter = LatLng(newLocation.latitude!, newLocation.longitude!);
      lastMapCenter = mapCenter;
      notifyListeners();
    });
  }

  /// Get the route between two points
  Future<void> getRoute(LatLng start, LatLng end, {String mode = 'driving-car'}) async {
    isLoading = true;
    routePoints.clear();
    markers.removeWhere((marker) => marker.child is Icon && (marker.child as Icon).color == Colors.red);
    isRouteVisible = false;
    notifyListeners();

    final response = await http.get(
      Uri.parse('https://api.openrouteservice.org/v2/directions/$mode?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
      routePoints = coords.map((coord) => LatLng(coord[1], coord[0])).toList();

      markers.add(Marker(
        width: 60.0,
        height: 60.0,
        point: start,
        child: const Column(children: [
          Icon(Icons.location_on, color: Colors.yellow, size: 30.0),
          Text("Start")
        ]),
      ));

      markers.add(Marker(
        width: 60.0,
        height: 60.0,
        point: end,
        child: const Column(children: [
          Icon(Icons.location_on, color: Colors.blue, size: 30.0),
          Text("End")
        ]),
      ));

      isRouteVisible = true;
      isDrawerVisible = true;
      notifyListeners();
      await fetchNearbyPlaces(start, end);
    } else {
      // Handle error with snackbar in the widget
    }
    isLoading = false;
    notifyListeners();
  }

  /// Fetch nearby places (like gas stations) between two locations
  Future<void> fetchNearbyPlaces(LatLng start, LatLng end) async {
    isLoading = true;
    notifyListeners();

    final response = await http.get(
      Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=gas+station&bounded=1&viewbox=${start.longitude},${start.latitude},${end.longitude},${end.latitude}&radius=500',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      gasStations = data;
      gasStationMarkers = data.map<Marker>((station) {
        return Marker(
          width: 30.0,
          height: 30.0,
          point: LatLng(double.parse(station['lat']), double.parse(station['lon'])),
          child: const Icon(Icons.local_gas_station, color: Colors.red, size: 30.0),
        );
      }).toList();
      notifyListeners();

      for (var station in gasStations) {
        await _fetchNearbyPlacesForStation(
          LatLng(double.parse(station['lat']), double.parse(station['lon'])),
        );
      }
    }
    isLoading = false;
    notifyListeners();
  }

  /// Fetch nearby places for each gas station
  Future<void> _fetchNearbyPlacesForStation(LatLng stationLatLng) async {
    isLoading = true;
    notifyListeners();

    final placesResponse = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=restaurant|supermarket&lat=${stationLatLng.latitude}&lon=${stationLatLng.longitude}&radius=1000'),
    );

    if (placesResponse.statusCode == 200) {
      final placesData = json.decode(placesResponse.body);
      gasStationNearbyPlaces[stationLatLng.toString()] = List<Map<String, dynamic>>.from(placesData);
      notifyListeners();
    }
    isLoading = false;
    notifyListeners();
  }

  /// Update location name based on the coordinates
  Future<void> updateLocationName(TextEditingController controller, LatLng location) async {
    final placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isNotEmpty) {
      controller.text = '${placemarks[0].street}, ${placemarks[0].locality}';
      notifyListeners();
    }
  }

  /// Show a bottom drawer with gas station details
  void showBottomDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: gasStations.length,
          itemBuilder: (context, index) {
            final station = gasStations[index];
            final stationLatLng = LatLng(double.parse(station['lat']), double.parse(station['lon']));
            final nearbyPlaces = gasStationNearbyPlaces[stationLatLng.toString()] ?? [];

            return ListTile(
              leading: const Icon(Icons.local_gas_station, color: Colors.red),
              title: Text(station['display_name']),
              subtitle: Row(
                children: nearbyPlaces.map<Widget>((place) {
                  IconData icon = Icons.place;
                  String category = place['type'];

                  if (category.contains('restaurant')) {
                    icon = Icons.restaurant;
                  } else if (category.contains('supermarket')) {
                    icon = Icons.local_grocery_store;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(icon, color: Colors.blue),
                  );
                }).toList(),
              ),
              onTap: () {
                mapController.move(stationLatLng, 15.0);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }
}