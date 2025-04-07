import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/generated/l10n.dart';

Future<double> getAverageRating() async {
  final CollectionReference ratings =
      FirebaseFirestore.instance.collection('ratings');
  final QuerySnapshot snapshot = await ratings.get();

  if (snapshot.docs.isNotEmpty) {
    double total = 0;
    for (var doc in snapshot.docs) {
      total += doc['rating'];
    }
    return total / snapshot.docs.length; // ✅ إرجاع المتوسط الصحيح
  }
  return 0.0;
}

void showRatingDialog(BuildContext context, Function updateAverage) {
  double tempRating = 0.0;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(S.of(context).rate_app),
      content: RatingBar.builder(
        minRating: 1,
        itemCount: 5,
        allowHalfRating: true,
        itemBuilder: (context, _) =>
            Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
        onRatingUpdate: (rating) {
          tempRating = rating;
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('ratings')
                .add({'rating': tempRating});
            Navigator.pop(context);

            // ✅ تحديث متوسط التقييم فورًا بعد الإضافة
            double newAverage = await getAverageRating();
            updateAverage(newAverage);
          },
          child: Text(S.of(context).submit),
        ),
      ],
    ),
  );
}
