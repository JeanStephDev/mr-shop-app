import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'register_profile_screen.dart';

/// Étape 2 de l'inscription : saisie du code reçu par SMS. La vérification
/// réelle du code se fait côté serveur au moment de l'appel register() final
/// (voir RegisterProfileScreen) — ici on collecte juste le code, sans appel
/// réseau supplémentaire, pour ne pas consommer l'OTP avant que le profil
/// ne soit complet.
class RegisterOtpScreen extends StatefulWidget {
  final String phone;
  const RegisterOtpScreen({super.key, required this.phone});

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final _codeController = TextEditingController();

  void _submit() {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrez le code reçu par SMS')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterProfileScreen(phone: widget.phone, otpCode: code),
    ));
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.sendOtp(widget.phone);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Code renvoyé par SMS' : (auth.error ?? 'Erreur'))),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(hintText: '••••••'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _submit, child: const Text('Continuer')),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(onPressed: _resend, child: const Text('Renvoyer le code')),
            ),
          ],
        ),
      ),
    );
  }
}
