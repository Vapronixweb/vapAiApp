import 'dart:ui';
import 'package:flutter/material.dart';

class ProAccessScreen extends StatelessWidget {
  const ProAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/pro_bg.jpg',
          //     fit: BoxFit.cover,
          //   ),
          // ),

          // Dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  const Text(
                    'Get Pro Access',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _feature('Generate Videos With Your Words'),
                  _feature('Have Fun With Video Templates'),
                  _feature('Transform Yourself Into Fav Characters'),
                  _feature('Claim Your 1000 Coin Pack'),

                  const SizedBox(height: 28),

                  // Yearly Access
                  _subscriptionCard(
                    title: 'YEARLY ACCESS',
                    subtitle: 'Just ₹ 3,999 per year',
                    price: '₹76.90',
                    priceNote: 'per week',
                    highlight: true,
                    badge: '85% OFF',
                  ),

                  const SizedBox(height: 14),

                  // Weekly Access
                  _subscriptionCard(
                    title: 'WEEKLY ACCESS',
                    subtitle: 'Cancel anytime',
                    price: '₹499.00',
                    priceNote: 'per week',
                    highlight: false,
                  ),

                  const Spacer(),

                  const Center(
                    child: Text(
                      'No commitment - cancel anytime',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CTA Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2AFADF), Color(0xFF4C83FF)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Try it now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer links
                  const Center(
                    child: Text(
                      'Terms of Use  •  Privacy Policy  •  Restore',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.cyanAccent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subscriptionCard({
    required String title,
    required String subtitle,
    required String price,
    required String priceNote,
    required bool highlight,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? Colors.cyanAccent : Colors.white24,
          width: highlight ? 2 : 1,
        ),
        color: Colors.black.withOpacity(0.4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                priceNote,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }
}
