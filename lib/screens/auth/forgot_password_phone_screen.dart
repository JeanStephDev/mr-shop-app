import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'forgot_password_reset_screen.dart';

class ForgotPasswordPhoneScreen extends StatefulWidget {
  const ForgotPasswordPhoneScreen({super.key});

  @override
  State<ForgotPasswordPhoneScreen> createState() => _ForgotPasswordPhoneScreenState();
}

class _ForgotPasswordPhoneScreenState extends State<ForgotPasswordPhoneScreen> {
  final _phoneController = TextEditingController();

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordResetOtp(phone);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ForgotPasswordResetScreen(phone: phone)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Numéro introuvable')));
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
            Text('Mot de passe oublié', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Entrez le numéro associé à votre compte', style: TextStyle(color: AppColors.navySoft)),
            const SizedBox(height: 24),
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
    );
  }
}
