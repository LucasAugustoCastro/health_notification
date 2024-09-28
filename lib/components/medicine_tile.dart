import 'package:flutter/material.dart';
import 'package:health_notification/medical_register.dart';
import 'package:health_notification/model/medicine.dart';
import 'package:health_notification/provider/medicines.dart';
import 'package:provider/provider.dart';

class MedicineTile extends StatelessWidget {
  final Medicine medicine;
  const MedicineTile(this.medicine, {super.key});

  @override
  Widget build(BuildContext context) {
    final medicines = Provider.of<Medicines>(context, listen: false);
    return ListTile(
      leading: Checkbox(
          value: medicine.taken,
          onChanged: (value) {
            medicines.changeTakenValue(medicine.id!);
          }),
      title: Text(medicine.name),
      subtitle: Text(medicine.time),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
                onPressed: (){
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return MedicalRegisterSheet(medicine: medicine);
                    },
                  );
                },
                icon: Icon(Icons.edit),
                color: Colors.orange,
            ),
            IconButton(
              onPressed: (){
                medicines.deleteMedicine(medicine.id!);
              },
              icon: Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
