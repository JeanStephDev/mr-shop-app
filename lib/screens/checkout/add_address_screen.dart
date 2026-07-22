import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/address_service.dart';
import 'map_picker_screen.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  double? _lat;
  double? _lng;
  bool _isSaving = false;

  Future<void> _pickOnMap() async {
    final result = await Navigator.of(context).push<Map<String, double>>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (result != null) {
      setState(() {
        _lat = result['lat'];
        _lng = result['lng'];
      });
    }
  }

  Future<void> _save() async {
    if (_addressController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await AddressService().addAddress(
        label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
        fullAddress: _addressController.text.trim(),
        lat: _lat,
        lng: _lng,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle adresse')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _labelController, decoration: const InputDecoration(hintText: 'Nom (ex: Maison, Bureau)')),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Adresse complète (quartier, rue, repère...)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickOnMap,
              icon: const Icon(Icons.map_outlined),
              label: Text(_lat == null ? 'Localiser précisément sur la carte' : 'Emplacement enregistré ✅ (modifier)'),
            ),
            if (_lat != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Position : ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}', style: const TextStyle(color: AppColors.navySoft, fontSize: 12)),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
