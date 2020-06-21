import 'dart:ui';
import 'package:PTMRacing/Utils/images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'model/model_product.dart';
class ViewItemPage extends StatefulWidget {
  String sBarcode ;
  ViewItemPage({Key key, this.sBarcode}) : super (key: key);
  @override
  _ViewItemPageState createState() => _ViewItemPageState();
}

class _ViewItemPageState extends State<ViewItemPage> {
  List<DocumentSnapshot> _documentList = new List();
  ModelProduct mdProduct;
  String sFullDate = '';
  String sListData = '';
  DateTime currentDt = DateTime.now();
  DateTime dtStartDate = DateTime.now();
  DateTime dtEndDate = DateTime.now();
  DateTime currentDateTime = DateTime.now();
  DateFormat datetimeFormat = DateFormat('dd-MM-yyyy HH:mm');
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  DateFormat timeFormat = DateFormat('HH:mm');
  Image image;
  String sThaiMonths = '';
  String sTimes = '';
  String sCodes = '';
  String sNames = '';
  String sGroups = '';
  String sUserName = '';
  String getMonthName(final int month) {
    switch (month) {
      case 1:
        return "มกราคม";
      case 2:
        return "กุมภาพันธ์";
      case 3:
        return "มีนาคม";
      case 4:
        return "เมษายน";
      case 5:
        return "พฤษภาคม";
      case 6:
        return "มิถุนายน";
      case 7:
        return "กรกฎาคม";
      case 8:
        return "สิงหาคม";
      case 9:
        return "กันยายน";
      case 10:
        return "ตุลาคม";
      case 11:
        return "พฤศจิกายน";
      case 12:
        return "ธันวาคม";
      default:
        return "Unknown";
    }
  }
  _setDataListViewFirstTime() async {
    sFullDate = currentDt.day.toString() +
        " " +
        getMonthName(currentDt.month) +
        " " +
        (currentDt.year).toString();
    int iRet = 0 ;
    // สำหรับดึงข้อมูล firebase
    await Firestore.instance.collection("product").where("barcode", isEqualTo: widget.sBarcode).getDocuments().then((value) {
      iRet = value.documents.length;
      String sBarcode = value.documents[0].data['barcode'];
      String sDate = value.documents[0].data['date'];
      String sTime = value.documents[0].data['time'];
      String sCode = value.documents[0].data['code'];
      String sName = value.documents[0].data['name'];
      String sGroup = value.documents[0].data['group'];
      String sImg64 = value.documents[0].data['image'];
      String sUsername = value.documents[0].data['username'];
      String sDocID = value.documents[0].documentID;
      DateTime dtDocDate = DateTime.parse(sDate);
      String sThaiMonth = sTime;
      String dateFormat = datetimeFormat.format(DateTime(dtDocDate.year,
          dtDocDate.month, dtDocDate.day, dtDocDate.hour, dtDocDate.minute));
      Image itemImage ;
      if(itemImage != null && sImg64 != null) {
        itemImage = ImagesConverter.imageFromBase64String(sImg64);
        image = itemImage;
      }
      widget.sBarcode = sBarcode;
      sThaiMonths = sThaiMonth;
      sCodes = sCode;
      sNames = sName;
      sGroups = sGroup;
      sUserName = sUsername;
//      mdProduct = ModelProduct(
//        widget.sBarcode,
//        sDate: sThaiMonth,
//        sTime: sTime,
//        sCode: sCode,
//        sName: sName,
//        sGroup: sGroup,
//        sImg64: sImg64,
//        imageList: itemImage,
//        sUsername: sUsername,
//        sDocID: sDocID,
//      );
      }
    );
    if (iRet > 0) {
//        Navigator.pop(context);
      setState(() {
      });
    }
  }
  @override
  void initState() {
    _setDataListViewFirstTime();
    image = ImagesConverter.imageFromBase64String(null);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: null,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: <Widget>[
              _buildShowContent(),
            ],
          ),
        ),
    );
  }
  Widget _buildAppBar(){
    return AppBar(
        centerTitle: true,
        title: Text("รายการสินค้า"),
    );
  }
  Widget _buildShowContent(){
    return Column(
      children: <Widget>[
        InkWell(
          child: new Hero(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  border: Border.all(color: Colors.grey)),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5)),
                child: image,
              ),
            ),
            tag: widget.sBarcode,
          ),
          onTap: () {
            print(sThaiMonths);
//            Navigator.of(context).push(new PageRouteBuilder(
//                opaque: false,
//                pageBuilder: (BuildContext context, _, __) {
//                  return new Material(
//                      color: Colors.black38,
//                      child: new Container(
//                        decoration: BoxDecoration(
//                            borderRadius:
//                            BorderRadius.circular(5)),
////                                    padding: const EdgeInsets.all(30.0),
//                        child: new InkWell(
//                          child: new Hero(
//                            child: ClipRRect(
//                              borderRadius: BorderRadius.only(
//                                  topLeft: Radius.circular(5),
//                                  topRight:
//                                  Radius.circular(5)),
//                              child: ImagesConverter.imageFromBase64String(widget.sBarcode,
//                                  bTapView: true),
//                            ),
//                            tag: widget.sBarcode,
//                          ),
//                          onTap: () {
//                            Navigator.pop(context);
//                          },
//                        ),
//                      ));
//                }));
          },
        ),
      ]
    );
  }
}
