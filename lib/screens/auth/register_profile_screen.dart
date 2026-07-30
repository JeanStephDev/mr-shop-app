import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../home/main_navigation.dart';
import '../legal/legal_document_screen.dart';

class RegisterProfileScreen extends StatefulWidget {
  final String phone;
  final String otpCode;
  const RegisterProfileScreen({super.key, required this.phone, required this.otpCode});

  @override
  State<RegisterProfileScreen> createState() => _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends State<RegisterProfileScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _termsAccepted = false;

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrez votre nom')));
      return;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le mot de passe doit faire au moins 6 caractères')));
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les mots de passe ne correspondent pas')));
      return;
    }
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous devez accepter les conditions d\'utilisation')));
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text.trim(),
      phone: widget.phone,
      otpCode: widget.otpCode,
      password: _passwordController.text,
      termsAccepted: _termsAccepted,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainNavigation()), (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Erreur')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Complétez votre profil', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              const Text('Code vérifié avec succès ✅', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Nom complet')),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirmController,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(hintText: 'Confirmer le mot de passe'),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                    activeColor: AppColors.orange,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        children: [
                          const Text('J\'accepte les ', style: TextStyle(fontSize: 13, color: AppColors.navySoft)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const LegalDocumentScreen(type: LegalDocumentType.terms),
                            )),
                            child: const Text('conditions d\'utilisation', style: TextStyle(fontSize: 13, color: AppColors.orange, fontWeight: FontWeight.w600)),
                          ),
                          const Text(' et la ', style: TextStyle(fontSize: 13, color: AppColors.navySoft)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const LegalDocumentScreen(type: LegalDocumentType.privacy),
                            )),
                            child: const Text('politique de confidentialité', style: TextStyle(fontSize: 13, color: AppColors.orange, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Créer mon compte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
