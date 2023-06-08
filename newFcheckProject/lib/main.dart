import 'dart:convert';
import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
// import 'package:flutter_app_version_checker/flutter_app_version_checker.dart';
import 'package:newfcheckproject/authenticationLogin.dart';
import 'package:newfcheckproject/deviceInfo.dart';
import 'package:newfcheckproject/forIOS.dart';
import 'package:newfcheckproject/offlineDatabase/sqfLiteDatabase.dart';
import 'firebase_options.dart';
import 'home/homeScreen.dart';
import 'officeAndWFH/officeAndWFH.dart';
import 'dashboardPage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();
  //WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Hive.initFlutter();
  await Hive.openBox('LocalStorage');
  await Hive.openBox('DateCorrection');

  //Hive.box("LocalStorage").clear();
/*  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);*/
var type = Hive.box("LocalStorage").get("employees") == null?null:Hive.box("LocalStorage").get("employees")["id"];
  //var type = await DBProvider.db.getEmployeesData("Id");
var platforms  = await deviceinfo("platform");
var initialRoute;
if(platforms.toString().toLowerCase().contains("iphone")){
  initialRoute = type.toString() != "null"?"/homeScreen":"/authenticationLogin";
}else{
  initialRoute = "/forIOS";
}

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // initialRoute:"/homeScreen",
    initialRoute: initialRoute,
    routes: {
      "/authenticationLogin": (context) =>const authenticationLogin(),
      "/homeScreen": (context) => const homeScreen(),
      "/dashboard": (context) => const dashboard(),
      "/forIOS": (context) => const forIOS(),
      //"/officeAndWFH": (context) => const officeAndWFH(),
    },
  ));
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

