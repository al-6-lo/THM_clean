import 'package:flutter/material.dart';
import 'custom_input_decoration.dart';

Widget buildTextField({
  required String label,
  required TextEditingController controller,
  required TextInputType keyboardType,
  required String? Function(String?)? validator,
  String? prefixText, // 🔹 إضافة `prefixText` كمعامل اختياري
  required BuildContext context, // تمرير `context` لتنسيق الحقول
}) {
  return TextFormField(
    decoration: customInputDecoration(label, context).copyWith(
      prefixText: prefixText, // 🔹 إضافة `prefixText` هنا
      prefixStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 16.0,
      ),
    ),
    keyboardType: keyboardType,
    cursorColor: Theme.of(context).colorScheme.primary,
    style: TextStyle(
      color: Theme.of(context).textTheme.bodyMedium?.color,
      fontSize: 16.0,
    ),
    validator: validator,
    controller: controller,
  );
}

TextEditingController bedNumberController = TextEditingController();
TextEditingController bedNameController = TextEditingController();
TextEditingController ageController = TextEditingController();
TextEditingController phoneNumberController = TextEditingController();
TextEditingController doctorNameController = TextEditingController();
