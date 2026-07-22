import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/banner_ad_widget.dart';
import '../shop/product_detail_screen.dart';
import '../shop/category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CatalogProvider>().loadHome());
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final user = context.watch<AuthProvider>().user;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<CatalogProvider>().loadHome(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MR SHOP · FRESH SCENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navySoft)),
                    Text('Bonjour, ${user?.name.split(' ').first ?? ''} 👋', style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                const CircleAvatar(backgroundColor: AppColors.navy, child: Icon(Icons.person, color: Colors.white, size: 18)),
              ],
            ),
            const SizedBox(height: 20),

            // Bannière hero (statique pour l'instant — peut être branchée sur /ads/banners)
            Container(
              height: 150,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(colors: [AppColors.navy, Color(0xFF1A5064)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Livraison offerte 🎁', style: TextStyle(color: AppColors.peach, fontWeight: FontWeight.w700, fontSize: 12)),
                  SizedBox(height: 6),
                  Text('Dès votre 3ème commande', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (catalog.categories.isNotEmpty) ...[
              const Text('Catégories', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: catalog.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final category = catalog.categories[i];
                    return ActionChip(
                      backgroundColor: Colors.white,
                      label: Text('${category.icon ?? ''} ${category.name}'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: category)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Text('Best-sellers', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),

            const BannerAdWidget(),

            if (catalog.isLoading)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: catalog.featuredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, i) {
                  final product = catalog.featuredProducts[i];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
