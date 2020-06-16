import 'package:flutter/material.dart';
import 'package:flutterptm/Utils/images.dart';
import 'package:flutterptm/model/model_product.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as ImageResize;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:progress_indicators/progress_indicators.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  int _counter = 0;
  List<ModelProduct> mdProduct = new List();
  String sBarcode = '';
  String sBase64Img = '';
  final picker = ImagePicker();

  @override
  void initState() {
    setDataListView();
    super.initState();
  }

  setDataListView() {
    // สำหรับดึงข้อมูล firebase
    setState(() {});
  }

  processCreateProduct() async {
    Future.delayed(Duration(seconds: 2), () {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("กรุณารอสักครู่.."),
              contentPadding: EdgeInsets.all(0),
              content: JumpingDotsProgressIndicator(
                fontSize: 30.0,
              ),
            );
          });
    });
    await _imageTakePicture();

    if (sBase64Img != null && sBase64Img != '') {
      Navigator.pop(context);
      await scan();
    }
    if (sBarcode != null) {
      mdProduct.add(
          ModelProduct(sBarcode, sBarcode, 'โช๊คอัพ', 'อะไหล่', sBase64Img));

      setState(() {});
    }
  }

  _imageTakePicture() async {
    var picture = await picker.getImage(
        source: ImageSource.camera, maxHeight: 640, maxWidth: 480);
    ImageResize.Image imageFile =
        ImageResize.decodeJpg(File(picture.path).readAsBytesSync());
    ImageResize.Image thumbnail = ImageResize.copyResize(imageFile, width: 300);
    sBase64Img = base64Encode(ImageResize.encodePng(thumbnail));
//    imageProduct = ImagesConverter.imageFromBase64String(sBase64Img);
    setState(() {});
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text("รายการสินค้า"),
      ),
      body: Container(child: _buildSuggestions()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => processCreateProduct(),
        tooltip: 'Scan',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSuggestions() {
    return new GridView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: mdProduct.length,
      gridDelegate:
          new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
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
    );
  }

  Widget _buildRow(ModelProduct pair, int index) {
    return new GestureDetector(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5.0,
        color: Colors.white,
        child: new Column(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                        child:
                            ImagesConverter.imageFromBase64String(pair.sImg64)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: new Container(
                padding: EdgeInsets.only(left: 5),
                child: new Row(
                  children: <Widget>[
                    Text(
                      pair.getBarcode,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
