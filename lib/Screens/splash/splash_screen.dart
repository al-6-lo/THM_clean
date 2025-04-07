// import 'package:flutter/material.dart';
// import 'package:t_h_m/Constants/colors.dart';
// import 'package:t_h_m/Screens/welcome/welcome_screen.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

//     _controller.forward();
//     _navigateToWelcome();
//   }

//   _navigateToWelcome() async {
//     await Future.delayed(Duration(seconds: 2), () {}); // الانتظار 3 ثواني
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => WelcomeScreen()),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryColor,
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Center(
//           child: Image.asset(
//             'assets/images/logo.png',
//             height: 350,
//             width: 350,
//           ),
//           // الشعار
//         ),
//       ),
//     );
//   }
// }
