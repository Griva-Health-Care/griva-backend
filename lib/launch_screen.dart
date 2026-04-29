import 'package:flutter/material.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  static const double _logoWidthRatio = 1.0;
  static const double _logoHeightRatio = 0.9;
  static const String _gifAssetPath = 'assets/images/launch_gif.gif';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          _gifAssetPath,
          width: MediaQuery.of(context).size.width * _logoWidthRatio,
          height: MediaQuery.of(context).size.height * _logoHeightRatio,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
