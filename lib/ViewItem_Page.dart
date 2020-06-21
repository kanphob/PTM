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
  String sUsername = '';
  String sListData = '';
  DateTime currentDt = DateTime.now();
  DateTime dtStartDate = DateTime.now();
  DateTime dtEndDate = DateTime.now();
  DateTime currentDateTime = DateTime.now();
  DateFormat datetimeFormat = DateFormat('dd-MM-yyyy HH:mm');
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  DateFormat timeFormat = DateFormat('HH:mm');
  Image image;
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
    await Firestore.instance.collection("product").where("barcode", isEqualTo: widget.sBarcode.toString().substring(0, 10)).getDocuments().then((value) {
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
      Image itemImage = ImagesConverter.imageFromBase64String(sImg64);
      if(sImg64 != null && sImg64 != null) {
        itemImage = ImagesConverter.imageFromBase64String(sImg64);
      }
      else{
        itemImage = image;
      }
      mdProduct = ModelProduct(
        sBarcode,
        sDate: sThaiMonth,
        sTime: sTime,
        sCode: sCode,
        sName: sName,
        sGroup: sGroup,
        sImg64: sImg64,
        imageList: itemImage,
        sUsername: sUsername,
        sDocID: sDocID,
      );
      }
    );
    if (iRet > 0) {
//        Navigator.pop(context);
      setState(() {
        image = mdProduct.imageList;
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
              _buildShowContent(mdProduct),
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
  Widget _buildShowContent(ModelProduct mdProduct){
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
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
                              child: mdProduct.imageList != null ? mdProduct.imageList :  Container()
                          ),
                        ),
                        tag: mdProduct.sImg64,
                      ),
                      onTap: () {
                        Navigator.of(context).push(new PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) {
                              return new Material(
                                  color: Colors.black38,
                                  child: new Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(5)),
//                                    padding: const EdgeInsets.all(30.0),
                                    child: new InkWell(
                                      child: new Hero(
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                topRight:
                                                Radius.circular(5)),
                                            child: ImagesConverter
                                                .imageFromBase64String(
                                                mdProduct.sImg64,
                                                bTapView: true)),
                                        tag: mdProduct.sImg64,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ));
                            }));
                      },
                    ),
                  )
                ],
              ),
              Positioned(
                top: 1,
                right: 1,
                child: IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: Text("ต้องการลบรายการนี้หรือไม่?"),
                              actions: <Widget>[
                                FlatButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(Icons.close,
                                        color: Colors.grey),
                                    label: Text(
                                      "ยกเลิก",
                                      style: TextStyle(color: Colors.grey),
                                    )),
//                                FlatButton.icon(
//                                    onPressed: () async {
//                                      String sResult =
//                                      await deleteFromDB(pair.sDocID);
//                                    },
//                                    icon: Icon(Icons.delete_forever,
//                                        color: Colors.red),
//                                    label: Text(
//                                      "ลบ",
//                                      style: TextStyle(color: Colors.red),
//                                    )),
                              ],
                            );
                          });
                    }),
              )
            ],
          ),
        ),
      ],
    );
  }
}
