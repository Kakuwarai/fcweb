//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:hive/hive.dart';
// import 'package:http/http.dart' as http;
// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'package:http_parser/http_parser.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:ntp/ntp.dart';
// import '../home/healthDeclaration.dart';
// import '../home/homeScreen.dart';
//
// //uploadFile
// File? _image;
// final imagePicker = ImagePicker();
// List<int>? _selectedFile;
// Uint8List? _bytesData;
// var image, inputimage = false;
// Future getImage (setState,context) async{
//   if(kIsWeb){
//
//     html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
//     uploadInput.multiple = false;
//     uploadInput.draggable = false;
//     uploadInput.click();
//
//     uploadInput.onChange.listen((event) {
//       final files = uploadInput.files;
//       final file = files![0];
//       final reader = html.FileReader();
//
//       reader.onLoadEnd.listen((event) {
//         setState(() {
//           _bytesData =
//               Base64Decoder().convert(reader.result.toString().split(",").last);
//           _selectedFile = _bytesData;
//
//           var modifiedDate = file.lastModifiedDate;
//
//           if((DateTime.now().difference(modifiedDate).inMinutes >= 5) == false){
//             setState((){inputimage = true;});
//           }else{
//             Future<bool?> areYouSureDialog(BuildContext context,setState) async {
//               showDialog<bool>(
//                 context: context,
//                 builder: (context) =>  AlertDialog(
//                   title:  Text("Choose a image that is capture less than 5 minutes ago",style: TextStyle(fontSize: 15),),
//                   actions: [
//                     ElevatedButton(onPressed: (){
//                       Navigator.pop(context, true);
//                     },
//                         child: const Text('Ok')
//                     ),
//                   ],
//                 ),
//               );
//               setState((){inputimage = false;});
//               return null;
//             }
//             areYouSureDialog(context, setState);
//           }
//
//         });
//       });
//
//       reader.readAsDataUrl(file);
//
//
//
//     });
//   }else{
//     image = await imagePicker.pickImage(source: ImageSource.camera,imageQuality: 10);
//     setState((){
//
//       _image = File(image.path);
//       inputimage = true;
//     });
//   }
//
//
// }
//
// var dateTimeDate = [];
//
// var timeIn ="",
//     timeOut="",
//     totalTime = "";
// List <String> breaks =[
//   "","","","","",""
// ];
// List <String> breakTypes =[
//   'firstBreakOut',
//       'firstBreakIn',
//       'secondBreakOut',
//       'secondBreakIn',
//       'thirdBreakOut',
//       'thirdBreakIn',
// ];
// bool breaksStop = false;
// getDataSite(setState)async{
//   //await DBProvider.db.getEmployeesData("id");
//   breaksStop = false;
//   timeIn ="";
//   timeOut="";
//   totalTime = "";
//
//   var d;
//
//   if(kIsWeb){
//   d = DateTime.now();
//   }else{
//     d = await NTP.now();
//   }
//   print("asdasd: ${Hive.box("LocalStorage").get("employees")}");
//   var dateTime = DateFormat("yyyy/MM/dd").format(d).toString();
//   var response = await http.post(
//       Uri.parse("${apiLink()}api/FcAttendances/gettimeinoutSite"),
//       body: {
//         "employeeId":Hive.box("LocalStorage").get("employees")["employeeId"].toString(),
//         //"employeeId":(await DBProvider.db.getEmployeesData("Id")).toString(),
//         "getDate":dateTime
//       });
//
//   if (response.statusCode == 200) {
//     try{
//       dateTimeDate = await jsonDecode(response.body) as List;
//       timeIn = dateTimeDate[dateTimeDate.length-1]['timeIn'].toString();
//       if(dateTimeDate[dateTimeDate.length-1]['timeOut'].toString() != "null"){
//         timeOut = dateTimeDate[dateTimeDate.length-1]['timeOut'].toString();
//         totalTime = dateTimeDate[dateTimeDate.length-1]['totalTime'].toString();
//       }
// for(int index=0; index <= 5;index++){
//   breaks[index] = "";
// }
//       for(int index=0; index <= 5;index++){
//         if(dateTimeDate[dateTimeDate.length-1][breakTypes[index]].toString() != "null"){
//           breaks[index] = dateTimeDate[dateTimeDate.length-1][breakTypes[index]].toString();
//         }
//       }
//
//       if(breaks[0] != "" && breaks[1] == ""){
//         breaksStop = true;
//
//       }
//       else if(breaks[2] != "" && breaks[3] == ""){
//         breaksStop = true;
//       }
//       else if(breaks[4] != "" && breaks[5] == ""){
//         breaksStop = true;
//       }
//       setState((){});
//     }catch(e){
// print("this is the Error: $e");
//     }
//     /*location = "${placemarks[0].street},"
//         "${placemarks[0].subLocality},"
//         "${placemarks[0].locality},";*/
//     setState((){});
//   }
//
// }
// var location ="";
// Position position=Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
// List<Placemark> placemarks = [];
// main(context) async{
//
//   LocationPermission permission;
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//
//     await Geolocator.requestPermission();
//
//     return false;
//
//   }else if(permission != LocationPermission.denied){
//     try{
//
//
//        position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.bestForNavigation);
//        var response = await http.get(Uri.parse("https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json"),
//            );
//
//    //print();
//    print("${position.latitude} - ${position.longitude}");
//
//        if(!kIsWeb){
//          placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//        }else{
//          var temp = jsonDecode(response.body)["display_name"];
//          var trimSplit = temp.toString().trim().split(',');
//          location = "${trimSplit[0]} ${trimSplit[1]} ${trimSplit[2]} ${trimSplit[3]} ${trimSplit[4]}";
//        }
//
//
//     }catch(e){
//       print(e);
//       return false;
//     }
//     return true;
//   }
//
// return false;
//
// }
//
// Future<bool?> areYouSureDialog(BuildContext context,setState, var content) async {
//   showDialog<bool>(
//     context: context,
//     builder: (context) =>  AlertDialog(
//       title:  Text("Do you want to ${content == "timeIn"? "time in": "time out"}?",style: TextStyle(fontSize: 15),),
//       actions: [
//         ElevatedButton(onPressed: (){
//           Navigator.pop(context, true);
//         },
//             child: const Text('No')
//         ),
//         ElevatedButton(onPressed: () async{
//           Navigator.pop(context, true);
//           if(content == "timeIn"){
//
//             if(internet() == false){
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('No internet connection'),
//                 ),
//               );
//             }else {
//               setState(() {
//                 waiting = true;
//               });
//               if (inputimage == true && await main(context) == true) {
//                 //var allData = await DBProvider.db.getAllData();
//                 var allData = Hive.box("LocalStorage").get("employees");
//                 print(allData);
//                 await main(context);
//                 var datetimenow;
//                 if(kIsWeb){
//
//
//           datetimenow = DateTime.now();
//                 }else{
//           datetimenow = await NTP.now();
//                 }
//
//
//                 var request = http.MultipartRequest('POST',
//                     Uri.parse("${apiLink()}api/FcAttendances/uploadFile"));
//                 // request.fields['employeeId'] =
//                 //     (allData[0]['employeeId']).toString();
//                 request.fields['employeeId'] =
//                     Hive.box("LocalStorage").get("employees")['employeeId'].toString();
//                 request.fields['workPlace'] = "Site";
//                 request.fields['TimeIn'] =
//                     DateFormat("hh:mm a").format(datetimenow).toString();
//                 request.fields['LocationIn'] = placemarks.toString() == "[]" ||placemarks == null ? location :"${placemarks[0].street},"
//                     "${placemarks[0].subLocality},"
//                     "${placemarks[0].locality},"
//                     "${placemarks[0].administrativeArea},"
//                     "${placemarks[0].country}";
//                 // request.fields['department'] = allData[0]['department'];
//                 // request.fields['sbu'] = allData[0]['sbu'];
//                 request.fields['department'] = Hive.box("LocalStorage").get("employees")['department'];
//                 request.fields['sbu'] = Hive.box("LocalStorage").get("employees")['sbu'];
//                 request.fields['date'] =
//                     DateFormat("yyyy/MM/dd").format(datetimenow).toString();
//                 // request.fields['folder'] =
//                 //     (allData[0]['employeeId']).toString();
//                 request.fields['folder'] =
//                     (Hive.box("LocalStorage").get("employees")['employeeId']).toString();
//                 request.fields['fileName'] =
//                     DateFormat("yyyy dd MM").format(datetimenow).toString();
//                 request.fields['LatLongIn'] =
//                 "${position.latitude.toString()}-${position.longitude
//                     .toString()}";
//
//                 // var file = await http.MultipartFile.fromPath(
//                 //   'file',
//                 //   _image!.path,
//                 // );
//                 //
//                 if(kIsWeb){
//                   request.files.add(http.MultipartFile.fromBytes('uploadAttachments', _selectedFile!,
//                       contentType: MediaType('application', 'json'), filename: "Any_name"));
//                 }else{
//                   request.files.add(http.MultipartFile.fromBytes(
//                       "uploadAttachments",
//                       File(_image!.path).readAsBytesSync(),
//                       contentType: MediaType('application','json'),
//                       filename: _image!.path));
//                 }
//
//
//
//                 var res = await request.send();
//   if(!kIsWeb){
//     location = "${placemarks[0].street},"
//         "${placemarks[0].subLocality},"
//         "${placemarks[0].locality},";
//   }
//
//                 getDataSite(setState);
//                 inputimage = false;
//               }else{
//                 waiting = false;
//                 setState((){});
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Please insert image'),
//                   ),
//                 );
//               }
//               setState(() {
//                 waiting = false;
//               });
//             }
//           }
//           else if(content == "timeOut"){
//             if(internet() == false){
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('No internet connection'),
//                 ),
//               );
//             }else{
//               setState((){ waiting = true;});
//               if(inputimage == true && await main(context) == true){
//                 //var allData = await DBProvider.db.getAllData();
//                 var allData = Hive.box("LocalStorage").get("employees");
//                 var datetimenow = await NTP.now();
//                 var request = http.MultipartRequest('POST', Uri.parse(
//                     "${apiLink()}api/FcAttendances/uploadFileTimeOut"));
//                 request.fields['folder'] = (allData[0]['employeeId']).toString();
//                 request.fields['fileName'] = DateFormat("yyyy dd MM").format(datetimenow).toString();
//                 request.fields['timeOut'] = DateFormat("hh:mm a").format(datetimenow).toString();
//                 request.fields['employeeId'] = (allData[0]['employeeId']).toString();
//                 request.fields['getdate'] = DateFormat("yyyy/MM/dd").format(datetimenow).toString();
//                 request.fields['LocationOut'] = "${placemarks[0].street},"
//                     "${placemarks[0].subLocality},"
//                     "${placemarks[0].locality},"
//                     "${placemarks[0].administrativeArea},"
//                     "${placemarks[0].country}";
//                 request.fields['latLongOut'] = "${position.latitude.toString()}-${position.longitude.toString()}";
//                 request.files.add(http.MultipartFile.fromBytes(
//                     "uploadAttachments",
//                     File(_image!.path).readAsBytesSync(),
//                     filename: _image!.path));
//
//                 var res = await request.send();
//                 if(!kIsWeb){
//                   location = "${placemarks[0].street},"
//                       "${placemarks[0].subLocality},"
//                       "${placemarks[0].locality},";
//                 }
//                 getDataSite(setState);
//                 inputimage =false;
//               }else{
//                 setState((){ waiting = false;});
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Please insert image'),
//                   ),
//                 );
//               }
//               setState((){ waiting = false;});
//             }
//           }
//
//
//         },
//             child: const Text('Yes')
//         ),
//       ],
//     ),
//   );
//
//   return null;
// }
//
// Future<bool?> perms(BuildContext context) async {
//   showDialog<bool>(
//     context: context,
//     builder: (context) =>  AlertDialog(
//       title: const Text("Please turn on permission location access?",style: TextStyle(fontSize: 15),),
//       actions: [
//
//         ElevatedButton(onPressed: () async{
//
//           await Geolocator.openAppSettings();
//           await Geolocator.openLocationSettings();
//           Navigator.pop(context, true);
//         },
//             child: const Text('Open')
//         ),
//       ],
//     ),
//   );
//
//   return null;
// }
//
// bool waiting = false;
// siteWidget(setState,context){
//   return SingleChildScrollView(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
// /*Center(
//     child: _image == null? Text("no image"): Image.file(_image!),
// ),*/
//         SizedBox(
//           height: inputimage?500:400,
//           width: inputimage?500:400,
//           child:  IconButton(onPressed: (){
//             getImage(setState,context);
//           },
//               icon: inputimage?
//               (kIsWeb == true? Image.memory(_bytesData!): Image.file(_image!)):
//               Image.asset('assets/Images/camera.png',) ),),
//
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.location_on,color: Colors.red,),
//             SizedBox(
//               width: MediaQuery.of(context).size.width * 0.7,
//               child: Expanded(
//                 child: Text(timeIn == "--:--"? "" :
//                 location),
//               ),
//             ),
//           ],),
//         SizedBox(height: 20,),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//           ElevatedButton.icon(
//               style:ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 side:const BorderSide(color: Colors.black)
//               )
//
//               ,onPressed:timeIn !=  ""  || waiting? null:()async{
//
//             areYouSureDialog(context,setState,"timeIn");
//
//           }, icon:const Icon(Icons.timer_sharp,color: Colors.blue,),
//               label: Text(waiting?"Please Wait.." :
//               timeIn != "null" && timeIn !=  "" ? timeIn : "Time In",
//                 style:const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
//
//           ElevatedButton.icon(
//     style:ElevatedButton.styleFrom(
//     backgroundColor: Colors.transparent,
//     elevation: 0,
//     side:const BorderSide(color: Colors.black)
//     ),
//               onPressed: timeIn ==  "" || (timeOut != "null" && timeOut !=  "") || waiting ? null:()async{
//
//                 areYouSureDialog(context,setState,"timeOut");
//
//                 }, icon:const Icon(Icons.timer_off_outlined,color: Colors.red,),
//               label: Text(waiting ?"please wait..." :
//               timeOut != "null" && timeOut !=  "" ? timeOut : "Time Out",
//                 style:const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
//
//         ],),
//
//
// //     Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //       children: [
// //         ElevatedButton.icon(
// //             style:ElevatedButton.styleFrom(
// //                 backgroundColor: breaksStop ? Colors.red:Colors.transparent,
// //                 elevation: 0,
// //                 side:const BorderSide(color: Colors.black)
// //             )
// //
// //             ,onPressed: ()async{
// //           var datetimenow = await NTP.now();
// //           var allData = await DBProvider.db.getAllData();
// //           var response = await http.post(
// //               Uri.parse("${apiLink()}api/FcAttendances/siteBreak"),
// //               body: {
// //                 "employeeId":(allData[0]['employeeId']).toString(),
// //                 "time":DateFormat("hh:mm a").format(datetimenow).toString(),
// //
// //               });
// //           if(response.statusCode == 200){
// //             getDataSite(setState);
// // print("success!");
// //           }
// //
// //         }, icon: Icon(Icons.free_breakfast_outlined,color: breaksStop? Colors.white:Colors.blue,),
// //             label: Text(breaksStop ? "Stop!":"Break",
// //               style: TextStyle(color: breaksStop ? Colors.white:Colors.black,
// //                   fontWeight: FontWeight.bold),)),
// //       ],
// //     ),
//         // Row(
//         //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         //   children: [
//         //     if(breaks[0] != "" && breaks[1] != "")...[
//         //
//         //       Text("1st Break: ${
//         //           (DateFormat("hh:mma").parse(breaks[1].replaceAll(' ', '').toUpperCase())
//         //               .difference(
//         //               DateFormat("hh:mma").parse(breaks[0].replaceAll(' ', '').toUpperCase())
//         //           )).inMinutes
//         //
//         //       } Min"),
//         //
//         //       if(breaks[2] != "" && breaks[3] != "")...[
//         //
//         //         Text("2nd Break: ${
//         //             (DateFormat("hh:mma").parse(breaks[3].replaceAll(' ', '').toUpperCase())
//         //                 .difference(
//         //                 DateFormat("hh:mma").parse(breaks[2].replaceAll(' ', '').toUpperCase())
//         //             )).inMinutes
//         //
//         //         } Min"),
//         //
//         //         if(breaks[4] != "" && breaks[5] != "")...[
//         //
//         //           Text("3rd Break: ${
//         //               (DateFormat("hh:mma").parse(breaks[5].replaceAll(' ', '').toUpperCase())
//         //                   .difference(
//         //                   DateFormat("hh:mma").parse(breaks[4].replaceAll(' ', '').toUpperCase())
//         //               )).inMinutes
//         //
//         //           } Min")
//         //
//         //         ],
//         //       ],
//         //
//         //     ],
//         //
//         //   ],
//         // ),
//
//         Column(children: [
//           const Icon(Icons.lock_clock,color: Colors.green,),
//           Text(totalTime!=""&&totalTime!="null"? totalTime:"--:--"),
//         ],),
//
//       ],
//     ),
//   );
// }