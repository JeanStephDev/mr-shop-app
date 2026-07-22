import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme.dart';

/// Écran de sélection précise de l'adresse : l'utilisateur déplace la carte,
/// un repère fixe reste au centre, et on récupère lat/lng au moment de valider.
/// Renvoie {'lat': double, 'lng': double} via Navigator.pop.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _controller;
  LatLng _center = const LatLng(5.3600, -4.0083); // Abidjan par défaut
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    _locateMe();
  }

  Future<void> _locateMe() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied || requested == LocationPermission.deniedForever) {
          setState(() => _isLocating = false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _isLocating = false;
      });
      _controller?.animateCamera(CameraUpdate.newLatLng(_center));
    } catch (_) {
      setState(() => _isLocating = false); // reste sur Abidjan par défaut si géoloc refusée/indisponible
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir l\'emplacement')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 15),
            onMapCreated: (controller) => _controller = controller,
            onCameraMove: (position) => _center = position.target,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          const Icon(Icons.location_on, size: 44, color: AppColors.orange), // repère fixe au centre
          if (_isLocating) const Positioned(top: 16, child: CircularProgressIndicator()),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop({'lat': _center.latitude, 'lng': _center.longitude}),
              child: const Text('Valider cet emplacement'),
            ),
          ),
        ],
      ),
    );
  }
}
