import 'package:flutter/material.dart';
import 'package:t_h_m/Screens/vital_signs/vital_signs_screen.dart';
import 'package:t_h_m/generated/l10n.dart';

class BedItem extends StatelessWidget {
  final String docId;
  final String bedNumber;
  final String bedName;
  final int age;
  final String gender;
  final String phoneNumber;
  final String doctorName;
  final String userRole;

  const BedItem({
    Key? key,
    required this.docId,
    required this.bedNumber,
    required this.bedName,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.doctorName,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VitalSignsScreen(
              docId: docId,
              bedNumber: bedNumber,
              bedName: bedName,
              age: age,
              gender: gender,
              phoneNumber: phoneNumber,
              doctorName: doctorName,
              userRole: userRole,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${S.of(context).bed} $bedNumber",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onBackground),
          ],
        ),
      ),
    );
  }
}
