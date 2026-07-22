import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'otp_screen.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.sendOtp(phone);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => OtpScreen(phone: phone)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Erreur')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bienvenue 👋', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Entrez votre numéro pour continuer', style: TextStyle(color: AppColors.navySoft)),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Ex: 0759000000', prefixText: '+225 '),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Recevoir le code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
