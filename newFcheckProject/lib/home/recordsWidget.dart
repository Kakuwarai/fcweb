import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../offlineDatabase/sqfLiteDatabase.dart';
import 'healthDeclaration.dart';

var records =[];
getRecords(setState)async{
  var response = await http.post(
      Uri.parse("${apiLink()}api/FcAttendances/getEmployeeRecords"),
      body: {
        "employeeId":Hive.box("LocalStorage").get("employees")["employeeId"].toString()
        //"employeeId":(await DBProvider.db.getEmployeesData("Id")).toString(),
      });

  if (response.statusCode == 200) {
      records = await jsonDecode(response.body) as List;
      setState((){});
  }
}

recordsWidget(setState,context){
  return Column(
    children: [
      /*SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: <Widget>[
            for(int index=0; index<records.length;index++)
            Container(
              height: 10000,
              padding: const EdgeInsets.all(8),
              color: Colors.blue,
              child: Text("Type: ${records[index]["workPlace"]}\n\n"

                  "Time In: ${records[index]["timeIn"]}\n\n"

                  "Time Out:${records[index]["timeOut"]}\n\n"

                  "Total Time: ${records[index]["totalTime"]}\n\n"

                  "Location: ${records[index]["location"]}\n\n"

                  "Date: ${records[index]["date"]}"),
            ),
          ],
        ),
      )*/

      if(records.length == 0)...[
 Container(
   height: MediaQuery.of(context).size.height,
   child:const Center(child: Text("No Records", style: TextStyle(fontSize: 50,color: Colors.black54))),

 )
      ]
      else...[


      SizedBox(
        height: MediaQuery.of(context).size.height*0.9,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
            itemCount:records.length,
            itemBuilder: (context, index){
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all()
          ),
          child: Column(
            children: [
            Container(
              decoration:const BoxDecoration(
                border:Border(
                  bottom: BorderSide(width: 1, color: Colors.black),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(records[index]["workPlace"],style:const TextStyle(color: Colors.black,
                  fontWeight: FontWeight.bold),),
                  Text(DateFormat("MM/dd/yyyy").format(DateTime.parse(records[index]["date"])).toString()
                      ,style:const TextStyle(color: Colors.black,
                          fontWeight: FontWeight.bold)),
              ],),
            ),
              SizedBox(height: 20,),
            //Text(records[index]["workPlace"],style: TextStyle(color: Colors.white),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                Column(children: [
                 const Icon(Icons.timer_sharp,color: Colors.blue,),
                  Text("${records[index]["timeIn"]}",style:const TextStyle(color: Colors.black,
                      fontWeight: FontWeight.bold)),
                ],),

                Column(children: [
                   const Icon(Icons.timer_off_outlined,color: Colors.red,),
                    Text("${records[index]["timeOut"]}",style:const TextStyle(color: Colors.black,
                        fontWeight: FontWeight.bold)),
                  ],),

                Column(children: [
                     const Icon(Icons.lock_clock,color: Colors.green,),
                      Text("${records[index]["totalTime"]}",style:const TextStyle(color: Colors.black,
                          fontWeight: FontWeight.bold)),
                    ],),
              ],),

            SizedBox(height: 20,),

            Row(children: [
             const Icon(Icons.location_on,color: Colors.blue,),
              Expanded(child:
              Text("${records[index]["locationIn"]}",style:
              TextStyle(color: Colors.black,
                  fontWeight: FontWeight.bold))),
            ],),
              SizedBox(height: 20,),

              Row(children: [
                const Icon(Icons.location_on,color: Colors.red,),
                Expanded(child:
                Text("${records[index]["locationOut"]}",style:
                TextStyle(color: Colors.black,
                    fontWeight: FontWeight.bold))),
              ],),
              SizedBox(height: 10,),
            //Text(records[index]["department"],style: TextStyle(color: Colors.white)),
            //Text(records[index]["sbu"],style: TextStyle(color: Colors.white)),
            //Text(records[index]["date"],style: TextStyle(color: Colors.white)),
          ],),
        )

    );}),
      ),


      ]
    ],
  );
}