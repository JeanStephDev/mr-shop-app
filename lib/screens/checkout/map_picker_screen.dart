import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';

/// Écran de sélection précise de l'adresse : l'utilisateur déplace la carte,
/// un repère fixe reste au centre, et on récupère lat/lng au moment de valider.
/// Renvoie {'lat': double, 'lng': double} via Navigator.pop.
///
/// Centrage sur la position actuelle : on s'appuie sur le bouton natif
/// "ma position" de Google Maps (myLocationButtonEnabled) plutôt que sur un
/// plugin de géolocalisation séparé — évite un bug Gradle connu et encore
/// non résolu du plugin geolocator_android (voir Baseflow/flutter-geolocator#1710)
/// qui empêche le build release. On ne fait ici que demander la permission
/// de localisation ; Google Maps SDK gère lui-même la récupération de la position.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const LatLng _abidjanCenter = LatLng(5.3600, -4.0083);
  LatLng _center = _abidjanCenter;
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (mounted) {
      setState(() => _locationEnabled = status.isGranted);
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
            initialCameraPosition: const CameraPosition(target: _abidjanCenter, zoom: 13),
            onCameraMove: (position) => _center = position.target,
            myLocationEnabled: _locationEnabled,
            myLocationButtonEnabled: _locationEnabled,
          ),
          const Icon(Icons.location_on, size: 44, color: AppColors.orange), // repère fixe au centre
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
