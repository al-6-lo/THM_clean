import 'package:flutter/material.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/Screens/add_beds/add_beds_screen.dart';

Future<void> PatientChoiceScreen(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  String selectedPatientType = 'all'; // القيمة الافتراضية
  String doctorName = '';

  // 🔹 جلب بيانات المستخدم
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  if (userDoc.exists && userDoc.data() != null) {
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    selectedPatientType = userData['selectedOption'] ?? 'all';
    doctorName = userData['doctorName'] ?? ''; // ✅ جلب اسم الدكتور
  }

  // ✅ **دالة لحفظ الخيار في Firebase**
  Future<void> saveUserFilterOption(String filterOption) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'selectedOption': filterOption,
      });
    } catch (e) {
      print("Error saving filter option: $e");
    }
  }

  // 📌 **فتح Dialog لاختيار المرضى**
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(S.of(context).choice_patients),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // خيار "كل المرضى"
                RadioListTile<String>(
                  title: Text(S.of(context).all_patients),
                  value: 'all',
                  groupValue: selectedPatientType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPatientType = value);
                      saveUserFilterOption(value);
                      Navigator.pop(context); // إغلاق الـ Dialog

                      // ✅ الانتقال إلى AddBedsScreen بدون اسم الطبيب
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBedsScreen(),
                        ),
                      );
                    }
                  },
                ),
                // خيار "مرضاي فقط"
                RadioListTile<String>(
                  title: Text(S.of(context).my_patients),
                  value: 'myPatients',
                  groupValue: selectedPatientType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPatientType = value);
                      saveUserFilterOption(value);
                      Navigator.pop(context); // إغلاق الـ Dialog

                      // ✅ الانتقال إلى AddBedsScreen مع تمرير اسم الطبيب
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddBedsScreen(doctorName: doctorName),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).close),
              ),
            ],
          );
        },
      );
    },
  );
}
