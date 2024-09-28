import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_notification/provider/medicines.dart';
import 'package:provider/provider.dart';
import 'medical_register.dart';
import 'components/medicine_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final medicines = Provider.of<Medicines>(context, listen: false);
    if (state == AppLifecycleState.resumed) {

      medicines.reloadMedicines();
    }else {
      print(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Health Notification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if(!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          )

        ],
      ),
      body: Center(
        child: MedicineList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return MedicalRegisterSheet();
              },
          );
          // MedicalRegisterSheet()
        },
      )
    );
  }
}