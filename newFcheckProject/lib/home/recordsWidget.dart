import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../offlineDatabase/sqfLiteDatabase.dart';
import 'healthDeclaration.dart';

var records =[];
var loadingRecords = false;
var filteredDateDisplay = "Filter";

getRecords(setState,filteredDate)async{
  setState((){loadingRecords = true;});
  var response = await http.post(
      Uri.parse("${apiLink()}api/FcAttendances/getEmployeeRecords"),
      body: {
        "employeeId":Hive.box("LocalStorage").get("employees")["employeeId"].toString(),
        "filteredDate":filteredDate??""
      });

  if (response.statusCode == 200) {
      records = await jsonDecode(response.body) as List;
      setState((){});
  }
  setState((){loadingRecords = false;});
}

class recordsWidget extends StatefulWidget {
  const recordsWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<recordsWidget> createState() => SiteWidgets();
}

class SiteWidgets extends State<recordsWidget> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }
  dialogDateTimePicker() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));

    filteredDateDisplay =DateFormat("MM/dd/yyyy")
        .format(picked!)
        .toString();
    getRecords(setState,picked.toString());

    setState(() {

    });

  }
  @override
  Widget build(BuildContext context) {
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
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(onPressed: (){
            filteredDateDisplay = "Filter";
            getRecords(setState,null);

            setState(() {

            });
          }, child: Icon(Icons.refresh)),

          SizedBox(width: 10,),

          ElevatedButton(onPressed: (){
            dialogDateTimePicker();
          }, child: Row(
            children: [
              Icon(Icons.filter_list),
              Text(filteredDateDisplay),
            ],
          )),

          SizedBox(width: 10,),
        ],
      ),
      if(records.length == 0)...[
        loadingRecords? Padding(
          padding: const EdgeInsets.only(top: 200),
          child: CircularProgressIndicator(),
        ):Container(
   height: MediaQuery.of(context).size.height,
   child:const Center(child: Text("No Records", style: TextStyle(fontSize: 50,color: Colors.black54))),

 )
      ]
      else...[


        loadingRecords? Padding(
          padding: const EdgeInsets.only(top: 200),
          child: CircularProgressIndicator(),
        ):SizedBox(
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
                  Text("${records[index]["workPlace"]} / ${records[index]["workPlaceOut"]}",style:const TextStyle(color: Colors.black,
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
                  TextButton(onPressed: (){
                    pictureEvidence(context, records[index]["employeeId"],
                        records[index]["timeIn"].toString().replaceAll(":", "").replaceAll(" ", ""),
                        DateFormat("yyyy dd MM").format(DateTime.parse(records[index]["date"])).toString(),
                        records[index]["date"],"in");

                  }, child: Text("view")),
                ],),

                Column(children: [
                   const Icon(Icons.timer_off_outlined,color: Colors.red,),
                    Text("${records[index]["timeOut"]}",style:const TextStyle(color: Colors.black,
                        fontWeight: FontWeight.bold)),
                  TextButton(onPressed: (){

                    pictureEvidence(context, records[index]["employeeId"],
                        records[index]["timeOut"].toString().replaceAll(":", "").replaceAll(" ", ""),
                        DateFormat("yyyy dd MM").format(DateTime.parse(records[index]["date"])).toString(),
                        records[index]["date"],"out");

                  }, child: Text("view")),
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

  pictureEvidence(context, employeeId, time, date, cdate, status) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Time ${status} image"),
        actions: [
          //https://apps.fastlogistics.com.ph/fastdrive//ontimemobile/220911842/2023 21 06/
          Image.network('https://apps.fastlogistics.com.ph/fastdrive//ontimemobile/'
              '${employeeId}/'
              '${date}/'
              '${time}${employeeId}.jpg',loadingBuilder: (context, child, loadingProgress) {

            if (loadingProgress == null) {
              return child;
            }

            return Center(child: CircularProgressIndicator());
          },errorBuilder: (context, error, stackTrace) {
            DateTime dates = DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.parse(cdate)));

            final today = DateTime(2023, 06, 22);
            final todays = DateTime(2023, 06, 23);
            final fiftyDaysAgo = today.difference(todays).inMinutes;

            if(fiftyDaysAgo <= 0){

              return TextButton(onPressed: (){

                Navigator.of(context).pop();
                pictureEvidence(context, employeeId, "0$time", date, cdate,status);
              }, child: Text("click if your time is older than jun 23, 2023"));
            }else{

              return Center(child: Text("Failed to load image"));
            }
            print(fiftyDaysAgo);

            return Text("asdasd");
          },),
          ElevatedButton(
              style: TextButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.pop(context, true);
              },
              child: const Text('Ok')),
        ],
      ),
    );
  }

}