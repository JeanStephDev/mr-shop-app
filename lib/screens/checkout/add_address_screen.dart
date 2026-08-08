import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/city.dart';
import '../../services/address_service.dart';
import 'map_picker_screen.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _addressService = AddressService();
  final _labelController = TextEditingController();
  final _quartierController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneContactController = TextEditingController();

  List<City> _cities = [];
  List<Commune> _communes = [];
  City? _selectedCity;
  Commune? _selectedCommune;
  bool _isLoadingCities = true;
  bool _isLoadingCommunes = false;
  double? _lat;
  double? _lng;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await _addressService.getCities();
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
        if (cities.length == 1) {
          _selectedCity = cities.first;
          _loadCommunes(cities.first.id);
        }
      });
    } catch (_) {
      setState(() => _isLoadingCities = false);
    }
  }

  Future<void> _loadCommunes(int cityId) async {
    setState(() {
      _isLoadingCommunes = true;
      _communes = [];
      _selectedCommune = null;
    });
    try {
      final communes = await _addressService.getCommunes(cityId);
      setState(() {
        _communes = communes;
        _isLoadingCommunes = false;
      });
    } catch (_) {
      setState(() => _isLoadingCommunes = false);
    }
  }

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
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrez une adresse (rue, repère...)')));
      return;
    }
    if (_selectedCommune == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisissez votre commune')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _addressService.addAddress(
        label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
        fullAddress: _addressController.text.trim(),
        cityId: _selectedCity?.id,
        communeId: _selectedCommune?.id,
        quartier: _quartierController.text.trim().isEmpty ? null : _quartierController.text.trim(),
        phoneContact: _phoneContactController.text.trim().isEmpty ? null : _phoneContactController.text.trim(),
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
      body: _isLoadingCities
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: _labelController, decoration: const InputDecoration(hintText: 'Nom (ex: Maison, Bureau)')),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<City>(
                    initialValue: _selectedCity,
                    decoration: const InputDecoration(hintText: 'Ville'),
                    items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (city) {
                      setState(() => _selectedCity = city);
                      if (city != null) _loadCommunes(city.id);
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<Commune>(
                    initialValue: _selectedCommune,
                    decoration: InputDecoration(hintText: _isLoadingCommunes ? 'Chargement...' : 'Commune'),
                    items: _communes.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: _isLoadingCommunes ? null : (commune) => setState(() => _selectedCommune = commune),
                  ),
                  const SizedBox(height: 12),

                  TextField(controller: _quartierController, decoration: const InputDecoration(hintText: 'Quartier (ex: Angré 8e Tranche)')),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'Rue, repère (ex: près de la pharmacie...)'),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _phoneContactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: 'Numéro de contact à cette adresse (optionnel)'),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _pickOnMap,
                    icon: const Icon(Icons.map_outlined),
                    label: Text(_lat == null ? 'Localiser précisément sur la carte' : 'Emplacement enregistré (modifier)'),
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
