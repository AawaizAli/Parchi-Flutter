import 'package:flutter/material.dart';
import '../widgets/parchi_card.dart';        // Make sure this path matches your project structure
import '../widgets/restaurant_mini_card.dart'; // Make sure this path matches your project structure

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Section 1: Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Search restaurants...",
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section 2: Parchi ID Card (Cleaned up: Logic is now in widgets/parchi_card.dart)
          const SliverToBoxAdapter(
            child: ParchiCard(),
          ),

          // Section 3: Restaurants Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                "All Restaurants",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Section 4: Restaurants Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const RestaurantMiniCard();
                },
                childCount: 12,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}