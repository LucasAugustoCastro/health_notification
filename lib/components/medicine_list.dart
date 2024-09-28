import 'package:flutter/material.dart';
import 'package:health_notification/components/medicine_tile.dart';
import 'package:health_notification/provider/medicines.dart';
import 'package:provider/provider.dart';

class MedicineList extends StatefulWidget {
  @override
  _MedicineListState createState() => _MedicineListState();
}

class _MedicineListState extends State<MedicineList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<Medicines>(context, listen: false).fetchMedicines());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<Medicines>(
          builder: (context, medicines, child) {
            return ListView.builder(
              itemCount: medicines.count,
              itemBuilder: (ctx, i) {
                final medicine = medicines.byIndex(i);
                return MedicineTile(medicine);
              },
            );
          }
      )
    );
  }
}
