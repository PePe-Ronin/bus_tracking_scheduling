import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/realtime_tracking_service.dart';

class BusTrackingMap extends StatefulWidget {
  final String busId;
  final bool showRoute;

  const BusTrackingMap({
    super.key,
    required this.busId,
    this.showRoute = true,
  });

  @override
  State<BusTrackingMap> createState() => _BusTrackingMapState();
}

class _BusTrackingMapState extends State<BusTrackingMap> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late RealtimeTrackingService _trackingService;
  StreamSubscription? _locationSubscription;
  StreamSubscription? _routeSubscription;

  @override
  void initState() {
    super.initState();
    _trackingService = RealtimeTrackingService();
    _initializeMap();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _routeSubscription?.cancel();
    super.dispose();
  }

  void _initializeMap() {
    // Start tracking bus location
    _locationSubscription =
        _trackingService.getBusLocation(widget.busId).listen((location) {
      if (location.isNotEmpty) {
        _updateBusMarker(location);
      }
    });

    if (widget.showRoute) {
      _routeSubscription =
          _trackingService.getBusRoute(widget.busId).listen((route) {
        _updateRoute(route);
      });
    }
  }

  void _updateBusMarker(Map<String, dynamic> location) {
    final lat = location['latitude'] as double;
    final lng = location['longitude'] as double;
    final speed = location['speed'] as double;
    final heading = location['heading'] as double;

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(widget.busId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: 'Bus ${widget.busId}',
            snippet: 'Speed: ${speed.toStringAsFixed(1)} km/h',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          rotation: heading,
        ),
      );
    });
  }

  void _updateRoute(List<Map<String, dynamic>> route) {
    final List<LatLng> polylineCoordinates = [];

    for (var stop in route) {
      final lat = stop['latitude'] as double;
      final lng = stop['longitude'] as double;
      polylineCoordinates.add(LatLng(lat, lng));

      // Add stop marker
      _markers.add(
        Marker(
          markerId: MarkerId(stop['id']),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: stop['name'],
            snippet: stop['address'],
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId(widget.busId),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 3,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: const CameraPosition(
        target: LatLng(7.785552035561738, 122.5863163838556),
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      trafficEnabled: true,
    );
  }
}
