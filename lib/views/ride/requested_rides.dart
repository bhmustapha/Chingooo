import 'package:flutter/material.dart';

class RequestedRidesPage extends StatelessWidget {
  const RequestedRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> requestedRides = [
      {
        'publisher': 'John Doe',
        'pickup': 'Maraval',
        'dropoff': 'Ain Turk',
        'date': '2025-05-23',
        'time': '14:30',
        'status': 'Pending',
      },
      {
        'publisher': 'Alice Smith',
        'pickup': 'Université Belgaid',
        'dropoff': 'La gare',
        'date': '2025-05-24',
        'time': '09:00',
        'status': 'Confirmed',
      },
      {
        'publisher': 'Carlos Vega',
        'pickup': 'Akid lotfi',
        'dropoff': 'Gambetta',
        'date': '2025-05-25',
        'time': '08:15',
        'status': 'Rejected',
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Requested Rides',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Ride List
              Expanded(
                child: ListView.separated(
                  itemCount: requestedRides.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ride = requestedRides[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Publisher
                          Text(
                            'Published by ${ride['publisher']}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          // Route
                          Text(
                            '${ride['pickup']} → ${ride['dropoff']}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          const SizedBox(height: 8),
                          Text('Date: ${ride['date']}'),
                          Text('Time: ${ride['time']}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Status: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                ride['status']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(ride['status']),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Buttons: Take Ride + Message Publisher
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement take ride logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text("Take this Ride"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  // TODO: Implement message publisher logic
                                  // e.g., Navigate to a chat page with ride['publisher']
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                                  foregroundColor: Colors.blue,
                                  side: const BorderSide(color: Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text("Message Publisher"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color? _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return null;
    }
  }
}
