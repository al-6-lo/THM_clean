import 'dart:async'; // ضروري للتايمر
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:t_h_m/Screens/Patient_info/patient_info_screen.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'vital_signs_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:t_h_m/Screens/patient_report/patient_report_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VitalSignsScreen extends StatefulWidget {
  final String bedNumber;
  final String docId;
  final String bedName;
  final int age;
  final String gender;
  final String phoneNumber;
  final String doctorName;
  final String userRole;

  const VitalSignsScreen({
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
  _VitalSignsScreenState createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  final FirebaseDatabase database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://thm1-95526-default-rtdb.firebaseio.com/",
  );

  late DatabaseReference vitalSignsRef;
  Map<String, String> vitalSigns = {
    "heart_rate": "Loading...",
    "temperature": "Loading...",
    "spo2": "Loading...",
    "blood_pressure": "Loading...",
    "glucose": "Loading...",
  };

  final FlutterTts _flutterTts = FlutterTts();

  Timer? _alertTimer;
  bool _isDangerActive = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void _initializeDatabase() {
    vitalSignsRef = database.ref();
    _listenToVitalSigns();
  }

// إضافة هذه الدالة لحفظ البيانات في Firestore
  void _saveVitalSignsToFirestore(Map<String, String> vitalSigns) async {
    try {
      // المرجع إلى الكولكشن "readings" داخل "beds"
      DocumentReference bedDocRef =
          FirebaseFirestore.instance.collection('beds').doc(widget.docId);
      CollectionReference readingsCollection = bedDocRef.collection('readings');

      // إضافة البيانات الجديدة
      await readingsCollection.add({
        'heart_rate': vitalSigns["heart_rate"],
        'temperature': vitalSigns["temperature"],
        'spo2': vitalSigns["spo2"],
        'blood_pressure': vitalSigns["blood_pressure"],
        'glucose': vitalSigns["glucose"],
        'timestamp': FieldValue.serverTimestamp(),
      });

      // تحديد عدد السجلات الموجود (يتم ترتيبها حسب "timestamp" نزولًا)
      QuerySnapshot snapshot = await readingsCollection
          .orderBy('timestamp', descending: true)
          .limit(5) // نحصل على السجلات الستة الأخيرة
          .get();

      // إذا كانت السجلات أكثر من 5، يتم حذف الأقدم
      if (snapshot.size > 5) {
        // حذف أقدم سجل (أي السجل الأول في النتيجة بعد الترتيب)
        var docToDelete = snapshot.docs.last;
        await docToDelete.reference.delete();
        print("Deleted oldest entry");
      }

      print("Data saved to Firestore successfully!");
    } catch (e) {
      print("Error saving data to Firestore: $e");
    }
  }

  void _listenToVitalSigns() {
    vitalSignsRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          vitalSigns = {
            "heart_rate": data["HR"]?.toString() ?? "N/A",
            "temperature": data["Temp"]?.toString() ?? "N/A",
            "spo2": data["SPO2"]?.toString() ?? "N/A",
            "blood_pressure": data["BP"]?.toString() ?? "N/A",
            "glucose": data["Glucose"]?.toString() ?? "N/A",
          };
        });

        _checkVitalSigns();
        _saveVitalSignsToFirestore(vitalSigns);
      }
    });
  }

  void _startRepeatingAlert() {
    if (_alertTimer == null || !_alertTimer!.isActive) {
      _alertTimer = Timer.periodic(Duration(seconds: 4), (timer) async {
        await _flutterTts.setLanguage("ar");
        await _flutterTts.setLanguage("en");
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.4);
        await _flutterTts.speak("Patient ${widget.bedName} is in danger");
      });
    }
  }

  void _stopRepeatingAlert() {
    _alertTimer?.cancel();
    _alertTimer = null;
  }

  void _checkVitalSigns() async {
    const double normalHeartRateLower = 60;
    const double normalHeartRateUpper = 200;
    const double normalTemperature = 37;
    const double normalSpo2Lower = 90;
    const double normalBloodPressureLower = 90;
    const double normalBloodPressureUpper = 120;
    const double normalGlucoseUpper = 140;

    bool isInDanger = false;

    if (double.tryParse(vitalSigns["heart_rate"] ?? "") != null) {
      double heartRate = double.parse(vitalSigns["heart_rate"]!);
      if (heartRate < normalHeartRateLower ||
          heartRate > normalHeartRateUpper) {
        isInDanger = true;
      }
    }

    if (double.tryParse(vitalSigns["temperature"] ?? "") != null) {
      double temperature = double.parse(vitalSigns["temperature"]!);
      if (temperature > normalTemperature) {
        isInDanger = true;
      }
    }

    if (double.tryParse(vitalSigns["spo2"] ?? "") != null) {
      double spo2 = double.parse(vitalSigns["spo2"]!);
      if (spo2 < normalSpo2Lower) {
        isInDanger = true;
      }
    }

    if (vitalSigns["blood_pressure"] != null) {
      var bloodPressure = vitalSigns["blood_pressure"]!.split('/');
      if (bloodPressure.length == 2) {
        double? systolic = double.tryParse(bloodPressure[0]);
        double? diastolic = double.tryParse(bloodPressure[1]);
        if (systolic != null && diastolic != null) {
          if (systolic < normalBloodPressureLower ||
              systolic > normalBloodPressureUpper ||
              diastolic < normalBloodPressureLower ||
              diastolic > normalBloodPressureUpper) {
            isInDanger = true;
          }
        }
      }
    }

    if (double.tryParse(vitalSigns["glucose"] ?? "") != null) {
      double glucose = double.parse(vitalSigns["glucose"]!);
      if (glucose > normalGlucoseUpper) {
        isInDanger = true;
      }
    }

    if (isInDanger) {
      _startRepeatingAlert();
      _isDangerActive = true;
    } else {
      if (_isDangerActive) {
        _stopRepeatingAlert();
        _isDangerActive = false;
      }
    }
  }

  @override
  void dispose() {
    _stopRepeatingAlert(); // إيقاف التايمر عند مغادرة الشاشة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "${S.of(context).vital_signs} - ${widget.bedName}",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        actions: [
          IconButton(
            icon: Icon(Icons.print,
                color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportScreen(
                      patientId: widget.docId, bedName: widget.bedName),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person,
                color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientInfoScreen(
                    docId: widget.docId,
                    bedNumber: widget.bedNumber,
                    bedName: widget.bedName,
                    age: widget.age,
                    gender: widget.gender,
                    phoneNumber: widget.phoneNumber,
                    doctorName: widget.doctorName,
                    userRole: widget.userRole,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VitalSignCard(
              icon: Icons.favorite,
              label: 'Heart Rate',
              value: '${vitalSigns["heart_rate"]} BPM',
            ),
            VitalSignCard(
              icon: Icons.thermostat,
              label: 'Temperature',
              value: '${vitalSigns["temperature"]} °C',
            ),
            VitalSignCard(
              icon: Icons.bubble_chart,
              label: 'Oxygen Level',
              value: '${vitalSigns["spo2"]} %',
            ),
            VitalSignCard(
              icon: Icons.monitor_heart,
              label: 'Blood Pressure',
              value: '${vitalSigns["blood_pressure"]} mmHg',
            ),
            VitalSignCard(
              icon: Icons.bloodtype,
              label: 'Glucose',
              value: '${vitalSigns["glucose"]} mg/dL',
            ),
          ],
        ),
      ),
    );
  }
}
