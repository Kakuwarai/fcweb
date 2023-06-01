import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_app_version_checker/flutter_app_version_checker.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:hive/hive.dart';
import 'package:newfcheckproject/home/homeScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
// import 'package:store_redirect/store_redirect.dart';

import '../offlineDatabase/sqfLiteDatabase.dart';

apiLink(){
  return "https://apps.fastlogistics.com.ph/omapi/";
  //return  "https://7b32-203-189-118-147.ngrok-free.app/";
}

List <bool> healthChecker = [
  //Most Common
  false, false,
  //Serious
  false, false, false,
  //Less Common
  false, false, false, false, false,
  //TRAVEL AND EXPOSURE HISTORY
  false, false, false,
];
List <String> HealthText = [
  //Most Common
  "Fever(37.5°C or Higher)",
  "Tiredness",
  //Serious
  "Difficulty of Breathing",
  "Chest Pain or Pressure",
  "Lost of Speech or Movement",
//Less Common
  "Aches and Pain",
  "Sore Throat",
  "Diarrhea",
  "Loss of Taste or Smell",
  "A rash on skin",
  //TRAVEL AND EXPOSURE HISTORY
  "Exposure to cluster of individuals with flu-like illness in household or workplace",
  "Exposure to confirm case of COVID-19",
  "Exposure to suspect case for COVID-19",
  //Others
];
List <String> newImage = [
  'assets/Images/fever.png',
  'assets/Images/tiredness.png',
  'assets/Images/diff_breathing.png',
  'assets/Images/chest_pain.png',
  'assets/Images/loss_of_speech.png',
  'assets/Images/aches_and_pain.png',
  'assets/Images/sore_throat.png',
  'assets/Images/diarrhea.png',
  'assets/Images/loss_of_taste_and_smell.png',
  'assets/Images/rash_on_the_skin.png',
];
 List<Icon> iconsTransportationList = const [
  Icon(Icons.home),
  Icon(Icons.directions_walk),
  Icon(Icons.train),
  Icon(Icons.airport_shuttle),
  Icon(Icons.car_rental),
  Icon(Icons.accessible_outlined),
  Icon(Icons.directions_bike),
  Icon(Icons.motorcycle),
  Icon(Icons.airplanemode_active),
  Icon(Icons.warehouse),
  Icon(Icons.location_off),
  Icon(Icons.telegram),
 ];

 List <String> nameTransportationList = [
   "Home","Walking","Public Transport","Company Shuttle",
   "Carpool","Private Vehicle","Bicycle", "Motorcycle",
   "Ariplane","Working Site","GPS Error","Teleport"

 ];

sessionEmployeeId() async{
  return await Hive.box("LocalStorage").get("employees")["id"];
    //return await DBProvider.db.getEmployeesData("Id");
}
var latestDate;
dateTimeNow()async{
  var ntp;

  if(kIsWeb){
    ntp = DateTime.now();
  }else{
    ntp = await NTP.now();
  }
  latestDate = ntp;
  return DateFormat("yyyy/dd/MM").format(ntp).toString();
}
newdatetime(){
  return latestDate;
}

var  selectedWidget = "default";
 isSelectedWidget(isSelectedWidget){
   if(isSelectedWidget == "default"){
     selectedWidget = "default";
   }
   else if(isSelectedWidget == "healthCare"){
     selectedWidget = "healthCare";
   }
   else if(isSelectedWidget == "records"){
     selectedWidget = "records";
   }
  return selectedWidget;
}

cSelectedWidget(){
  return selectedWidget;
}

bool healthIconColor = false;
healthIconColorControoler(){
  return healthIconColor;
}

healthIconColorBool (bool){
  healthIconColor = bool;
}

bool loading = false;

Widget healthCare(setState,context){
  return WillPopScope( onWillPop:()async{
    setState((){selectedWidget = "default";});
    return cSelectedWidget();

  },child: loading? const Center(child: CircularProgressIndicator()):
  Column(children: [
        //healthDeclarationWidget(setState,context),
    healthDeclarationWidget(setState,context),
            Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: TextButton(onPressed: (){
                heathCheckDialog(context,setState,"healthCheckSubmitDialog");
              }
              , child: const Text("SUBMIT",style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 18,) ) ),
            ),
    const SizedBox(height: 50,)
  ],
              ),);
              }

TextEditingController  otherHealthDec = TextEditingController();

healthDeclarationWidget(setState,context){
  return Column(children: [

    const Text("Health Care"),

    const Text("PART 1. SIGNS AND SYMPTOMS",
      style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold),),

    for(int x=0; x<10;x++)
      Row(children: [
        Image.asset(newImage[x],height: 50, ),
        Expanded(child: Text(HealthText[x])),
        Checkbox(value: healthChecker[x], onChanged: (value){
          setState((){
            healthChecker[x] = value!;
          });
        }),
      ],
      ),
    Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 1,
        color: Colors.black,),
    ),

    const Text("PART 2. TRAVEL AND EXPOSURE HISTORY",
      style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold),),


    for(int x=10; x<13;x++)
      Row(children: [
        Expanded(child: Text(HealthText[x])),
        Checkbox(value: healthChecker[x], onChanged: (value){
          setState((){ healthChecker[x] = value!;});
        }),
      ],
      ),
     const Text("Others",
      style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold),),
    Card(
        color: Colors.grey.shade100,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            controller: otherHealthDec,
            maxLines: 8, //or null
            decoration: const InputDecoration.collapsed(hintText: "Enter your text here"),
          ),
        )
    ),
  ],);
}

transportationWidget(setState,context){
  return Column(children: [
    const Text("\"Method of transportation\""),
  Container(
    width: MediaQuery.of(context).size.width,
  height: 400,
  padding: const EdgeInsets.all(10.0),
  child: GridView.builder(
  itemCount: iconsTransportationList.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 4,
  crossAxisSpacing: 4.0,
  mainAxisSpacing: 4.0
  ),
  itemBuilder: (BuildContext context, int index){
  return Column(children: [
      IconButton(onPressed: (){
  }, icon: iconsTransportationList[index]),
     Text(nameTransportationList[index],textAlign:TextAlign.center ,),
  ],);
  },
  )
  ),

  ],);
}
Future<bool?> heathCheckDialog(BuildContext context,setState,String selector) async {
  if(selector == "healthCheckDialog"){
    showDialog<bool>(barrierDismissible: false,
      context: context,
      builder: (context) =>  AlertDialog(
        title: const Text("please fill your health care or press submit if no internet connection and fill later",style: TextStyle(fontSize: 15),),
        actions: [
          ElevatedButton(onPressed: (){
            setState((){selectedWidget = "healthCare";});
            Navigator.pop(context, true);
            return cSelectedWidget();
          },
              child: const Text('Go')
          ),
        ],
      ),
    );
  }
  else if(selector == "healthCheckSubmitDialog"){
    showDialog<bool>(
      context: context,
      builder: (context) =>  AlertDialog(
        title: const Text("are you sure?",style: TextStyle(fontSize: 15),),
        actions: [
          ElevatedButton(onPressed: (){
            Navigator.pop(context, true);
          },
              child: const Text('No')
          ),
          ElevatedButton(onPressed: () async{
            setState(() {
              loading = true;
            });
            try {
              Navigator.pop(context, true);
              var latestDate = await NTP.now();
              var healthDeclaration = "";

              for (int x = 0; x < healthChecker.length; x++) {
                if (healthChecker[x] == true) {
                  healthDeclaration = "${HealthText[x]},$healthDeclaration";
                }
              }
                        if(otherHealthDec.text.trim() != ""){
                          healthDeclaration = "${otherHealthDec.text},$healthDeclaration";
                        }
              var response = await http.post(
                  Uri.parse("${apiLink()}api/FcHealthDeclarations"),
                  body: {
                    "employeeId": (await sessionEmployeeId()).toString(),
                    "sickString": healthDeclaration,
                  });
              if (response.statusCode == 200) {
                Hive.box('DateCorrection').put("DateCorrection",
                    DateFormat("yyyy/dd/MM").format(latestDate).toString());
               /* await DBProvider.db.dateCorrection(
                    DateFormat("yyyy/dd/MM").format(latestDate).toString());*/
              }

              return setState(() {
                healthIconColorBool(false);
                isSelectedWidget("default");
                cSelectedWidget();
                loading = false;
              });
            }catch(e){
              setState((){
                healthIconColorBool(false);
                isSelectedWidget("default");
                cSelectedWidget();
                loading = false;
              });
            }
          },
              child: const Text('Yes')
          ),
        ],
      ),
    );
  }

    return null;
}

// final _checker = AppVersionChecker();
// void  _checkVersion(context) async {
//   _checker.checkUpdate().then((value) {
//     if(value.canUpdate == true) {
//       showDialog(context: context, builder: (context) =>
//           AlertDialog(
//             title: const Text("Update", style: TextStyle(fontSize: 12),),
//             content:  Text(
//                 "There is an updated version, please update from ${ value.currentVersion} to ${value.newVersion}"),
//             actions: [
//               TextButton(onPressed: () =>
//               {
//                 // _launchUrl(value?.appURL ?? "")
//                 StoreRedirect.redirect(androidAppId: 'com.parkFast.parking_app')
//               }, child: const Text("Update")),
//               TextButton(onPressed: () => SystemNavigator.pop(),
//                   child: const Text("Cancel"))
//             ],
//           ));
//     }else{
//       //checkIfLogged();
//     }
//   });
// }