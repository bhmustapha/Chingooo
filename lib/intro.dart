import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnBoardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to Chingoo",
          body: "Share rides easily and save money.",
          image: Center(
            child: SvgPicture.asset('assets/images/Carpool.svg', height: 200),
          ),
        ),
        PageViewModel(
          title: "Book a Ride",
          body: "Quickly find and book your carpool rides.",
          image: Center(
            child: SvgPicture.asset('assets/images/Order_ride.svg', height: 200),
          ),
        ),
        PageViewModel(
          title: "Navigate Safely",
          body: "Get accurate routes and track your rides.",
          image: Center(
            child: SvgPicture.asset('assets/images/Navigation.svg', height: 200),
          ),
        ),
      ],
      onDone: () {
        Navigator.of(context).pushReplacementNamed('/auth');
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
