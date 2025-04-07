import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:t_h_m/Screens/add_beds/add_beds_screen.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'patient_info_dialogs.dart';
import 'patient_info_firebase.dart';
import 'patient_info_widgets.dart';
import 'package:t_h_m/Screens/add_beds/add_beds_firebase.dart';

class PatientInfoScreen extends StatefulWidget {
  final String docId;
  final String bedNumber;
  final String bedName;
  final int age;
  final String gender;
  final String phoneNumber;
  final String doctorName;
  final String userRole;

  const PatientInfoScreen({
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
  PatientInfoScreenState createState() => PatientInfoScreenState();
}

class PatientInfoScreenState extends State<PatientInfoScreen> {
  late TextEditingController bedNumberController;
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController phoneController;
  late TextEditingController doctorNameController;

  bool _isEditing = false;
  String? userRole;
  bool isLoading = true;
  late String originalBedNumber,
      originalName,
      originalAge,
      originalGender,
      originalPhone,
      originaldoctorName;

  late String selectedGender;
  int? patientId; // السماح بأن يكون `null` لمنع الخطأ
  late Future<int> loadPatientIdFuture; // تعريف المتغير
  String? selectedDoctor; // إضافة هذا السطر
  List<String> doctorNames = [];
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    loadPatientIdFuture = loadPatientId(); // تعيين دالة التحميل
    initializeControllers();
    loadDoctors();
  }

  void initializeControllers() {
    bedNumberController = TextEditingController(text: widget.bedNumber);
    nameController = TextEditingController(text: widget.bedName);
    ageController = TextEditingController(text: widget.age.toString());
    phoneController = TextEditingController(text: widget.phoneNumber);
    doctorNameController = TextEditingController(text: widget.doctorName);

    selectedGender = widget.gender;

    originalBedNumber = widget.bedNumber;
    originalName = widget.bedName;
    originalAge = widget.age.toString();
    originalGender = widget.gender;
    originalPhone = widget.phoneNumber;
    originaldoctorName = widget.doctorName;
  }

  @override
  void dispose() {
    bedNumberController.dispose();
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    doctorNameController.dispose();

    super.dispose();
  }

  Future<void> loadDoctors() async {
    List<String> doctors =
        await _firebaseService.fetchDoctorNames(); // استدعاء الدالة من الكائن
    setState(() {
      doctorNames = doctors;
    });
  }

  void _updatePatientData() async {
    var docRef =
        FirebaseFirestore.instance.collection('beds').doc(widget.docId);
    String newBedNumber = bedNumberController.text.trim();

    // التحقق مما إذا كان رقم السرير الجديد موجودًا بالفعل في قاعدة البيانات
    var querySnapshot = await FirebaseFirestore.instance
        .collection('beds')
        .where('bedNumber', isEqualTo: newBedNumber)
        .get();

    bool bedNumberExists =
        querySnapshot.docs.any((doc) => doc.id != widget.docId);

    if (bedNumberExists) {
      showDuplicateBedNumberDialog(context);
      return; // الخروج دون تحديث البيانات
    }

    // تحديث البيانات إذا لم يكن رقم السرير مكررًا
    docRef.get().then((docSnapshot) {
      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Document does not exist!')),
        );
        return;
      }

      docRef.update({
        'bedNumber': newBedNumber,
        'bedName': nameController.text.trim(),
        'age': int.tryParse(ageController.text) ?? int.parse(originalAge),
        'gender': selectedGender,
        'phoneNumber': phoneController.text.trim(),
        'doctorName': doctorNameController.text.trim(),
      }).then((_) {
        setState(() {
          _isEditing = false;
          originalBedNumber = newBedNumber;
          originalName = nameController.text;
          originalAge = ageController.text;
          originalGender = selectedGender;
          originalPhone = phoneController.text;
          originaldoctorName = doctorNameController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(S.of(context).updated_successfully,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color)),
              backgroundColor: Theme.of(context).dialogTheme.backgroundColor),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).update_failed}: $error')),
        );
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching document: $error')),
      );
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;

      bedNumberController.text = originalBedNumber;
      nameController.text = originalName;
      ageController.text = originalAge;
      selectedGender = originalGender;
      phoneController.text = originalPhone;
      doctorNameController.text = originaldoctorName;
    });
  }

  Future<bool> _onWillPop() async {
    if (_isEditing) {
      _cancelEditing();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).patient_informations,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          backgroundColor: AppColors.primaryColor,
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
// استخدم FutureBuilder لانتظار تحميل patientId
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('beds')
                      .doc(widget.docId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      );
                    } else if (!snapshot.hasData || !snapshot.data!.exists) {
                      // ✅ إذا تم حذف المريض، إغلاق الصفحة تلقائيًا
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddBedsScreen()), // استبدل `HomePage` بصفحتك الرئيسية
                            (Route<dynamic> route) => false,
                          );
                        }
                      });

                      return Center(
                        child: Text(
                          "Patient data not found.",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      var data = snapshot.data!;
                      int patientId = data['patientId'] ?? 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${S.of(context).patientId} : $patientId',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }
                  },
                ),
                PatientInfoWidgets.buildTextField(
                  context: context,
                  label: S.of(context).bed_number,
                  controller: bedNumberController,
                  enabled: _isEditing,
                  originalValue: originalBedNumber,
                ),
                PatientInfoWidgets.buildTextField(
                  context: context,
                  label: S.of(context).name,
                  controller: nameController,
                  enabled: _isEditing,
                  originalValue: originalName,
                ),
                PatientInfoWidgets.buildTextField(
                  context: context,
                  label: S.of(context).age,
                  controller: ageController,
                  enabled: _isEditing,
                  originalValue: originalAge,
                ),
                PatientInfoWidgets.buildGenderSelector(
                  context: context,
                  enabled: _isEditing,
                  selectedGender: selectedGender,
                  onGenderSelected: (String gender) {
                    setState(() {
                      selectedGender = gender;
                    });
                  },
                ),
                PatientInfoWidgets.buildTextField(
                  context: context,
                  label: S.of(context).phone_number,
                  controller: phoneController,
                  enabled: _isEditing,
                  originalValue: originalPhone,
                ),
                _isEditing
                    ? DropdownButtonFormField<String>(
                        value: selectedDoctor?.isNotEmpty == true
                            ? selectedDoctor
                            : originaldoctorName, // إظهار اسم الدكتور الحالي إذا كان موجودًا
                        dropdownColor:
                            Theme.of(context).dialogTheme.backgroundColor,
                        decoration: InputDecoration(
                          labelText: S.of(context).doctor_name,
                        ),
                        items: doctorNames.map((String doctor) {
                          return DropdownMenuItem<String>(
                            value: doctor,
                            child: Text(doctor),
                          );
                        }).toList(),
                        validator: (value) => value == null
                            ? S.of(context).please_doctor_name
                            : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDoctor = newValue ?? originaldoctorName;
                          });
                        },
                      )
                    : PatientInfoWidgets.buildTextField(
                        context: context,
                        label: S.of(context).doctor_name,
                        controller: doctorNameController,
                        enabled:
                            false, // لا يمكن تعديله إذا لم يكن في وضع التعديل
                        originalValue:
                            originaldoctorName, // القيمة الأصلية لاسم الطبيب
                      ),

                const SizedBox(height: 20),
                if (_isEditing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _updatePatientData,
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary),
                        child: Text(
                          S.of(context).save,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _cancelEditing,
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error),
                        child: Text(
                          S.of(context).cancel,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (patientId != 0) {
                            // التحقق مما إذا كان `patientId` قد تم تحميله
                            showDeleteConfirmationDialog(context, widget.docId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Patient ID is not available yet.")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error),
                        child: Text(
                          S.of(context).delete,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: widget.userRole == "Admin"
            ? FloatingActionButton(
                onPressed: () => setState(() {
                  _isEditing = true;
                }),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : null,
      ),
    );
  }
}
