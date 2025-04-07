import 'package:flutter/material.dart';

class VitalSignCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const VitalSignCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Theme.of(context).colorScheme.background,
      child: ListTile(
        leading: Icon(icon,
            color: Theme.of(context).colorScheme.onBackground, size: 30),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground)),
        subtitle: Text(value,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground)),
      ),
    );
  }
}
