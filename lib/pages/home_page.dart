import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../helpers/app_localizations.dart';
import '../providers/auth_service.dart';
import '../providers/language_provider.dart';
import '../providers/location_provider.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _dialogShown = false;
  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage?;



    final mapProvider = Provider.of<MapProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);

    final isDarkMode = themeProvider.isDarkMode;
    final tileUrl = isDarkMode
        ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";




    if (message != null && !_dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNotificationDialog(context, message);
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('title')),
        actions: [
          DropdownButton<String>(
            icon: Icon(Icons.language,
                color:
                    themeProvider.isDarkMode ? Colors.white : Colors.grey[800]),
            value: languageProvider.locale.languageCode,
            dropdownColor:
                themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
            items: <String>['en', 'de'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase(),
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.grey[800])),
              );
            }).toList(),
            onChanged: (String? newLanguage) {
              if (newLanguage != null) {
                languageProvider.setLanguage(newLanguage);
              }
            },
          ),
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();

              navigatorKey.currentState?.pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: mapProvider.currentLocation == null
          ? Container(
              color: Colors.black54,
              child: Center(
                child: Image.asset(
                  'assets/images/loading.gif',
                  width: 100,
                  height: 100,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8.0),
                                      width: 24,
                                      height: 24,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.blue,
                                                width: 2.0,
                                              ),
                                            ),
                                            child: const CircleAvatar(
                                              radius: 4,
                                              backgroundColor: Colors.purple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: mapProvider.startController,
                                        decoration: InputDecoration(
                                          labelText:
                                              localizations.translate('from'),
                                          hintText: localizations
                                              .translate('starting_location'),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 10),
                                          suffixIcon: IconButton(
                                            icon: const Icon(Icons.gps_fixed,
                                                color: Colors.purple, size: 24),
                                            onPressed: () {
                                              if (mapProvider.currentLocation !=
                                                  null) {
                                                final startLatLng = LatLng(
                                                    mapProvider.currentLocation!
                                                        .latitude!,
                                                    mapProvider.currentLocation!
                                                        .longitude!);
                                                mapProvider.updateLocationName(
                                                    mapProvider.startController,
                                                    startLatLng);
                                              }
                                            },
                                          ),
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.place,
                                        color: Colors.redAccent, size: 24),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: mapProvider.endController,
                                        decoration: InputDecoration(
                                          labelText:
                                              localizations.translate('to'),
                                          hintText: localizations
                                              .translate('ending_location'),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 10),
                                          suffixIcon: IconButton(
                                            icon: const Icon(Icons.swap_vert,
                                                color: Colors.purple, size: 24),
                                            onPressed:
                                                mapProvider.swapLocations,
                                          ),
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      final startAddress =
                                          mapProvider.startController.text;
                                      final endAddress =
                                          mapProvider.endController.text;

                                      if (startAddress.isEmpty ||
                                          endAddress.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                localizations.translate(
                                                    'please_enter_addresses')),
                                          ),
                                        );
                                        return;
                                      }

                                      try {
                                        final startLocations =
                                            await locationFromAddress(
                                                startAddress);
                                        final endLocations =
                                            await locationFromAddress(
                                                endAddress);

                                        if (startLocations.isNotEmpty &&
                                            endLocations.isNotEmpty) {
                                          LatLng startLatLng = LatLng(
                                              startLocations[0].latitude,
                                              startLocations[0].longitude);
                                          LatLng endLatLng = LatLng(
                                              endLocations[0].latitude,
                                              endLocations[0].longitude);

                                          await mapProvider.getRoute(
                                              startLatLng, endLatLng);
                                          setState(() {
                                            mapProvider.mapCenter = startLatLng;
                                            mapProvider.lastMapCenter =
                                                startLatLng;
                                          });
                                          mapProvider.mapController.move(
                                              mapProvider.mapCenter,
                                              mapProvider.mapZoom);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                localizations.translate(
                                                    'invalid_addresses')),
                                          ));
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(localizations.translate(
                                              'error_fetching_addresses')),
                                        ));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      backgroundColor: isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                      minimumSize: const Size.fromHeight(
                                          40), // Reduced height
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Rounded corners
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.directions,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.blue),
                                        const SizedBox(width: 8),
                                        Text(
                                          localizations.translate('go'),
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.blueGrey
                                                : Colors.blue,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapProvider.mapController,
                        options: MapOptions(
                          initialCenter: mapProvider.mapCenter,
                          initialZoom: mapProvider.mapZoom,
                          onPositionChanged:
                              (MapCamera position, bool hasGesture) {
                            if (hasGesture) {
                              mapProvider.lastMapCenter = position.center;
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: tileUrl,
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: mapProvider.markers +
                                mapProvider.gasStationMarkers,
                          ),
                          if (mapProvider.isRouteVisible)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: mapProvider.routePoints,
                                  strokeWidth: 4.0,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (mapProvider.isLoading)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Image.asset(
                              'assets/images/loading.gif',
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                      Positioned(
                        right: 10,
                        bottom: 70,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 40.0,
                              height: 40.0,
                              child: FloatingActionButton(
                                heroTag: 'zoom_in',
                                backgroundColor: isDarkMode
                                    ? Colors.grey[850]
                                    : Colors.blueAccent,
                                onPressed: () {
                                  setState(() {
                                    mapProvider.mapZoom += 1.0;
                                    mapProvider.mapController.move(
                                        mapProvider.lastMapCenter ??
                                            mapProvider.mapCenter,
                                        mapProvider.mapZoom);
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                elevation: 6.0,
                                child: Icon(
                                  Icons.zoom_in,
                                  color:
                                      isDarkMode ? Colors.white : Colors.white,
                                  size: 24.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 40.0,
                              height: 40.0,
                              child: FloatingActionButton(
                                heroTag: 'zoom_out',
                                backgroundColor: isDarkMode
                                    ? Colors.grey[850]
                                    : Colors.blueAccent,
                                onPressed: () {
                                  setState(() {
                                    mapProvider.mapZoom -= 1.0;
                                    mapProvider.mapController.move(
                                        mapProvider.lastMapCenter ??
                                            mapProvider.mapCenter,
                                        mapProvider.mapZoom);
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      50.0), // Rounded shape
                                ),
                                elevation: 6.0,
                                child: Icon(
                                  Icons.zoom_out,
                                  color:
                                      isDarkMode ? Colors.white : Colors.white,
                                  size: 24.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 40.0,
                              height: 40.0,
                              child: FloatingActionButton(
                                heroTag: 'toggle_style',
                                backgroundColor: isDarkMode
                                    ? Colors.grey[850]
                                    : Colors.blueAccent,
                                onPressed: () {
                                  if (mapProvider.currentLocation != null) {
                                    setState(() {
                                      mapProvider.mapCenter = LatLng(
                                          mapProvider
                                              .currentLocation!.latitude!,
                                          mapProvider
                                              .currentLocation!.longitude!);
                                      mapProvider.mapZoom = 15.0;
                                    });
                                    mapProvider.mapController.move(
                                        mapProvider.mapCenter,
                                        mapProvider.mapZoom);
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      50.0), // Rounded shape
                                ),
                                elevation: 6.0,
                                child: Icon(
                                  Icons.my_location,
                                  color:
                                      isDarkMode ? Colors.white : Colors.white,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (mapProvider.isDrawerVisible && !mapProvider.isLoading)
                  Container(
                    color: isDarkMode ? Colors.black38 : Colors.white,
                    child: ListTile(
                      title: Text(
                        localizations.translate('show_gas_stations'),
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87),
                      ),
                      trailing: Icon(Icons.list,
                          color: isDarkMode ? Colors.white : Colors.black87),
                      onTap: () {
                        mapProvider.showBottomDrawer(context);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  void _showNotificationDialog(BuildContext context, RemoteMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('notification')),
          content: Text(message.notification?.body ?? 'No message content'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _dialogShown = true; // Mark dialog as shown
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

