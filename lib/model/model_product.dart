import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ModelProduct {
  String sName;
  String sDate;
  String sTime;
  String sCode;
  String sBarcode;
  String sGroup;
  String sImg64;
  Image imageList;
  String sUsername;
  String sDocID;
  DocumentReference reference;

  ModelProduct(this.sBarcode,
      {this.sDate,
      this.sTime,
      this.sCode,
      this.sName,
      this.sGroup,
      this.sImg64,
        this.imageList,
        this.sUsername,
      this.sDocID,
      this.reference});

  factory ModelProduct.fromJson(Map<dynamic, dynamic> json) =>
      _ModelProductFromJson(json);

  Map<String, dynamic> toJson() => _ModelProductToJson(this);

  @override
  String toString() => "Barcode<$sBarcode>";

//  String get getBarcode => sBarcode;
//
//  String get getCode => sCode;
//
//  String get getName => sName;
//
//  String get getGroup => sGroup;
//
//  String get getsImg64 => sImg64;
//
//  set setBarcode(String sBarcode) {
//    this.sBarcode = sBarcode;
//  }
//
//  set setCode(String sCode) {
//    this.sCode = sCode;
//  }
//
//  set setName(String sName) {
//    this.sName = sName;
//  }
//
//  set setGroup(String sGroup) {
//    this.sGroup = sGroup;
//  }
}

ModelProduct _ModelProductFromJson(Map<dynamic, dynamic> json) {
  return ModelProduct(
    json['barcode'] as String,
    sDate: json['date'] as String,
    sTime: json['time'] as String,
    sCode: json['code'] as String,
    sName: json['name'] as String,
    sGroup: json['group'] as String,
    sImg64: json['image'] as String,
    sUsername: json['username'] as String,
    sDocID: json['docID'] as String,
  );
}

//2
Map<String, dynamic> _ModelProductToJson(ModelProduct instance) =>
    <String, dynamic>{
      'barcode': instance.sBarcode,
      'date': instance.sDate,
      'time': instance.sTime,
      'code': instance.sCode,
      'name': instance.sName,
      'group': instance.sGroup,
      'image': instance.sImg64,
      'username': instance.sUsername,
      'docID': instance.sDocID,
    };
