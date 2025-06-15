import 'package:carpooling/main.dart';
import 'package:carpooling/themes/light_theme.dart';
import 'package:carpooling/views/admin/analytics_page.dart';
import 'package:carpooling/views/admin/reports_page.dart';
import 'package:carpooling/views/admin/reviews_page.dart';
import 'package:carpooling/views/admin/rides_page.dart';
import 'package:carpooling/views/admin/users/users_page.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_AdminTileData> adminTiles = [
      _AdminTileData(title: "Users", icon: Icons.person, onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (_) => UsersPage()));
      }),
      _AdminTileData(title: "Rides", icon: Icons.directions_car, onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (_) => RidesPage()));
      }),
      _AdminTileData(title: "Reports", icon: Icons.report, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsPage()));
      }),
      _AdminTileData(title: "Reviews", icon: Icons.star, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewsPage()));
      }),
      _AdminTileData(title: "Analytics", icon: Icons.bar_chart, onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsPage()));
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: adminTiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final tile = adminTiles[index];
            return GestureDetector(
              onTap: tile.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: themeNotifier.value == ThemeMode.light ? Colors.white : Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tile.icon, size: 40, color: Colors.blue),
                    const SizedBox(height: 10),
                    Text(
                      tile.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdminTileData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _AdminTileData({required this.title, required this.icon, required this.onTap});
}
  