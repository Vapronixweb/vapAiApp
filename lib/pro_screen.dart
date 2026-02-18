import 'dart:convert';

import 'package:ai_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;

import 'controllers/auth_controller.dart';

class ProAccessScreen extends StatefulWidget {
  const ProAccessScreen({super.key});

  @override
  State<ProAccessScreen> createState() => _ProAccessScreenState();
}

class _ProAccessScreenState extends State<ProAccessScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _loading = true;

  final Set<String> _productIds = {
    'imagineai_creator_monthly',
    'imagineai_pro_monthly',
  };

  @override
  void initState() {
    super.initState();
    _initIAP();

    _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {

          // 🔐 Send to backend for verification
          await sendToServer(purchase);

          await _iap.completePurchase(purchase);
        }
      }
    });
  }

  Future<void> sendToServer(PurchaseDetails purchase) async {

    final auth = AuthController.to;
    final token = auth.accessToken.value;

    await http.post(
      Uri.parse("$apiUrl/purchase/verify"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({
        "product_id": purchase.productID,
        "purchase_token": purchase.verificationData.serverVerificationData,
        "platform": "android"
      }),
    );
  }


  Future<void> _initIAP() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    final response = await _iap.queryProductDetails(_productIds);
    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
  }

  void _buy(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  ProductDetails? _getProduct(String id) {
    return _products.firstWhere(
          (p) => p.id == id,
      orElse: () => throw Exception('Product not found'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final creator = _getProduct('imagineai_creator_monthly');
    final pro = _getProduct('imagineai_pro_monthly');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),

              const Text(
                'Upgrade Your Plan',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              _feature('AI image generation'),
              _feature('Monthly credits'),
              _feature('Better image quality'),

              const SizedBox(height: 24),

              _subscriptionCard(
                title: 'Creator Plan',
                subtitle: '100 credits • Medium quality',
                price: creator!.price,
                highlight: false,
                onTap: () => _buy(creator),
              ),

              const SizedBox(height: 14),

              _subscriptionCard(
                title: 'Pro Plan',
                subtitle: '300 credits • High quality • Priority',
                price: pro!.price,
                highlight: true,
                badge: 'BEST',
                onTap: () => _buy(pro),
              ),

              const Spacer(),

              Center(
                child: TextButton(
                  onPressed: () => _iap.restorePurchases(),
                  child: const Text('Restore Purchases'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _subscriptionCard({
    required String title,
    required String subtitle,
    required String price,
    required bool highlight,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlight ? Colors.blue : Colors.grey.shade300,
            width: highlight ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(badge!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            Text(price,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
