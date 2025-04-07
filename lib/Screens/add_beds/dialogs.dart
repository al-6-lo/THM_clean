import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:flutter/services.dart';

// نافدة منبثقة للنجاح
class Dialogs {
  static void showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 🔹 لا يمكن إغلاقه إلا بعد انتهاء الأنيميشن
      builder: (BuildContext dialogContext) {
        // 🔹 بعد 2 ثانية، يتم إغلاق الأنيميشن تلقائيًا
        Future.delayed(Duration(seconds: 2), () {
          if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
            Navigator.of(dialogContext).pop();
          }
        });

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
                child: Lottie.asset(
                    'assets/animations/success.json'), // تأكد من وضع الملف داخل مجلد assets
              ),
              SizedBox(height: 10),
              Text(
                S.of(context).added_successfully,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // النص المترجم
              ),
            ],
          ),
        );
      },
    );
  }

// دالة عرض رسالة تأكيد الخروج
  static Future<bool> showExitDialog(BuildContext context) async {
    // 🔹 أزل `_`
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
            title: Text(
              S.of(context).exit_app,
              style: TextStyle(fontSize: 17),
            ),
            content: Text(
              S.of(context).confirm_exit,
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // البقاء في التطبيق
                child: Text(S.of(context).no,
                    style: TextStyle(color: AppColors.primaryColor)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst); // الخروج من التطبيق
                  SystemNavigator.pop();
                },
                child: Text(S.of(context).yes,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
        ) ??
        false; // القيمة الافتراضية إذا تم إغلاق النافذة بدون اختيار
  }
}
