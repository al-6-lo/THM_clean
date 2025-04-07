import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/generated/l10n.dart';

Widget buildRichText(BuildContext context, String title, String value) {
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: "$title : ",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        TextSpan(
          text: value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    ),
  );
}

class PreviousPatientsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).pre_patients,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('previous_patients')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ أثناء تحميل البيانات"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(S.of(context).no_pre_patients,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    )));
          } else {
            var patients = snapshot.data!.docs;

            return ListView.builder(
              itemCount: patients.length,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemBuilder: (context, index) {
                var patientData =
                    patients[index].data() as Map<String, dynamic>?;

                if (patientData == null) {
                  return ListTile(
                    title: Text("بيانات غير متوفرة"),
                  );
                }

                // استخراج البيانات مع التأكد من عدم وجود قيم `null`
                String bedName = patientData['bedName'] ?? "غير معروف";
                String bedNumber = patientData['bedNumber'] ?? "غير متوفر";
                String phoneNumber = patientData['phoneNumber'] ?? "غير متوفر";
                String doctorName = patientData['doctorName'] ?? "غير معروف";
                String gender = patientData['gender'] ?? "غير محدد";
                String patientId = patientData.containsKey('patientId')
                    ? patientData['patientId'].toString()
                    : "غير متوفر";

                String deletedAtText = "تاريخ غير متوفر";
                if (patientData.containsKey('deletedAt') &&
                    patientData['deletedAt'] != null) {
                  Timestamp timestamp = patientData['deletedAt'] as Timestamp;
                  DateTime date = timestamp.toDate();
                  deletedAtText =
                      "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}";
                }

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildRichText(
                            context, S.of(context).patientId, patientId),
                        buildRichText(context, S.of(context).name, bedName),
                        buildRichText(
                            context, S.of(context).bed_number, bedNumber),
                        buildRichText(context, S.of(context).gender, gender),
                        buildRichText(
                            context, S.of(context).phone_number, phoneNumber),
                        buildRichText(
                            context, S.of(context).doctor_name, doctorName),
                        Divider(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "${S.of(context).deleted_at}: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: deletedAtText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
