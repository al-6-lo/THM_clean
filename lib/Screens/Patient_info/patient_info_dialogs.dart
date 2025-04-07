import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/Screens/add_beds/add_beds_screen.dart';

extension PatientInfoDialogs on State {
  //  دالة عرض التنبيه إذا كان رقم السرير مكررًا
  void showDuplicateBedNumberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text(
          S.of(context).bed_exists,
          style: TextStyle(
              color: Theme.of(context).colorScheme.error, fontSize: 18),
        ),
        content: Text(
          S.of(context).enter_another_number,
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).ok,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  //  دالة تأكيد الحذف
  void showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/warning.json', // مسار الأنيميشن
                width: 75,
                height: 75,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).confirm_deleted_bed,
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // إغلاق النافذة
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                deletePatient(docId); // استدعاء دالة الحذف
                Navigator.of(context).pop(); // إغلاق النافذة بعد الحذف
              },
              child: Text(
                S.of(context).delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  //  دالة حذف المريض
  void deletePatient(String docId) async {
    try {
      DocumentSnapshot patientDoc =
          await FirebaseFirestore.instance.collection('beds').doc(docId).get();

      if (patientDoc.exists) {
        Map<String, dynamic> patientData =
            patientDoc.data() as Map<String, dynamic>;
        patientData['deletedAt'] = FieldValue.serverTimestamp(); // تاريخ الحذف

        await FirebaseFirestore.instance
            .collection('previous_patients')
            .doc(docId)
            .set(patientData);

        //  حذف المستند من `beds` بعد النسخ
        await FirebaseFirestore.instance.collection('beds').doc(docId).delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("تم نقل المريض إلى الأرشيف!")),
          );

          //  العودة للصفحة الرئيسية
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AddBedsScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        print(" لم يتم العثور على بيانات المريض!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("المريض غير موجود!")),
        );
      }
    } catch (error) {
      print(' فشل في حذف المريض: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل في نقل المريض إلى الأرشيف!")),
        );
      }
    }
  }
}
