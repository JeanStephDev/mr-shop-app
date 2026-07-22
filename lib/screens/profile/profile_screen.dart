import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/phone_entry_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Profil', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const CircleAvatar(radius: 24, backgroundColor: AppColors.navy, child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(user?.phone ?? '', style: const TextStyle(color: AppColors.navySoft)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('Mes adresses'), onTap: () {}),
          ListTile(leading: const Icon(Icons.receipt_long_outlined), title: const Text('Historique de commandes'), onTap: () {}),
          ListTile(leading: const Icon(Icons.help_outline), title: const Text('Aide & support'), onTap: () {}),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Se déconnecter', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const PhoneEntryScreen()), (r) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
