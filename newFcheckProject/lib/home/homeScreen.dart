import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:newfcheckproject/home/healthDeclaration.dart';
import 'package:newfcheckproject/home/recordsWidget.dart';

import 'package:newfcheckproject/offlineDatabase/sqfLiteDatabase.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:webviewx/webviewx.dart';
import '../deviceInfo.dart';
import '../officeAndWFH/WFHWidget.dart';
import '../officeAndWFH/officeWidget.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';


import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import '../home/healthDeclaration.dart';
import '../home/homeScreen.dart';

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
    forIos();
    var type = Hive.box("LocalStorage").get("employees") == null?null:Hive.box("LocalStorage").get("employees")["id"];

    if(type == null || type == "[]" || type == ""){
      Navigator.of(context).pushReplacementNamed("/authenticationLogin");
    }
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

    locationpermision();
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

  forIos()async{

    var platforms  = await deviceinfo("platform");

    if(!platforms.toString().toLowerCase().contains("iphone")){
      Navigator.pushReplacementNamed(context, "/forIOS");
    }

  }

  locationpermision()async{

    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {

      await Geolocator.requestPermission();

    }
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



  File? _image;
  final imagePicker = ImagePicker();
  List<int>? _selectedFile;
  Uint8List? _bytesData;
  var image, inputimage = false;
  Future getImage (setState,context) async{
    if(kIsWeb){

      try{
        html.FileUploadInputElement uploadInput = html.FileUploadInputElement();

        uploadInput.multiple = false;

        uploadInput.draggable = false;
        uploadInput.click();

        uploadInput.onChange.listen((event) {
          final files = uploadInput.files;
          final file = files![0];
          final reader = html.FileReader();

          reader.onLoadEnd.listen((event) {
            setState(() {
              _bytesData =
                  Base64Decoder().convert(reader.result.toString().split(",").last);

              _selectedFile = _bytesData;

              setState((){inputimage = true;});


              // var modifiedDate = file.lastModifiedDate;
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(
              //     content: Text('mod'),
              //   ),
              // );
              // if((DateTime.now().difference(modifiedDate).inMinutes >= 5) == false){
              //   setState((){inputimage = true;});
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text('true'),
              //     ),
              //   );
              // }else{
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text('false'),
              //     ),
              //   );
              //   Future<bool?> areYouSureDialog(BuildContext context,setState) async {
              //     showDialog<bool>(
              //       context: context,
              //       builder: (context) =>  AlertDialog(
              //         title:  Text("Choose a image that is capture less than 5 minutes ago",style: TextStyle(fontSize: 15),),
              //         actions: [
              //           ElevatedButton(onPressed: (){
              //             Navigator.pop(context, true);
              //           },
              //               child: const Text('Ok')
              //           ),
              //         ],
              //       ),
              //     );
              //     setState((){inputimage = false;});
              //     return null;
              //   }
              //   areYouSureDialog(context, setState);
              // }

            });
          });

          reader.readAsDataUrl(file);



        });
      }catch(e){
        Future<bool?> areYouSureDialog(BuildContext context,setState) async {
          showDialog<bool>(
            context: context,
            builder: (context) =>  AlertDialog(
              title:  Text("error: ${e}",style: TextStyle(fontSize: 15),),
              actions: [
                ElevatedButton(onPressed: (){
                  Navigator.pop(context, true);
                },
                    child: const Text('Ok')
                ),
              ],
            ),
          );
          setState((){inputimage = false;});
          return null;
        }
        areYouSureDialog(context, setState);
      }
    }else{
      image = await imagePicker.pickImage(source: ImageSource.camera,imageQuality: 10);
      setState((){

        _image = File(image.path);
        inputimage = true;
      });
    }


  }

  var dateTimeDate = [];

  var timeIn ="",
      timeOut="",
      totalTime = "";
  List <String> breaks =[
    "","","","","",""
  ];
  List <String> breakTypes =[
    'firstBreakOut',
    'firstBreakIn',
    'secondBreakOut',
    'secondBreakIn',
    'thirdBreakOut',
    'thirdBreakIn',
  ];
  bool breaksStop = false;
  getDataSite(setState)async{
    //await DBProvider.db.getEmployeesData("id");
    breaksStop = false;
    timeIn ="";
    timeOut="";
    totalTime = "";

    var d;

    if(kIsWeb){
      d = DateTime.now();
    }else{
      d = await NTP.now();
    }

    var dateTime = DateFormat("yyyy/MM/dd").format(d).toString();
    var response = await http.post(
        Uri.parse("${apiLink()}api/FcAttendances/gettimeinoutSite"),
        body: {
          "employeeId":Hive.box("LocalStorage").get("employees")["employeeId"].toString(),
          //"employeeId":(await DBProvider.db.getEmployeesData("Id")).toString(),
          "getDate":dateTime
        });

    if (response.statusCode == 200) {
      try{
        dateTimeDate = await jsonDecode(response.body) as List;
        timeIn = dateTimeDate[dateTimeDate.length-1]['timeIn'].toString();
        if(dateTimeDate[dateTimeDate.length-1]['timeOut'].toString() != "null"){
          timeOut = dateTimeDate[dateTimeDate.length-1]['timeOut'].toString();
          totalTime = dateTimeDate[dateTimeDate.length-1]['totalTime'].toString();
        }
        for(int index=0; index <= 5;index++){
          breaks[index] = "";
        }
        for(int index=0; index <= 5;index++){
          if(dateTimeDate[dateTimeDate.length-1][breakTypes[index]].toString() != "null"){
            breaks[index] = dateTimeDate[dateTimeDate.length-1][breakTypes[index]].toString();
          }
        }

        if(breaks[0] != "" && breaks[1] == ""){
          breaksStop = true;

        }
        else if(breaks[2] != "" && breaks[3] == ""){
          breaksStop = true;
        }
        else if(breaks[4] != "" && breaks[5] == ""){
          breaksStop = true;
        }
        setState((){});
      }catch(e){
        print("this is the Error: $e");
      }
      /*location = "${placemarks[0].street},"
        "${placemarks[0].subLocality},"
        "${placemarks[0].locality},";*/
      setState((){});
    }

  }
  var location ="";
  Position position=Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
  List<Placemark> placemarks = [];

  nominatim()async{

    var response = await http.get(Uri.parse("https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json"),
    );

    var temp = jsonDecode(response.body)["display_name"];
    var trimSplit = temp.toString().trim().split(',');
    location = "${trimSplit[0]} ${trimSplit[1]} ${trimSplit[2]} ${trimSplit[3]} ${trimSplit[4]}";
    setState(() {

    });

  }

  main(context) async{


    // LocationPermission permission;
    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //
    //   await Geolocator.requestPermission();
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("loc false"),
    //     ),
    //   );
    //   return false;
    //
    //}else if(permission != LocationPermission.denied){
      try{


        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation);


        await nominatim();


        //print();
        //print("${position.latitude} - ${position.longitude}");

        if(!kIsWeb){

          placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        }else{

          // var response = await http.get(Uri.parse("https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json"),
          // ).catchError((Object error, StackTrace stackTrace) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: Text(error.toString()),
          //     ),
          //   );
          // });


          // var temp = jsonDecode(response.body)["display_name"];
          // var trimSplit = temp.toString().trim().split(',');
          // location = "${trimSplit[0]} ${trimSplit[1]} ${trimSplit[2]} ${trimSplit[3]} ${trimSplit[4]}";

        }


      }catch(e){
        //print(e);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text("catch: ${e.toString()}"),
          ),
        );
        return false;
      }

      return true;
    //}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("loc false"),
      ),
    );
    return false;

  }

  Future<bool?> areYouSureDialog(BuildContext context,setState, var content) async {
    showDialog<bool>(
      context: context,
      builder: (context) =>  AlertDialog(
        title:  Text("Do you want to ${content == "timeIn"? "time in": "time out"}?",style: TextStyle(fontSize: 15),),
        actions: [
          ElevatedButton(onPressed: (){
            Navigator.pop(context, true);
          }, style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Background color
          ),
              child: const Text('No')
          ),
          ElevatedButton(onPressed: () async{
            Navigator.pop(context, true);
            if(content == "timeIn"){

              if(internet() == false){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No internet Connection'),
                  ),
                );
              }else {

                setState(() {
                  waiting = true;
                });
                if (inputimage == true && await main(context) == true) {

                  //var allData = await DBProvider.db.getAllData();
                  //var allData = Hive.box("LocalStorage").get("employees");
                  await main(context);

                  var datetimenow;
                  if(kIsWeb){
                    datetimenow = DateTime.now();
                  }else{
                    datetimenow = await NTP.now();
                  }


                  var request = http.MultipartRequest('POST',
                      Uri.parse("${apiLink()}api/FcAttendances/uploadFile"));

                  // request.fields['employeeId'] =
                  //     (allData[0]['employeeId']).toString();
                  request.fields['employeeId'] =
                      Hive.box("LocalStorage").get("employees")['employeeId'].toString();
                  request.fields['workPlace'] = "Site";
                  request.fields['TimeIn'] =
                      DateFormat("hh:mm a").format(datetimenow).toString();
                  request.fields['LocationIn'] = placemarks.toString() == "[]" ||placemarks == null ? location :"${placemarks[0].street},"
                      "${placemarks[0].subLocality},"
                      "${placemarks[0].locality},"
                      "${placemarks[0].administrativeArea},"
                      "${placemarks[0].country}";
                  // request.fields['department'] = allData[0]['department'];
                  // request.fields['sbu'] = allData[0]['sbu'];
                  request.fields['department'] = Hive.box("LocalStorage").get("employees")['department'];
                  request.fields['sbu'] = Hive.box("LocalStorage").get("employees")['sbu'];
                  request.fields['date'] =
                      DateFormat("yyyy/MM/dd").format(datetimenow).toString();
                  // request.fields['folder'] =
                  //     (allData[0]['employeeId']).toString();
                  request.fields['folder'] =
                      (Hive.box("LocalStorage").get("employees")['employeeId']).toString();
                  request.fields['fileName'] =
                      DateFormat("yyyy dd MM").format(datetimenow).toString();
                  request.fields['LatLongIn'] =
                  "${position.latitude.toString()}-${position.longitude
                      .toString()}";

                  // var file = await http.MultipartFile.fromPath(
                  //   'file',
                  //   _image!.path,
                  // );
                  //
                  if(kIsWeb){
                    request.files.add(http.MultipartFile.fromBytes('uploadAttachments', _selectedFile!,
                        contentType: MediaType('application', 'json'), filename: "Any_name"));

                  }else{
                    request.files.add(http.MultipartFile.fromBytes(
                        "uploadAttachments",
                        File(_image!.path).readAsBytesSync(),
                        contentType: MediaType('application','json'),
                        filename: _image!.path));
                  }



                  var res = await request.send();


                  if(!kIsWeb){
                    location = "${placemarks[0].street},"
                        "${placemarks[0].subLocality},"
                        "${placemarks[0].locality},";
                  }

                  getDataSite(setState);
                  inputimage = false;
                }else{
                  waiting = false;
                  setState((){});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please insert image'),
                    ),
                  );
                }
                setState(() {
                  waiting = false;
                });
              }
            }
            else if(content == "timeOut"){
              if(internet() == false){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No internet connection'),
                  ),
                );
              }else{
                setState((){ waiting = true;});
                if(inputimage == true && await main(context) == true){
                  //var allData = await DBProvider.db.getAllData();
                  //var allData = Hive.box("LocalStorage").get("employees");

                  var datetimenow;

                  if(kIsWeb){
                    datetimenow = DateTime.now();
                  }else{
                    datetimenow = await NTP.now();
                  }

                  var request = http.MultipartRequest('POST', Uri.parse(
                      "${apiLink()}api/FcAttendances/uploadFileTimeOut"));
                  request.fields['folder'] =
                      (Hive.box("LocalStorage").get("employees")['employeeId']).toString();
                  request.fields['fileName'] = DateFormat("yyyy dd MM").format(datetimenow).toString();
                  request.fields['timeOut'] = DateFormat("hh:mm a").format(datetimenow).toString();
                  request.fields['employeeId'] =
                      Hive.box("LocalStorage").get("employees")['employeeId'].toString();
                  request.fields['getdate'] = DateFormat("yyyy/MM/dd").format(datetimenow).toString();
                  request.fields['LocationOut'] = placemarks.toString() == "[]" ||placemarks == null ? location :"${placemarks[0].street},"
                      "${placemarks[0].subLocality},"
                      "${placemarks[0].locality},"
                      "${placemarks[0].administrativeArea},"
                      "${placemarks[0].country}";;
                  request.fields['latLongOut'] = "${position.latitude.toString()}-${position.longitude.toString()}";
                  if(kIsWeb){

                    request.files.add(http.MultipartFile.fromBytes('uploadAttachments', _selectedFile!,
                        contentType: MediaType('application', 'json'), filename: "Any_name"));

                  }else{
                    request.files.add(http.MultipartFile.fromBytes(
                        "uploadAttachments",
                        File(_image!.path).readAsBytesSync(),
                        contentType: MediaType('application','json'),
                        filename: _image!.path));
                  }

                  var res = await request.send();
                  if(!kIsWeb){
                    location = "${placemarks[0].street},"
                        "${placemarks[0].subLocality},"
                        "${placemarks[0].locality},";
                  }
                  getDataSite(setState);
                  inputimage =false;
                }else{
                  setState((){ waiting = false;});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please insert image'),
                    ),
                  );
                }
                setState((){ waiting = false;});
              }
            }


          }, style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Background color
          ),
              child: const Text('Yes')
          ),
        ],
      ),
    );

    return null;
  }

  Future<bool?> perms(BuildContext context) async {
    showDialog<bool>(
      context: context,
      builder: (context) =>  AlertDialog(
        title: const Text("Please turn on permission location access?",style: TextStyle(fontSize: 15),),
        actions: [

          ElevatedButton(onPressed: () async{

            await Geolocator.openAppSettings();
            await Geolocator.openLocationSettings();
            Navigator.pop(context, true);
          },
              child: const Text('Open')
          ),
        ],
      ),
    );

    return null;
  }

  bool waiting = false;
bool isDrawerOpen = false;


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
       onDrawerChanged: (isOpen) {
         // write your callback implementation here
       setState(() {
         if(isOpen == true){
           isDrawerOpen = true;
         }else{
           isDrawerOpen = false;
         }
       });
       },
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
              if(isDrawerOpen == false)
                   WebViewX(
                     initialContent: 'https://apps.fastlogistics.com.ph/ontime/timeinandout/#/?'
                         'id=${Hive.box("LocalStorage").get("employees")['employeeId'].toString()}'
                         '&department=${Hive.box("LocalStorage").get("employees")['department']}'
                         '&sbu=${Hive.box("LocalStorage").get("employees")['sbu']}'
                         '&folder=${(Hive.box("LocalStorage").get("employees")['employeeId']).toString()}'
                         '&fileName=${DateFormat("yyyy dd MM").format(DateTime.now()).toString()}',
                     width: MediaQuery.of(context).size.width,
                     height: MediaQuery.of(context).size.height,
                   ),

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