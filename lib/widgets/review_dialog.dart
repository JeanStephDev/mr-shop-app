import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/order_service.dart';

/// Boîte de dialogue de notation, affichée automatiquement (ou via bouton)
/// une fois la commande livrée. Correspond à POST /orders/{id}/review côté API.
Future<bool?> showReviewDialog(BuildContext context, int orderId) {
  int rating = 5;
  final commentController = TextEditingController();
  bool isSaving = false;

  return showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Comment s\'est passée votre commande ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  icon: Icon(star <= rating ? Icons.star : Icons.star_border, color: AppColors.yellow, size: 32),
                  onPressed: () => setState(() => rating = star),
                );
              }),
            ),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Un commentaire (optionnel)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Plus tard')),
          ElevatedButton(
            onPressed: isSaving
                ? null
                : () async {
                    setState(() => isSaving = true);
                    try {
                      await OrderService().submitReview(orderId, rating: rating, comment: commentController.text.trim());
                      if (context.mounted) Navigator.of(context).pop(true);
                    } catch (e) {
                      setState(() => isSaving = false);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
            child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Envoyer'),
          ),
        ],
      ),
    ),
  );
}
