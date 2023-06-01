import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:newfcheckproject/home/healthDeclaration.dart';
import 'package:newfcheckproject/home/recordsWidget.dart';
import 'package:newfcheckproject/officeAndWFH/officeAndWFH.dart';
import 'package:newfcheckproject/officeAndWFH/siteWidget.dart';
import 'package:newfcheckproject/offlineDatabase/sqfLiteDatabase.dart';
import 'package:http/http.dart' as http;
import '../officeAndWFH/WFHWidget.dart';
import '../officeAndWFH/officeWidget.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';


class homeScreen extends StatefulWidget {
  const homeScreen({Key? key,}):super(key: key);

  @override
  State<homeScreen> createState() => _homeScreen();
}
class CustomClips extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width / 12, size.height);
    path.lineTo(size.width, 0.0);
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

bool hasInternet = true;

internet(){
  return hasInternet;
}

class _homeScreen extends State<homeScreen> with TickerProviderStateMixin {
  late TabController _Tabcontroller;
  late TabController btnOffice;
  var employeeID = "";


  @override
  void initState() {


    //sessionEmployeeId1(setState);
   // getDataWFH(setState);
    getDataSite(setState);
    getEmployeeId();
    dateTimeNow();

    if(!kIsWeb){
      InternetConnectionChecker().onStatusChange.listen((status) {
        final hhasInternet = status == InternetConnectionStatus.connected;
        if(mounted){
          setState(() => hasInternet = hhasInternet);
          if(hasInternet == true){
            //sessionEmployeeId1(setState);
            // getDataWFH(setState);
            getDataSite(setState);
          }
        }
      });
    }

    if(!kIsWeb){

      FlutterWindowManager.addFlags(
          FlutterWindowManager.FLAG_SECURE);
    }


    _Tabcontroller = TabController(length: 1, vsync: this);
    btnOffice = TabController(length: 2, vsync: this);
    dateTimeCheckerPerDay();

    btnOffice.addListener(() {
      setState(() {
       // OfficeSLider(btnOffice.index);
      });

    });

    super.initState();
  }
  getEmployeeId() async{
    //print("this: ${await sessionEmployeeId()}");
    employeeID =  (await sessionEmployeeId()).toString();
  }

  bool
  homePageNav = false,
  healthdecNav = false,
  recordsNave = false;
  nav(){
    return Drawer(
      elevation: 0,
      child: ListView(
        children: [
           DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Image.asset('assets/Images/appBar.png',),
          ),
          ListTile(
            // shape:const RoundedRectangleBorder(
            //   side: BorderSide(color: Colors.black, width: 1),
            //   borderRadius: BorderRadius.only(
            //       bottomLeft: Radius.circular(1000),
            //   topRight: Radius.circular(1000) ),
            // ),

            tileColor:homePageNav? Colors.blue:Colors.transparent,
            textColor:Colors.blue,
            leading:SizedBox(
              height: 40,
              width: 70,
              child: Row(
                children: [
                  const SizedBox(width: 20,),
                   Icon(
                    Icons.home,
                    size: 50,
                    color: homePageNav? Colors.white: Colors.blue,),
                ],
              ),
            ),
            title: Text("Home",style:
            TextStyle(fontSize: 20,
                color: homePageNav? Colors.white:Colors.blue),),
            onTap: () {
              homePageNav = true;
              healthdecNav = false;
              recordsNave = false;
              dateTimeCheckerPerDay();
              setState(() {
                isSelectedWidget("default");
              });
    },),
         // const SizedBox(height: 5,),
         //  ListTile(
         //
         //    tileColor:healthdecNav? Colors.blue:Colors.transparent,
         //    textColor:Colors.blue,
         //    leading: SizedBox(
         //      height: 40,
         //      width: 70,
         //      child: Row(
         //        children: [
         //          const SizedBox(width: 20,),
         //          Image.asset(
         //            'assets/Images/checks_identity__health_dec_-removebg-preview.png',
         //            height: 45,
         //            color: healthIconColorControoler()? Colors.redAccent:
         //            healthdecNav? Colors.white:Colors.blue,),
         //        ],
         //      ),
         //    ),
         //    title: Text("Health Declaration",style:
         //      TextStyle(fontSize: 20,
         //      color: healthdecNav? Colors.white:Colors.blue),),
         //    onTap: () {
         //      setState((){
         //        homePageNav = false;
         //        healthdecNav = true;
         //        recordsNave = false;
         //        isSelectedWidget("healthCare");
         //      });
         //    },),
          const SizedBox(height: 5,),
          ListTile(
            tileColor:recordsNave? Colors.blue: Colors.transparent,
            textColor:Colors.blue,
            leading: Container(
              height: 40,
              width: 70,
            child: Row(
            children: [
              SizedBox(width: 20,),
    Image.asset('assets/Images/records_time_or_history-removebg-preview.png',
    height: 40,
    color:recordsNave? Colors.white: Colors.blue,)
    ],
    ),
    ),
            title: Text("Records",style:
            TextStyle(fontSize: 20,
            color: recordsNave? Colors.white:Colors.blue),),
            onTap: () {
              setState((){
                homePageNav = false;
                healthdecNav = false;
                recordsNave = true;
                getRecords(setState);
                isSelectedWidget("records");
              });
            },
          ),

        ],
      ),
    );
  }


  ElevatedButton_styleFrom(){
   return ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ) ,
        textStyle:const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold)
    );
  }
  var allAroundNavigator = "";

 void dateTimeCheckerPerDay()async{
var coordinator = "else";
var temp = true;
      try{
        if(/*await DBProvider.db.getEmployeesData("dateTime") != await dateTimeNow()*/temp != temp){
          setState(() {
            coordinator = "if";
            Future.delayed(Duration.zero, () => heathCheckDialog(context,setState,"healthCheckDialog"));
              healthIconColorBool(true);
          });

        }
      }catch (e){
        if(/*await DBProvider.db.getEmployeesData("dateTime") !=
   DateFormat("yyyy/dd/MM").format(DateTime.now()).toString()*/ temp != temp){
          setState(() {
            coordinator = "if";
            Future.delayed(Duration.zero, () => heathCheckDialog(context,setState,"healthCheckDialog"));
             healthIconColorBool(true);
          });
        }
    }
if(coordinator == "else"){
      setState((){
        if(allAroundNavigator == "officeTimeIn/Out"){
          //thisWidget('office');
        Navigator.pushReplacementNamed(context,'/officeAndWFH');
        }
        else if(allAroundNavigator == "workFromHomeIn/Out"){
         // thisWidget('WFH');
          Navigator.pushReplacementNamed(context,'/officeAndWFH');
        }else if(allAroundNavigator == "siteIn/Out"){
       // thisWidget('Site');
        Navigator.pushReplacementNamed(context,'/officeAndWFH');
        }
          healthIconColorBool(false);
      });
      }
  /* await DBProvider.db.dateCorrection(
       DateFormat("yyyy/dd/MM").format(latestDate).toString());*/
  }
  //Image.asset('assets/Images/rash_on_the_skin.png',height: 50, )

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.transparent,
       elevation: 0,
       iconTheme:const IconThemeData(color: Colors.black),
     // actions: [
     //   Row(
     //     children: [
     //       ClipRRect(
     //         borderRadius: BorderRadius.circular(1000),
     //           child: Image.network('${apiLink()}api/FcEmployees?employee=$employeeID',
     //           errorBuilder: (context, error, stackTrace) {
     //             return const Icon(Icons.account_box_rounded);
     //           },
     //         ),
     //       ),
     //      const SizedBox(width: 5,)
     //     ],
     //   ),
     // ],
     ),
     drawer: nav(),
     body: cSelectedWidget() == "default"? Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         children: [
         /* SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 10,
            child: ElevatedButton.icon(onPressed:(){

                allAroundNavigator = "officeTimeIn/Out";
                dateTimeCheckerPerDay();

            },
                style: ElevatedButton_styleFrom(),
              icon: Image.asset('assets/Images/OFFICE-removebg-preview.png',
                  height: 100,
                  color: Colors.white),
                label:const Text("Office",textAlign: TextAlign.center)),
          ),

           SizedBox(
             width: MediaQuery.of(context).size.width * 0.9,
             height: 10,
             child: ElevatedButton.icon(onPressed:(){

               allAroundNavigator = "workFromHomeIn/Out";
               dateTimeCheckerPerDay();

             },
                 style: ElevatedButton_styleFrom(),
                 icon: Image.asset('assets/Images/WFH-removebg-preview.png',
                     height: 100,
                     color: Colors.white, ),
                 label:const Text("WFH",textAlign: TextAlign.center,)),
           ),

           SizedBox(
             width: MediaQuery.of(context).size.width * 0.9,
             height: 10,
             child: ElevatedButton.icon(onPressed:(){

               allAroundNavigator = "siteIn/Out";
               dateTimeCheckerPerDay();

             },
                 style: ElevatedButton_styleFrom(),
                 icon: Image.asset('assets/Images/site-removebg-preview.png',
                     height: 100,
                     color: Colors.white ),
                 label: Text("Site",textAlign: TextAlign.center)),
           ),*/

           TabBar( controller: _Tabcontroller,
             tabs: [
               // Column(children: [
               //   Image.asset('assets/Images/office.png',
               //       height: 50),
               //   Text("OFFICE",style: TextStyle(color: Colors.black),)
               // ],),
               // Column(children: [
               //   Image.asset('assets/Images/WFH.png',
               //       height: 50),
               //   Text("WFH",style: TextStyle(color: Colors.black),)
               // ],),
               Column(children: [
                 Image.asset('assets/Images/Site.png',
                     height: 50),
                 Text("SITE",style: TextStyle(color: Colors.black),)
               ],),
             ],
           ),

           Expanded(
             child: TabBarView(physics: BouncingScrollPhysics(),
                 controller: _Tabcontroller,children: [
               // officeWidget(setState,context,btnOffice),
               // WFHWidget(setState, context),
               siteWidget(setState, context),
             ]),
           )

           // Expanded(
           //   child: TabBarView(physics: BouncingScrollPhysics(),
           //       controller: _Tabcontroller,children: [
           //     // officeWidget(setState,context,btnOffice),
           //     // WFHWidget(setState, context),
           //     siteWidget(setState, context),
           //   ]),
           // )
       ],
       ),
     ):cSelectedWidget() == "records"? SingleChildScrollView(child: recordsWidget(setState,context)):
     SingleChildScrollView(child: healthCare(setState,context)),


   );
  }

}