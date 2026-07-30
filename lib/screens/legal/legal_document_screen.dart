import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum LegalDocumentType { terms, privacy, mentions, delivery }

/// Affiche les vraies pages légales du site (déjà rédigées et tenues à jour
/// côté Laravel) dans une WebView — pas de duplication de contenu à
/// maintenir à deux endroits différents.
class LegalDocumentScreen extends StatelessWidget {
  final LegalDocumentType type;
  const LegalDocumentScreen({super.key, required this.type});

  String get _path => switch (type) {
        LegalDocumentType.terms => '/cgu-cgv',
        LegalDocumentType.privacy => '/politique-de-confidentialite',
        LegalDocumentType.mentions => '/mentions-legales',
        LegalDocumentType.delivery => '/politique-de-livraison-remboursement',
      };

  String get _title => switch (type) {
        LegalDocumentType.terms => 'Conditions d\'utilisation',
        LegalDocumentType.privacy => 'Politique de confidentialité',
        LegalDocumentType.mentions => 'Mentions légales',
        LegalDocumentType.delivery => 'Livraison & remboursement',
      };

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.hexa-node.site$_path'));

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: WebViewWidget(controller: controller),
    );
  }
}
