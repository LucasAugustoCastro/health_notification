import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_notification/model/medicine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;


class Medicines with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Medicine> _items = [];

  List<Medicine> get all {
    return [..._items];
  }

  int get count {
    return _items.length;
  }

  Medicine byIndex(int i) {
    return _items[i];
  }

  Future<void> fetchMedicines() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('medicines')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      _items = snapshot.docs.map((doc) {
        return Medicine.fromDocument(doc);
      }).toList();

      notifyListeners();

    } catch (error) {
      throw error;
    }
  }

  Future<void> addMedicine(Medicine medicine) async {
    try {
      final docRef = await _firestore.collection('medicines').add(medicine.toMap());
      medicine.id = docRef.id;
      _items.add(medicine);

      await medicine.scheduleNotificationEvery30Minutes();

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateMedicine(String id, Medicine newMedicine) async {
    try {
      await _firestore.collection('medicines').doc(id).update(newMedicine.toMap());

      final index = _items.indexWhere((med) => med.id == id);
      if (index >= 0) {
        newMedicine.id = id;
        _items[index] = newMedicine;
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> changeTakenValue(String id) async {
    try {
      final medicine = _items.where((item) => item.id == id).first;
      medicine.taken = !medicine.taken;
      tz.TZDateTime? now = null;
      if (medicine.taken) {
        await medicine.cancelNotificationsForMedicine();
        final localTimeZone = tz.getLocation('America/Sao_Paulo');
        now = tz.TZDateTime.now(localTimeZone);
        medicine.takenAt = Timestamp.fromDate(now);

      } else {
        await medicine.scheduleNotificationEvery30Minutes();
      }

      await FirebaseFirestore.instance
          .collection('medicines')
          .doc(medicine.id)
          .update({
            'taken': medicine.taken,
            'taken_at': now != null ? Timestamp.fromDate(now) : null,
          });
      notifyListeners();

    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteMedicine(String id) async {
    try {
      await _firestore.collection('medicines').doc(id).delete();
      final medicine = _items.where((item) => item.id == id).first;
      _items.removeWhere((med) => med.id == id);
      await medicine.cancelNotificationsForMedicine();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> reloadMedicines() async {
    try {

      await fetchMedicines();

      final localTimeZone = tz.getLocation('America/Sao_Paulo');
      final now = tz.TZDateTime.now(localTimeZone);
      for (var medicine in _items) {

        if (medicine.taken){
          var takenAt = medicine.takenAt!.toDate();
          if (takenAt.day != now.day){
            changeTakenValue(medicine.id!);
          }

        }



        if (!medicine.taken) {
          await medicine.cancelNotificationsForMedicine();
          medicine.scheduleNotificationEvery30Minutes();
        }
      }

    } catch (error) {
      throw error;
    }
  }

}