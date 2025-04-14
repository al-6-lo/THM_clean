import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportScreen extends StatelessWidget {
  final String patientId;
  final String bedName;

  const ReportScreen({required this.patientId, required this.bedName});

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) return;
    throw Exception("Permission denied to access storage");
  }

  Future<void> generateAndSavePDF(
    BuildContext context,
    DocumentSnapshot data,
    List<QueryDocumentSnapshot> records,
  ) async {
    await _requestPermissions();
    final pdf = pw.Document();

    // Get current date
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    pdf.addPage(pw.Page(
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Report Title at the top
            pw.Center(
              child: pw.Text(
                "PATIENT VITAL SIGNS REPORT",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            pw.SizedBox(height: 70),

            // Name & Date
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(" Name: ${data['bedName']}",
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text("Date: $formattedDate",
                    style: pw.TextStyle(fontSize: 14)),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.Divider(),

            // Other Patient Info in a table
            pw.Table(
              columnWidths: {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(5),
              },
              children: [
                pw.TableRow(children: [
                  pw.Text("Patient ID", style: pw.TextStyle(fontSize: 13)),
                  pw.Text("${data['patientId']}",
                      style: pw.TextStyle(fontSize: 13)),
                ]),
                pw.TableRow(children: [
                  pw.Text("Age", style: pw.TextStyle(fontSize: 13)),
                  pw.Text("${data['age']}", style: pw.TextStyle(fontSize: 13)),
                ]),
                pw.TableRow(children: [
                  pw.Text("Gender", style: pw.TextStyle(fontSize: 13)),
                  pw.Text("${data['gender']}",
                      style: pw.TextStyle(fontSize: 13)),
                ]),
                pw.TableRow(children: [
                  pw.Text("Phone Number", style: pw.TextStyle(fontSize: 13)),
                  pw.Text("${data['phoneNumber']}",
                      style: pw.TextStyle(fontSize: 13)),
                ]),
                pw.TableRow(children: [
                  pw.Text("Bed Number", style: pw.TextStyle(fontSize: 13)),
                  pw.Text("${data['bedNumber']}",
                      style: pw.TextStyle(fontSize: 13)),
                ]),
              ],
            ),

            pw.SizedBox(height: 24),
            pw.Text("Recent Vital Signs:",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),

            // Table of Vital Signs
            pw.Table.fromTextArray(
              headers: const [
                'Timestamp',
                'Heart Rate',
                'Temperature',
                'SpO2',
                'Blood Pressure',
                'Glucose'
              ],
              data: records.map((record) {
                final timestamp = record['timestamp'];

                // التأكد من أن timestamp ليس null وأنه من نوع Timestamp
                final time = (timestamp != null && timestamp is Timestamp)
                    ? timestamp.toDate()
                    : null;

                // إذا كانت القيمة time موجودة، نقوم بتنسيق التاريخ، وإذا لم تكن موجودة نتركها فارغة
                final formattedTime = time != null
                    ? "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} "
                        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
                    : "";

                return [
                  formattedTime, // إما التاريخ أو فارغ إذا لم يوجد
                  "${record['heart_rate']} BPM",
                  "${record['temperature']} °C",
                  "${record['spo2']} %",
                  "${record['blood_pressure']} mmHg",
                  "${record['glucose']} mg/dL",
                ];
              }).toList(),
              cellStyle: pw.TextStyle(fontSize: 11),
              headerStyle: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
              border: pw.TableBorder.all(width: 0.5),
              cellAlignment: pw.Alignment.center,
            ),

            pw.SizedBox(height: 24),

            // Doctor Name and Signature
            pw.Text("Doctor Name: ${data['doctorName']}",
                style: pw.TextStyle(fontSize: 13)),
            pw.SizedBox(height: 8),
            pw.Text("Signature: __________________________",
                style: pw.TextStyle(fontSize: 13)),
          ],
        );
      },
    ));

    final outputDir = await getExternalStorageDirectory();
    final downloadsDir = Directory('${outputDir!.path}/Download');
    if (!await downloadsDir.exists())
      await downloadsDir.create(recursive: true);

    final outputFile = File(
      '${downloadsDir.path}/patient_report_${data['bedName']}.pdf',
    );

    await outputFile.writeAsBytes(await pdf.save());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(filePath: outputFile.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bedRef = FirebaseFirestore.instance.collection('beds').doc(patientId);

    return Scaffold(
      appBar: AppBar(
        title: Text("${S.of(context).report} - $bedName",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: bedRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || !snapshot.data!.exists)
            return Center(child: Text('لا توجد بيانات للمريض'));

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                /// معلومات المريض
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem("Name", data['bedName']),
                    _buildInfoItem("Age", data['age']),
                    _buildInfoItem("Gender", data['gender']),
                    _buildInfoItem("Phone Number", data['phoneNumber']),
                    _buildInfoItem("Bed Number", data['bedNumber']),
                    _buildInfoItem("Doctor Name", data['doctorName']),
                    _buildInfoItem("Patient ID", data['patientId']),
                  ],
                ),
                SizedBox(height: 20),

                /// القراءات
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: bedRef
                        .collection('readings')
                        .orderBy('timestamp', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator());

                      final records = snapshot.data!.docs;
                      if (records.isEmpty)
                        return Center(child: Text('لا توجد قراءات حيوية'));

                      return ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          final timestamp =
                              (record['timestamp'] as Timestamp?)?.toDate() ??
                                  DateTime.now();

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(
                                '📅 ${timestamp.toString()}',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Heart Rate: ${record['heart_rate']} BPM'),
                                  Text(
                                      'Temperature: ${record['temperature']} °C'),
                                  Text('Oxygen Level: ${record['spo2']} %'),
                                  Text(
                                      'Blood Pressure: ${record['blood_pressure']} mmHg'),
                                  Text('Glucose: ${record['glucose']} mg/dL'),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                /// الأزرار في الأسفل
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (snapshot.hasData) {
                          final patientData = snapshot.data!; // بيانات المريض
                          final bedRef = FirebaseFirestore.instance
                              .collection('beds')
                              .doc(patientId);

                          // تمرير بيانات المريض والقراءات إلى generateAndSavePDF
                          bedRef
                              .collection('readings')
                              .orderBy('timestamp', descending: true)
                              .limit(5)
                              .get()
                              .then((readingsSnapshot) {
                            final records = readingsSnapshot.docs;

                            // تم تمرير البيانات والقراءات بشكل صحيح
                            generateAndSavePDF(context, patientData, records);
                          });
                        }
                      },
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text(S.of(context).generating_report),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final outputDir = await getExternalStorageDirectory();
                        final downloadsDir =
                            Directory('${outputDir!.path}/Download');
                        final outputFile = File(
                            '${downloadsDir.path}/patient_report_${bedName}.pdf');
                        if (await outputFile.exists()) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(S.of(context).saved_successfully),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(S.of(context).saved_successfully),
                          ));
                        }
                      },
                      icon: Icon(Icons.download),
                      label: Text(S.of(context).downloading_report),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: $value",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          Divider(),
        ],
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String filePath;

  const PDFViewerScreen({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PDF - ${S.of(context).report}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: PDFView(
            filePath: filePath,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
          ),
        ),
      ),
    );
  }
}
