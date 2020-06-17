import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterptm/model/model_product.dart';

class DataRepository {
  // 1
  final CollectionReference collection =
      Firestore.instance.collection('product');

  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  Future<DocumentReference> addProduct(ModelProduct product) {
    return collection.add(product.toJson());
  }

  // 4
  updateProduct(ModelProduct product) async {
    await collection
        .document(product.reference.documentID)
        .updateData(product.toJson());
  }
}
