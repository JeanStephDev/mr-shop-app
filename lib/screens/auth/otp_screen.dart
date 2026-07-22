import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../home/main_navigation.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController(); // demandé seulement à la 1ère connexion

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(
      phone: widget.phone,
      code: _codeController.text.trim(),
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainNavigation()), (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Code invalide')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code envoyé', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Un SMS a été envoyé au ${widget.phone}', style: const TextStyle(color: AppColors.navySoft)),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Code à 6 chiffres'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Votre nom (si première connexion)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _submit,
                child: auth.isLoading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Valider'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
