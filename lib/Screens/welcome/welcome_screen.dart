// import 'package:flutter/material.dart';
// import 'package:t_h_m/Constants/colors.dart';
// import 'package:t_h_m/Screens/add_beds/add_beds_screen.dart';
// import 'package:lottie/lottie.dart';

// class WelcomeScreen extends StatefulWidget {
//   @override
//   _WelcomeScreenState createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen> {
//   PageController _pageController = PageController();
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//   }

//   void _onPageChanged(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'THM Information',
//           style: TextStyle(color: AppColors.backgroundColor, fontSize: 24),
//         ),
//         backgroundColor: AppColors.primaryColor,
//       ),
//       body: Container(
//         color: AppColors.primaryColor,
//         child: Column(
//           children: [
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 onPageChanged: _onPageChanged,
//                 children: [
//                   _buildPage('Welcome To', ' Tele Health Monitoring',
//                       'assets/animations/medical.json'),
//                   _buildPage(
//                       'Tele Health Monitoring',
//                       'An application monitors vital signs such as ECG, temperature, and more.',
//                       'assets/animations/vital_signs.json'),
//                   _buildPage(
//                       'How It Works',
//                       'The app connects to a device that measures vital signs and transfers them to it for remote patient monitoring.',
//                       'assets/animations/app.json'),
//                   _buildPage(
//                       'Get Started',
//                       'Press the button below to start using the app...',
//                       'assets/images/start.png'),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             if (_currentIndex == 3)
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => AddBedsScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.backgroundColor),
//                 child:
//                     Text('Start', style: TextStyle(color: AppColors.textColor)),
//               ),
//             SizedBox(height: 20),
//             _buildIndicator(),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPage(String title, String content, String assetPath) {
//     bool isLottie = assetPath.endsWith('.json');

//     return Container(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           isLottie
//               ? Lottie.asset(assetPath, width: 300, height: 300)
//               : Image.asset(assetPath, width: 350, height: 350),
//           SizedBox(height: 20),
//           Text(
//             title,
//             style: TextStyle(
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textColor),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 20),
//           Text(
//             content,
//             style: TextStyle(fontSize: 18, color: AppColors.backgroundColor),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _indicator(0),
//         SizedBox(width: 8),
//         _indicator(1),
//         SizedBox(width: 8),
//         _indicator(2),
//         SizedBox(width: 8),
//         _indicator(3),
//       ],
//     );
//   }

//   Widget _indicator(int index) {
//     return Container(
//       width: 8,
//       height: 8,
//       decoration: BoxDecoration(
//         color: _currentIndex == index
//             ? AppColors.secondaryColor
//             : AppColors.backgroundColor,
//         shape: BoxShape.circle,
//       ),
//     );
//   }
// }
