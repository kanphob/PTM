import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:PTMRacing/AddProductScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Color redColor = Colors.red;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          buttonTheme: ButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            buttonColor: redColor,
            splashColor: Colors.red[300],
          ),
          primarySwatch: redColor,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color whiteColor = Colors.white;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.red[500],Colors.red[100]],
                  begin: Alignment.topRight,
                    end: Alignment.center,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Image.asset('assets/images/logo.png',filterQuality: FilterQuality.high,),
                  ),
                  SizedBox(
                    height: 10,
                  ),
              Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 3,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Center(
                          child: Form(
                            key: _loginFormKey,
                            autovalidate: false,
                            child: new Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Padding(
                                    padding: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    child: Container(
                                      child: Column(
                                        children: <Widget>[
                                          new TextFormField(
                                            controller: usernameController,
                                            autofocus: true,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Color(0xff3e4a59),
                                            ),
                                            decoration: new InputDecoration(
                                                labelText: "ชื่อผู้ใช้งาน*",
                                                errorStyle:
                                                    TextStyle(fontSize: 10),
                                                hintStyle:
                                                    TextStyle(fontSize: 12),
                                                icon: Image.asset(
                                                  "assets/images/user_icon3.png",
                                                  height: 40.0,
                                                  width: 40.0,
                                                  fit: BoxFit.scaleDown,
                                                )),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: (val) => val.length == 0
                                                ? "กรุณาระบุชื่อผู้ใช้งาน."
                                                : null,
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        child: Text("เข้าสู่ระบบ",
                        style: TextStyle(color: whiteColor,fontSize: 18,fontWeight: FontWeight.bold,),
                        ),
                        padding: EdgeInsets.only(top: 10,bottom: 10,left: 20,right: 20),
                        onPressed: (){
                          if (_loginFormKey.currentState.validate()) {
                            Navigator.push(context, MaterialPageRoute(builder: (
                                context) => AddProductScreen(
                              sUsername: usernameController.text,)));
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
        ),
    );
  }
}
