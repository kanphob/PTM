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
  TextStyle _textStyleLabel = TextStyle(color: Colors.black,fontSize: 18);
  TextStyle _textStyleData = TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold);
  TextStyle _textStyleAppBar = TextStyle(fontWeight: FontWeight.bold);
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
      if(image  != null && sImg64 != null) {
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
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[500],Colors.red[100]],
                begin: Alignment.topRight,
                end: Alignment.center,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10,bottom: 15),
                  child: _buildShowImage(),
                ),
                _buildShowDetail()
              ],
            ),
          ),
          floatingActionButton: _buildButtonEdit(),
        ),
    );
  }
  Widget _buildAppBar(){
    return AppBar(
        centerTitle: true,
        elevation: 5,
        title: Text("รายการสินค้า",
        style: _textStyleAppBar,
        ),
    );
  }
  Widget _buildShowImage(){
    return InkWell(
      child: new Hero(
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.red[600],width: 5)),
          child: image
        ),
        tag: widget.sBarcode,
      ),
      onTap: () {
        Navigator.of(context).push(
            new PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) {
              return new Material(
                  color: Colors.black38,
                  child: new Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                    ),
                    child: new InkWell(
                      child: new Hero(
                        child: image,
                        tag: widget.sBarcode,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ));
            }));
      },
    );
  }
  Widget _buildShowDetail(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: 7,bottom: 7),
          margin: EdgeInsets.only(bottom: 5),
          child: Container(
            margin: EdgeInsets.only(left: 15,right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child:
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'ชื่อสินค้า : ',
                            style: _textStyleLabel,
                          ),
                          TextSpan(
                            text: sNames,
                            style: _textStyleData,
                          ),
                        ]
                    ),
                  ),
                ),
                Expanded(
                  child:
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'ชื่อผู้บันทึก : ',
                            style: _textStyleLabel,
                          ),
                          TextSpan(
                            text: sUserName,
                            style: _textStyleData,
                          ),
                        ]
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.grey[300],
          padding: EdgeInsets.only(top: 7,bottom: 7),
          margin: EdgeInsets.only(bottom: 5),
          child: Container(
            margin: EdgeInsets.only(left: 15,right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child:
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'ประเภทสินค้า : ',
                            style: _textStyleLabel,
                          ),
                          TextSpan(
                            text: sGroups,
                            style: _textStyleData,
                          ),
                        ]
                    ),
                  ),
                ),
                Expanded(
                  child:
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'เวลาที่บันทึก : ',
                            style: _textStyleLabel,
                          ),
                          TextSpan(
                            text: sThaiMonths,
                            style: _textStyleData,
                          ),
                        ]
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: EdgeInsets.only(top: 7,bottom: 7),
          margin: EdgeInsets.only(bottom: 5),
          child: Container(
            margin: EdgeInsets.only(left: 15,right: 15),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'รหัสสินค้า : ',
                      style: _textStyleLabel,
                    ),
                    TextSpan(
                      text: sCodes,
                      style: _textStyleData,
                    ),
                  ]
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildButtonEdit(){
    return FloatingActionButton.extended(
      icon: Icon(Icons.create),
      label: Text("แก้ไขข้อมูลสินค้า"),
      elevation: 5,
      onPressed: () {
        _onClickButtonEdit();
      },
    );
  }
  _onClickButtonEdit(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.only(top: 10,bottom: 10,right: 10,left: 10),
          actionsPadding: EdgeInsets.only(top: 5,bottom: 5,right: 10,left: 10),
          buttonPadding: EdgeInsets.only(top: 5,bottom: 5,),
          title: new Text("กำลังพัฒนา..",),
//          content: new Container(
//            alignment: Alignment.center,
//            child: Text("กำลังพัฒนา..",),
//          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
