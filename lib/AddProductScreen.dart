import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:PTMRacing/Utils/images.dart';
import 'package:PTMRacing/model/model_product.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as ImageResize;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:intl/intl.dart';
import 'package:PTMRacing/DataRepository.dart';

class AddProductScreen extends StatefulWidget {
  String sUsername;

  AddProductScreen({Key key, this.sUsername}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  int _counter = 0;
  List<ModelProduct> mdProduct = new List();
  String sBarcode = '';
  String sBase64Img = '';
  final picker = ImagePicker();
  DateFormat datetimeFormat = DateFormat('dd-MM-yyyy HH:mm');
  DateFormat timeFormat = DateFormat('HH:mm');
  DateTime currentDt = DateTime.now();
  DataRepository repository = DataRepository();
  String sFullDate = '';
  String sUsername = '';

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

  @override
  void initState() {
    if (this.widget.sUsername != null) sUsername = this.widget.sUsername;
    setDataListView();
    super.initState();
  }

  deleteFromDB(String sDocID) async {
    await Firestore.instance.collection("product").document(sDocID).delete();
    Navigator.pop(context, 'deleted');
    await setDataListView();
    setState(() {});
  }

  setDataListView() async {
    sFullDate = currentDt.day.toString() +
        " " +
        getMonthName(currentDt.month) +
        " " +
        (currentDt.year + 543).toString();
    // สำหรับดึงข้อมูล firebase
    mdProduct.clear();
    await Firestore.instance
        .collection("product")
        .orderBy("date", descending: true)
        .getDocuments()
        .then((value) {
      int iRet = value.documents.length;
      value.documents.forEach((element) {
        String sBarcode = element.data['barcode'];
        String sDate = element.data['date'];
        String sCode = element.data['code'];
        String sName = element.data['name'];
        String sGroup = element.data['group'];
        String sImg64 = element.data['image'];
        String sUsername = element.data['username'];
        String sDocID = element.documentID;
        DateTime dtDocDate = DateTime.parse(sDate);
        String dateFormat = datetimeFormat.format(DateTime(dtDocDate.year + 543,
            dtDocDate.month, dtDocDate.day, dtDocDate.hour, dtDocDate.minute));
        mdProduct.add(ModelProduct(
          sBarcode,
          sDate: dateFormat,
          sCode: sCode,
          sName: sName,
          sGroup: sGroup,
          sImg64: sImg64,
          sUsername: sUsername,
          sDocID: sDocID,
        ));
      });
      if (iRet > 0) {
        setState(() {});
      }
    });
  }

  processCreateProduct() async {
    sBase64Img = '';
    sBarcode = '';

    String sBase64 = await _imageTakePicture();
    if (sBase64Img != null && sBase64Img != '') {
      await scan();

      if (sBarcode != null && sBarcode != '') {
        String sDate = currentDt.toString();

//      mdProduct.add(ModelProduct(sBarcode,sDate: sDate,sCode: sBarcode,sName: 'ไม่ระบุ',sGroup: 'ไม่ระบุ',sImg64: sBase64Img));
        await repository.addProduct(ModelProduct(sBarcode,
            sDate: sDate,
            sCode: sBarcode,
            sName: 'ไม่ระบุ',
            sGroup: 'ไม่ระบุ',
            sImg64: sBase64Img,
            sUsername: sUsername));
        setDataListView();
      }
    }
  }

  _imageTakePicture() async {
    var picture = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 600,
      imageQuality: 85,);
    ImageResize.Image imageFile =
        ImageResize.decodeJpg(File(picture.path).readAsBytesSync());
    ImageResize.Image thumbnail = ImageResize.copyResize(imageFile, width: 300);
    sBase64Img = base64Encode(ImageResize.encodePng(thumbnail));
//    imageProduct = ImagesConverter.imageFromBase64String(sBase64Img);
    setState(() {});
    return sBase64Img;
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();

      setState(() {
        if (barcode != null) {
          sBarcode = barcode;
        }
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
//          Text("");
      } else {
        // Unknown error.
      }
    } on FormatException {
      // User returned using the "back"-button before scanning anything.
    } catch (e) {
      // Unknown error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: GestureDetector(
            child: Text("รายการสินค้า"),
            onTap: () {

            },
          )
      ),
      body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        padding: EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('วันที่: ' + sFullDate),
                            Text('ชื่อผู้ใช้งาน: ' + sUsername),
                          ],
                        )),
                  )
                ],
              ),
              _buildSuggestions(),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => processCreateProduct(),
        tooltip: 'Scan',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSuggestions() {
    return mdProduct.length > 0
        ? new GridView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: mdProduct.length,
      shrinkWrap: true,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
      itemBuilder: (context, i) {
        final index = i;

//        if (index >= mdProduct.length) {
//          getProduct(index);
//        }

//        for (int i = 0; i < index + 1; i++) {
//          values.add(0);
//        }

        if (mdProduct.length > 0 && index < mdProduct.length) {
          return _buildRow(mdProduct[index], index);
        }
      },
    )
        : Expanded(
      child: Center(
        child: Text(
          "ไม่มีรายการ",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildRow(ModelProduct pair, int index) {
    return Card(
      elevation: 5.0,
      color: Colors.white,
      child: new GestureDetector(
        child: new Column(
          children: <Widget>[
            Expanded(
                flex: 6,
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
                                    child:
                                    ImagesConverter.imageFromBase64String(
                                        pair.sImg64)),
                              ),
                              tag: pair.sImg64,
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
                                                  borderRadius:
                                                  BorderRadius.only(
                                                      topLeft: Radius
                                                          .circular(5),
                                                      topRight:
                                                      Radius.circular(
                                                          5)),
                                                  child: ImagesConverter
                                                      .imageFromBase64String(
                                                      pair.sImg64,
                                                      bTapView: true)),
                                              tag: pair.sImg64,
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
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: Icon(Icons.close,
                                              color: Colors.grey),
                                          label: Text(
                                            "ยกเลิก",
                                            style:
                                            TextStyle(color: Colors.grey),
                                          )),
                                      FlatButton.icon(
                                          onPressed: () async {
                                            String sResult =
                                            await deleteFromDB(pair.sDocID);
                                          },
                                          icon: Icon(Icons.delete_forever,
                                              color: Colors.red),
                                          label: Text(
                                            "ลบ",
                                            style: TextStyle(color: Colors.red),
                                          )),
                                    ],
                                  );
                                });
                          }),
                    )
                  ],
                )),
            Expanded(
              flex: 1,
              child: new Container(
                padding: EdgeInsets.only(left: 5),
                child: new Row(
                  children: <Widget>[
                    Text(
                      pair.sBarcode,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: new Container(
                padding: EdgeInsets.only(left: 5),
                child: new Row(
                  children: <Widget>[
                    Text(
                      pair.sDate,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: new Container(
                padding: EdgeInsets.only(left: 5),
                child: new Row(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          size: 15,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          pair.sUsername,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, height: 1.1),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
