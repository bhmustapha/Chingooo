import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int totalUsers = 0;
  int totalRides = 0;
  int totalRequests = 0;
  int totalBookings = 0;
  int totalReports = 0;
  int totalConversations = 0;
  double averageRating = 0;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    final rides = await FirebaseFirestore.instance.collection('rides').get();
    final rideRequests = await FirebaseFirestore.instance.collection('ride_requests').get();
    final bookings = await FirebaseFirestore.instance.collection('bookings').get();
    final reports = await FirebaseFirestore.instance.collection('reports').get();
    final conversations = await FirebaseFirestore.instance.collection('conversations').get();
    final ratingsSnapshot = await FirebaseFirestore.instance.collection('ratings').get();

    double totalRating = 0;
    for (var doc in ratingsSnapshot.docs) {
      final rating = doc['rating']?.toDouble() ?? 0;
      totalRating += rating;
    }

    setState(() {
      totalUsers = users.size;
      totalRides = rides.size;
      totalRequests = rideRequests.size;
      totalBookings = bookings.size;
      totalReports = reports.size;
      totalConversations = conversations.size;
      averageRating = ratingsSnapshot.size > 0 ? totalRating / ratingsSnapshot.size : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow([
              _buildStatCard('Users', totalUsers.toString(), Icons.people),
              _buildStatCard('Rides', totalRides.toString(), Icons.local_taxi),
            ]),
            _buildStatRow([
              _buildStatCard('Requests', totalRequests.toString(), Icons.swap_calls),
              _buildStatCard('Bookings', totalBookings.toString(), Icons.event),
            ]),
            _buildStatRow([
              _buildStatCard('Reports', totalReports.toString(), Icons.report),
              _buildStatCard('Chats', totalConversations.toString(), Icons.chat),
            ]),
            _buildStatRow([
              _buildStatCard('Avg. Rating', averageRating.toStringAsFixed(2), Icons.star),
            ]),
            const SizedBox(height: 32),

            const Text('Sample Rides Activity (Demo)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 200, child: _RidesLineChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(List<Widget> cards) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: cards.map((card) => Expanded(child: card)).toList(),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

// Optional: Demo Line Chart (replace later with real-time chart)
class _RidesLineChart extends StatelessWidget {
  const _RidesLineChart();

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return Text(days[value.toInt() % 7]);
            },
          )),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 5),
              FlSpot(1, 7),
              FlSpot(2, 6),
              FlSpot(3, 9),
              FlSpot(4, 11),
              FlSpot(5, 4),
              FlSpot(6, 8),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          )
        ],
      ),
    );
  }
}
