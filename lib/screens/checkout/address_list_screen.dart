import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/address.dart';
import '../../services/address_service.dart';
import 'add_address_screen.dart';
import 'payment_method_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final _addressService = AddressService();
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _addresses = await _addressService.getAddresses();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adresse de livraison')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ..._addresses.map((address) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: AppColors.orange),
                        title: Text(address.label ?? 'Adresse'),
                        subtitle: Text(address.fullAddress),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PaymentMethodScreen(address: address)),
                        ),
                      ),
                    )),
                OutlinedButton.icon(
                  onPressed: () async {
                    final added = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const AddAddressScreen()));
                    if (added == true) _load();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une nouvelle adresse'),
                ),
              ],
            ),
    );
  }
}
