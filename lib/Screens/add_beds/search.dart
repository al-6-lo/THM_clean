// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SearchPage extends StatefulWidget {
//   @override
//   _SearchPageState createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   TextEditingController _searchController = TextEditingController();
//   String searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           controller: _searchController,
//           autofocus: true,
//           decoration: InputDecoration(
//             hintText: "Search patient...",
//             border: InputBorder.none,
//             hintStyle:
//                 TextStyle(color: Theme.of(context).colorScheme.onPrimary),
//           ),
//           style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
//           onChanged: (value) {
//             setState(() {
//               searchQuery = value.toLowerCase();
//             });
//           },
//         ),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         iconTheme: IconThemeData(
//           color: Theme.of(context).colorScheme.onPrimary,
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.close,
//                 color: Theme.of(context).colorScheme.onPrimary),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('beds').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           var beds = snapshot.data!.docs;

//           // 🔥 فلترة البيانات بناءً على البحث
//           var filteredBeds = beds.where((bed) {
//             var patientName = bed['bedName'].toString().toLowerCase();
//             return searchQuery.isEmpty || patientName.contains(searchQuery);
//           }).toList();

//           if (filteredBeds.isEmpty) {
//             return Center(child: Text('No matching beds found.'));
//           }

//           return ListView.builder(
//             itemCount: filteredBeds.length,
//             itemBuilder: (context, index) {
//               var bed = filteredBeds[index];
//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 child: Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Bed Number: ${bed['bedNumber']}',
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
