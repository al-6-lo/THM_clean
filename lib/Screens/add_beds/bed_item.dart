import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:t_h_m/Screens/vital_signs/vital_signs_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class BedItem extends StatefulWidget {
  final String docId;
  final String bedNumber;
  final String bedName;
  final int age;
  final String gender;
  final String phoneNumber;
  final String doctorName;
  final String userRole;
  final String heartRate;
  final String temperature;
  final String spo2;
  final String bloodPressure;
  final String glucose;

  const BedItem({
    Key? key,
    required this.docId,
    required this.bedNumber,
    required this.bedName,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.doctorName,
    required this.userRole,
    required this.heartRate,
    required this.temperature,
    required this.spo2,
    required this.bloodPressure,
    required this.glucose,
  }) : super(key: key);

  @override
  _BedItemState createState() => _BedItemState();
}

class _BedItemState extends State<BedItem> {
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

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void _initializeDatabase() {
    vitalSignsRef = database.ref();
    _listenToVitalSigns();
  }

  bool isConnected = false; // حالة الاتصال

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

          // نتحقق من الوقت
          String? timestampStr = data["timestamp"]?.toString();
          if (timestampStr != null) {
            DateTime lastUpdate = DateTime.parse(timestampStr);
            Duration difference = DateTime.now().difference(lastUpdate);
            isConnected = difference.inSeconds <
                10; // متصل إذا آخر تحديث أقل من 10 ثوانٍ مثلاً
          } else {
            isConnected = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VitalSignsScreen(
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
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عرض رقم السرير
            Row(
              children: [
                Text(
                  isConnected ? "🟢" : "🔴",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(width: 6),
                Text(
                  "${S.of(context).bed} ${widget.bedNumber}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // عرض العلامات الحيوية
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "HR: ${vitalSigns["heart_rate"]} BPM",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Temp: ${vitalSigns["temperature"]} °C",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Oxygen: ${vitalSigns["spo2"]} %",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "BP: ${vitalSigns["blood_pressure"]} mmHg",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Glucose: ${vitalSigns["glucose"]} mg/dL",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
