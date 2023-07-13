import 'dart:html';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:newfcheckproject/deviceInfo.dart';
import 'package:platform_device_id/platform_device_id.dart';

class forIOS extends StatefulWidget {
  const forIOS({
    Key? key,
  }) : super(key: key);

  @override
  State<forIOS> createState() => ForIOS();
}

class ForIOS extends State<forIOS> with TickerProviderStateMixin {

  var platform = "";
  var devices = "";

  @override
  void initState() {
    super.initState();
    device();
  }

  device() async {

       platform = await deviceinfo("platform");

       //devices = await deviceinfo("device");

       if(platform.toString().toLowerCase().contains("iphone")){
         var type = Hive.box("LocalStorage").get("employees") == null?null:Hive.box("LocalStorage").get("employees")["id"];
         Navigator.pushReplacementNamed(context, type.toString() != "null"?"/homeScreen":"/authenticationLogin");
       }
       devices = await Hive.box("LocalStorage").get("test")??"NULL";
       setState(() {
     });

  }

  test()async{
    var rng = await Random();
var newrng = rng.nextInt(100).toString();
    await Hive.box("LocalStorage").put("test", await newrng);
    devices = await newrng;
    print(devices);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "For IOS Users Only!\n${platform}\n${devices}",
            style: TextStyle(fontSize: 30),
          )),
SizedBox(height: 20,),
          TextButton(onPressed: (){test();}, child: Text("click")),
          TextButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
              ),
              onPressed: (){
            window.location.href = 'https://ontime-y07j.onrender.com';
          }, icon: Icon(Icons.android_outlined), label: Text("Download android version here!"))


        ],
      ),
    );
  }
}
