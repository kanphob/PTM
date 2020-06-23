import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Globals {
  static Firestore firebaseStore;
  static List<DocumentSnapshot> querySnapshot;
}
