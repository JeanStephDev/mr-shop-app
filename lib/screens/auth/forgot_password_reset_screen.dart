import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class ForgotPasswordResetScreen extends StatefulWidget {
  final String phone;
  const ForgotPasswordResetScreen({super.key, required this.phone});

  @override
  State<ForgotPasswordResetScreen> createState() => _ForgotPasswordResetScreenState();
}

class _ForgotPasswordResetScreenState extends State<ForgotPasswordResetScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le mot de passe doit faire au moins 6 caractères')));
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(
      phone: widget.phone,
      otpCode: _codeController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe mis à jour ✅')));
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
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
            Text('Réinitialiser le mot de passe', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Code envoyé au ${widget.phone}', style: const TextStyle(color: AppColors.navySoft)),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(hintText: '••••••'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Nouveau mot de passe'),
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
