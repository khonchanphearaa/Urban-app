import 'package:flutter/material.dart';

class SeasonalSaleBanner extends StatelessWidget {
  const SeasonalSaleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=800'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.2), // Light overlay for text contrast
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "SUMMER 24",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Seasonal Sale",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Up to 50% Off Selected Items",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {},
                    child: const Text("Shop Now", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}