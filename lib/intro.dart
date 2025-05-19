import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to Carpool",
          body: "Share rides easily and save money.",
          image: Center(
            child: Image.asset('assets/images/welcome_carpool.png', height: 200),
          ),
        ),
        PageViewModel(
          title: "Book a Ride",
          body: "Quickly find and book your carpool rides.",
          image: Center(
            child: Image.asset('assets/images/book_ride.png', height: 200),
          ),
        ),
        PageViewModel(
          title: "Navigate Safely",
          body: "Get accurate routes and track your rides.",
          image: Center(
            child: Image.asset('assets/images/navigate_route.png', height: 200),
          ),
        ),
      ],
      onDone: () {
        Navigator.of(context).pushReplacementNamed('/mainnav');
      },
      showSkipButton: true,
      skip: Text("Skip"),
      next: Icon(Icons.arrow_forward),
      done: Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: Size(22.0, 10.0),
        activeColor: Colors.blue,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
