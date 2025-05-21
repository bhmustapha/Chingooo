import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({Key? key}) : super(key: key);

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Return Button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                const SizedBox(height: 24),
                const Text(
                  "About Sarii",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "Version 1.0.0",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Sarii helps users find and offer carpool rides easily and safely. "
                  "Connect with nearby riders and drivers to save money and reduce your carbon footprint.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Developers",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text("BABAHACENE Mustapha"),
                const Text("mustaphababahacene56@gmail.com"),
                const SizedBox(height: 12),
                const Text("BENSEBANE Abdellah"),
                const Text("abdellah@gmail.com"),
                const SizedBox(height: 24),
                const Text(
                  "Legal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL("https://example.com/privacy"),
                  child: const Text(
                    "Privacy Policy",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _launchURL("https://example.com/terms"),
                  child: const Text(
                    "Terms of Service",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: () => _launchURL(
                      "https://play.google.com/store/apps/details?id=mycarpool.app",
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Rate This App",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
