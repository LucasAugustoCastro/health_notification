import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_notification/model/medicine.dart';
import 'package:health_notification/provider/medicines.dart';
import 'package:provider/provider.dart';
import 'CustomWidget/my_text_field.dart';

class MedicalRegisterSheet extends StatefulWidget {
  final Medicine? medicine;

  MedicalRegisterSheet({this.medicine});

  @override
  _MedicalRegisterSheetState createState() => _MedicalRegisterSheetState();
}

class _MedicalRegisterSheetState extends State<MedicalRegisterSheet> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _medicineHourController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _medicineNameController.text = widget.medicine!.name;
      _medicineHourController.text = widget.medicine!.time;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _medicineHourController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveMedicine(Medicines medicines) async {
    if (_formKey.currentState!.validate()) {
      try {
        final newMedicine = Medicine(
          name: _medicineNameController.text.trim(),
          time: _medicineHourController.text,
          userId: FirebaseAuth.instance.currentUser!.uid,
        );
        if (widget.medicine == null) {
          medicines.addMedicine(newMedicine);
        } else {
          medicines.updateMedicine(widget.medicine!.id as String, newMedicine);
        }
        if (!mounted) return ;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.medicine == null ? 'Remédio cadastrado com sucesso!' : "Remédio atualizado com sucesso" ))
        );
      } catch (e) {
        ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(
            SnackBar(content: Text('Erro ao salvar remédio: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicines = Provider.of<Medicines>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MyTextField(
                        myController: _medicineNameController,
                        fieldName: "Digite o nome do remédio",
                        myIcon: Icons.medical_services,
                      ),
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: AbsorbPointer(
                          child: MyTextField(
                            myController: _medicineHourController,
                            fieldName: "Escolha o horário do remédio",
                            myIcon: Icons.access_time,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveMedicine(medicines);
                            Navigator.pop(context);
                            _medicineNameController.clear();
                            _medicineHourController.clear();

                          }
                        },
                        child: Text(widget.medicine == null
                            ? "Registrar Remédio"
                            : "Atualizar Remédio"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
