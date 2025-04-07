import 'package:flutter/material.dart';
import 'package:t_h_m/Constants/colors.dart';

// تصميم الحقول مع تأثير التركيز

InputDecoration customInputDecoration(String label, BuildContext context) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1),
    ),
  );
}

// ويدجت buildTextField
