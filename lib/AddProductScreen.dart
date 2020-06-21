import 'package:PTMRacing/ViewItem_Page.dart';
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
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_rounded_date_picker/rounded_date_picker.dart';

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
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  DateFormat timeFormat = DateFormat('HH:mm');
  DateTime currentDt = DateTime.now();
  DataRepository repository = DataRepository();
  String sFullDate = '';
  String sUsername = '';
  String sListData = '';
  TextEditingController dateStart_controller;
  TextEditingController dateEnd_controller;
  DateFormat savetimeFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');
  DateFormat savedateFormat = DateFormat('yyyy-MM-dd');
  DateTime dtStartDate = DateTime.now();
  DateTime dtEndDate = DateTime.now();
  DateTime currentDateTime = DateTime.now();
  DateTime currentDT = DateTime.now();
  TextEditingController searchBar_controller = TextEditingController();
  List<DocumentSnapshot> documentList = new List();
  bool bNoMoreData = false;
  TextStyle _textStyleButton = TextStyle(color: Colors.white);
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

  bool isProcess = false;

  waitProcess() async {
    if (!isProcess) {
      isProcess = true;
      await setDataListViewScrolling();
      isProcess = false;
//      if(isLoading){
//        isLoading = false;
//        setState(() {});
//      }
    }
  }

  @override
  void initState() {
    if (this.widget.sUsername != null) sUsername = this.widget.sUsername;
    String sThaiMonth = dtStartDate.day.toString() +
        ' ' +
        getMonthName(dtStartDate.month) +
        ' ' +
        dtStartDate.year.toString();
    dateStart_controller = TextEditingController(text: sThaiMonth);
    setDataListViewFirstTime();
    super.initState();
  }

  deleteFromDB(String sDocID) async {
    await Firestore.instance.collection("product").document(sDocID).delete();
    Navigator.pop(context, 'deleted');
    await setDataListViewFirstTime();
    setState(() {});
  }

  setDataListViewFirstTime() async {
    sFullDate = currentDt.day.toString() +
        " " +
        getMonthName(currentDt.month) +
        " " +
        (currentDt.year).toString();
    // สำหรับดึงข้อมูล firebase
    mdProduct.clear();
    await Firestore.instance
        .collection("product")
        .where("date", isEqualTo: dtStartDate.toString().substring(0, 10))
        .orderBy("time", descending: true)
        .limit(10)
        .getDocuments()
        .then((value) {
      int iRet = value.documents.length;
      value.documents.forEach((element) {
        String sBarcode = element.data['barcode'];
        String sDate = element.data['date'];
        String sTime = element.data['time'];
        String sCode = element.data['code'];
        String sName = element.data['name'];
        String sGroup = element.data['group'];
        String sImg64 = element.data['image'];
        String sUsername = element.data['username'];
        String sDocID = element.documentID;
        DateTime dtDocDate = DateTime.parse(sDate);
        String sThaiMonth =
//            dtDocDate.day.toString() +
//            ' ' +
//            getMonthName(dtDocDate.month) +
//            ' ' +
//            dtDocDate.year.toString() +
//            ' ' +
            sTime;
        String dateFormat = datetimeFormat.format(DateTime(dtDocDate.year,
            dtDocDate.month, dtDocDate.day, dtDocDate.hour, dtDocDate.minute));
        Image itemImage = ImagesConverter.imageFromBase64String(sImg64);
        if (sBarcode == null) sBarcode = '';
        if (sThaiMonth == null) sThaiMonth = '';
        if (sTime == null) sTime = '';
        if (sCode == null) sCode = '';
        if (sName == null) sName = '';
        if (sGroup == null) sGroup = '';
        if (sImg64 == null) sImg64 = '';
        if (sUsername == null) sUsername = '';
        mdProduct.add(ModelProduct(
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
        ));
        documentList.add(element);
      });
      if (iRet == 0) sListData = "ไม่มีรายการ";
      if (iRet == 0) bNoMoreData = true;
      if (iRet > 0) {
//        Navigator.pop(context);
        setState(() {});
      }
    });
  }

  getDataBySearch(String sSeachName) async {
    // สำหรับดึงข้อมูล firebase
    mdProduct.clear();
    await Firestore.instance
        .collection("product")
        .where("barcode", isGreaterThanOrEqualTo: sSeachName)
        .where("barcode", isLessThan: sSeachName + 'z')
        .getDocuments()
        .then((value) {
      int iRet = value.documents.length;
      value.documents.forEach((element) {
        String sBarcode = element.data['barcode'];
        String sDate = element.data['date'];
        String sTime = element.data['time'];
        String sCode = element.data['code'];
        String sName = element.data['name'];
        String sGroup = element.data['group'];
        String sImg64 = element.data['image'];
        String sUsername = element.data['username'];
        String sDocID = element.documentID;
        DateTime dtDocDate = DateTime.parse(sDate);
        String sThaiMonth =
//            dtDocDate.day.toString() +
//            ' ' +
//            getMonthName(dtDocDate.month) +
//            ' ' +
//            dtDocDate.year.toString() +
//            ' ' +
            sTime;
        String dateFormat = datetimeFormat.format(DateTime(dtDocDate.year,
            dtDocDate.month, dtDocDate.day, dtDocDate.hour, dtDocDate.minute));
        Image itemImage = ImagesConverter.imageFromBase64String(sImg64);
        if (sBarcode == null) sBarcode = '';
        if (sThaiMonth == null) sThaiMonth = '';
        if (sTime == null) sTime = '';
        if (sCode == null) sCode = '';
        if (sName == null) sName = '';
        if (sGroup == null) sGroup = '';
        if (sImg64 == null) sImg64 = '';
        if (sUsername == null) sUsername = '';
        mdProduct.add(ModelProduct(
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
        ));
        documentList.add(element);
      });
      if (iRet == 0) {
        mdProduct.clear();
        sListData = "ไม่มีรายการ";
        bNoMoreData = true;
        setState(() {});
      }
      if (iRet > 0) {
//        Navigator.pop(context);
        setState(() {});
      }
    });
  }

  setDataListViewScrolling() async {
    bNoMoreData = false;
    int iRet = 0;
    // สำหรับดึงข้อมูล firebase
    await Firestore.instance
        .collection("product")
        .where("date", isEqualTo: dtStartDate.toString().substring(0, 10))
        .orderBy("time", descending: true)
        .startAfterDocument(documentList[documentList.length - 1])
        .limit(10)
        .getDocuments()
        .then((value) {
      iRet = value.documents.length;
      value.documents.forEach((element) {
        String sBarcode = element.data['barcode'];
        String sDate = element.data['date'];
        String sTime = element.data['time'];
        String sCode = element.data['code'];
        String sName = element.data['name'];
        String sGroup = element.data['group'];
        String sImg64 = element.data['image'];
        String sUsername = element.data['username'];
        String sDocID = element.documentID;
        DateTime dtDocDate = DateTime.parse(sDate);
//        DateTime dtDocTime = DateTime.parse(sTime);
        String sThaiMonth =
//            dtDocDate.day.toString() +
//            ' ' +
//            getMonthName(dtDocDate.month) +
//            ' ' +
//            dtDocDate.year.toString() +
//            ' ' +
        sTime;
        String dateFormat = datetimeFormat.format(DateTime(dtDocDate.year,
            dtDocDate.month, dtDocDate.day, dtDocDate.hour, dtDocDate.minute));
        Image itemImage = ImagesConverter.imageFromBase64String(sImg64);
        if (sBarcode == null) sBarcode = '';
        if (sThaiMonth == null) sThaiMonth = '';
        if (sTime == null) sTime = '';
        if (sCode == null) sCode = '';
        if (sName == null) sName = '';
        if (sGroup == null) sGroup = '';
        if (sImg64 == null) sImg64 = '';
        if (sUsername == null) sUsername = '';
        mdProduct.add(ModelProduct(
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
        ));
        documentList.add(element);
      });
    });
    if (iRet == 0) sListData = "ไม่มีรายการ";
    if (iRet == 0) bNoMoreData = true;
    setState(() {});
  }

  processCreateProduct() async {
    sBase64Img = '';
    sBarcode = '';

    String sBase64 = await _imageTakePicture();
    if (sBase64Img != null && sBase64Img != '') {
      await scan();

      if (sBarcode != null && sBarcode != '') {
        int iRet = 0;
        await Firestore.instance
            .collection("product")
            .where("barcode", isEqualTo: sBarcode)
            .getDocuments()
            .then((value) {
          iRet = value.documents.length;
        });
        if (iRet > 0) {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text("รหัสบาร์โค้ดซ้ำ..มีข้อมูลในระบบแล้ว"),
                  actions: <Widget>[
                    FlatButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey,
                        ),
                        label: Text(
                          "ปิด",
                          style: TextStyle(color: Colors.grey),
                        ))
                  ],
                );
              });
        } else {
          String sDate = savedateFormat.format(DateTime.now());
          String sTime = timeFormat.format(DateTime.now());
//      mdProduct.add(ModelProduct(sBarcode,sDate: sDate,sCode: sBarcode,sName: 'ไม่ระบุ',sGroup: 'ไม่ระบุ',sImg64: sBase64Img));
          await repository.addProduct(ModelProduct(sBarcode,
              sDate: sDate,
              sTime: sTime,
              sCode: sBarcode,
              sName: 'ไม่ระบุ',
              sGroup: 'ไม่ระบุ',
              sImg64: sBase64Img,
              sUsername: sUsername));
          setDataListViewFirstTime();
        }
      }
    }
  }

  _imageTakePicture() async {
    var picture = await picker.getImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    ImageResize.Image imageFile =
        ImageResize.decodeJpg(File(picture.path).readAsBytesSync());
    ImageResize.Image thumbnail = ImageResize.copyResize(imageFile, width: 550);
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
  _onClickPushPage(){
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ViewItemPage(sBarcode: sBarcode,);
    },));
  }
  searchData(String search) async {
    await Future.delayed(Duration(milliseconds: 700));

    String sSearchName = searchBar_controller.text;
    if (search.length < 3) {
      sSearchName = "";
    }
    if (search == sSearchName) {
      getDataBySearch(sSearchName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        child:
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.start,
//            children: <Widget>[
//              Row(
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget>[
//                  Expanded(
//                    child: Container(
//                      decoration: BoxDecoration(color: Colors.grey.shade200),
//                      padding: EdgeInsets.all(5),
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Text('วันที่: ' + sFullDate),
//                          Text('ชื่อผู้ใช้งาน: ' + sUsername),
//                        ],
//                      ),
//                    ),
//                  )
//                ],
//              ),
        _buildSuggestions(),
//            ],
//          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => processCreateProduct(),
        tooltip: 'Scan',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar(){
    return AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: GestureDetector(
          child: Text("รายการสินค้า"),
          onTap: () {
            print(dtStartDate.toString().substring(0, 10));
          },
        ));
  }
  Widget _buildSuggestions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
                    Text('ชื่อผู้ใช้งาน: ' + sUsername),
                    buildPickDate(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.shade100,
                            ),
                            alignment: Alignment.center,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (term) {
                                searchData(searchBar_controller.text);
                              },
                              autofocus: false,
                              onChanged: searchData,
                              controller: searchBar_controller,
                              decoration: InputDecoration(
                                hintText: 'คันหาด้วยบาร์โค้ด',
                                prefixIcon: GestureDetector(
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.grey.shade700,
                                  ),
                                  onTap: () {
                                    searchData(searchBar_controller.text);
                                  },
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 13),
                                border: InputBorder.none,
                                suffixIcon: searchBar_controller.text.length > 0
                                    ? IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 15,
                                    color: Colors.grey.shade500,
                                  ),
                                  onPressed: () {
                                    searchBar_controller.clear();
                                    setDataListViewFirstTime();
                                    setState(() {});
                                  },
                                )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        mdProduct.length > 0
            ? Expanded(
          child: new GridView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: mdProduct.length + 1,
            shrinkWrap: true,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (context, i) {
              final index = i;

              if (index >= documentList.length) {
                if (!bNoMoreData) {
                  waitProcess();
                }
              }

              if (mdProduct.length > 0 && index < mdProduct.length) {
                return _buildRow(mdProduct[index], index);
              }
            },
          ),
        )
            : Expanded(
          child: Center(
            child: Text(
              sListData,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        )
      ],
    );
  }

  Widget buildPickDate() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      color: Colors.grey.shade200,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  'เลือกวันที่',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                onTap: () {},
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 5,
                child: DateTimeField(
                  readOnly: true,
                  resetIcon: null,
                  textAlign: TextAlign.center,
                  controller: dateStart_controller,
                  format: dateFormat,
                  style: TextStyle(color: Colors.blue, height: 1.4),
                  onShowPicker: (context, currentValue) async {
                    dtStartDate = DateTime(
                        dtStartDate.year,
                        dtStartDate.month,
                        dtStartDate.day,
                        dtStartDate.hour,
                        dtStartDate.minute,
                        dtStartDate.second);
                    final date = await RoundedDatePicker.show(
                      context,
                      theme: ThemeData(primarySwatch: Colors.red),
                      initialDate: DateTime(
                          dtStartDate.year, dtStartDate.month, dtStartDate.day),
                      locale: Locale("th", "TH"),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      dtStartDate = date;
                      String sThaiMonth = dtStartDate.day.toString() +
                          ' ' +
                          getMonthName(dtStartDate.month) +
                          ' ' +
                          dtStartDate.year.toString();
                      dateStart_controller =
                          TextEditingController(text: sThaiMonth);
                      setDataListViewFirstTime();
                      setState(() {});

                      return DateTime(
                        date.year,
                        date.month,
                        date.day,
                      );
                    } else {
                      String sThaiMonth = dtStartDate.day.toString() +
                          ' ' +
                          getMonthName(dtStartDate.month) +
                          ' ' +
                          dtStartDate.year.toString();
                      dateStart_controller =
                          TextEditingController(text: sThaiMonth);
//                              return DateTime(
//                                  dtStartDate.year,
//                                  dtStartDate.month,
//                                  dtStartDate.day,
//                                  dtStartDate.hour,
//                                  dtStartDate.minute);
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                      size: 15,
                    ),
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.blue,
                      size: 15,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(ModelProduct pair, int index) {
    return Card(
      elevation: 5.0,
      color: Colors.white,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                                child: pair.imageList),
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
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(5),
                                                  topRight:
                                                  Radius.circular(5)),
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
                                      onPressed: () => Navigator.pop(context),
                                      icon: Icon(Icons.close,
                                          color: Colors.grey),
                                      label: Text(
                                        "ยกเลิก",
                                        style: TextStyle(color: Colors.grey),
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
            ),
          ),
          new Container(
            padding: EdgeInsets.only(left: 5),
            child: new Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    pair.sBarcode,
                    overflow: TextOverflow.ellipsis,
                    style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                )
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.only(left: 5),
            child: new Row(
              children: <Widget>[
                Icon(
                  Icons.access_time,
                  size: 15,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  pair.sDate + ' น.',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.only(left: 5,bottom: 10),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Wrap(
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
                ),
                Container(
                  width: 70,
                  height: 30,
                  margin: EdgeInsets.only(right: 5,),
                  child: MaterialButton(
                    color: Colors.red,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Text('data',
                      style: _textStyleButton,
                    ),
                    onPressed: (){
                      _onClickPushPage();
                    },
                  ),
                )
              ],
            )
          ),
        ],
      ),
    );
  }
}
