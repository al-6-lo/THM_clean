import 'package:flutter/material.dart';
import 'package:t_h_m/generated/l10n.dart';

class PatientInfoWidgets {
  //  دالة إنشاء حقل إدخال (TextField) مع استعادة القيمة تلقائيًا
  static Widget buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
    required bool enabled,
    required String originalValue,
    String? Function(String?)? validator, // ✅ أضف هذا المعامل
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus && controller.text.trim().isEmpty) {
            controller.text = originalValue; //  استعادة القيمة الأصلية تلقائيًا
          }
        },
        child: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          enabled: enabled,
          cursorColor: Theme.of(context).colorScheme.primary,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          style: TextStyle(
              color: enabled
                  ? Theme.of(context).textTheme.bodyMedium?.color
                  : Theme.of(context).textTheme.bodyMedium?.color),
        ),
      ),
    );
  }

  //  دالة إنشاء محدد الجنس (Gender Selector)
  static Widget buildGenderSelector({
    required BuildContext context,
    required bool enabled,
    required String selectedGender,
    required Function(String) onGenderSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).gender,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.primary),
          ),
          Row(
            children: [
              Radio<String>(
                value: S.of(context).male,
                groupValue: selectedGender,
                onChanged: enabled ? (value) => onGenderSelected(value!) : null,
                activeColor: Theme.of(context).colorScheme.primary,
                fillColor: MaterialStateProperty.resolveWith((states) => enabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey),
              ),
              Text(
                S.of(context).male,
                style: TextStyle(
                    color: enabled
                        ? Theme.of(context).textTheme.bodyMedium?.color
                        : Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(width: 10),
              Radio<String>(
                value: S.of(context).female,
                groupValue: selectedGender,
                onChanged: enabled ? (value) => onGenderSelected(value!) : null,
                activeColor: Theme.of(context).colorScheme.primary,
                fillColor: MaterialStateProperty.resolveWith((states) => enabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey),
              ),
              Text(
                S.of(context).female,
                style: TextStyle(
                    color: enabled
                        ? Theme.of(context).textTheme.bodyMedium?.color
                        : Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
