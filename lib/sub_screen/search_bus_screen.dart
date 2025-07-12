// ignore_for_file: camel_case_types, file_names, unused_local_variable, depend_on_referenced_packages, non_constant_identifier_names, use_super_parameters, avoid_print, no_leading_underscores_for_local_identifiers, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API_MODEL/page_list_api_model.dart';
import '../API_MODEL/review_list_api_model.dart';
import '../API_MODEL/search_bus_api_model.dart';
import '../api_model/facility_api_model.dart';
import '../api_model/oprator_api_model.dart';
import '../config/config.dart';
import '../config/light_and_dark.dart';
import 'seat_book_screen.dart';

class Search_Bus_Screen extends StatefulWidget {
 final String boarding_id;
 final String drop_id;
 final String trip_date;
 final String to;
 final String from;
 final String is_verify;
 const Search_Bus_Screen({Key? key, required this.boarding_id, required this.drop_id, required this.trip_date, required this.to, required this.from, required this.is_verify}) : super(key: key);

  @override
  State<Search_Bus_Screen> createState() => _Search_Bus_ScreenState();
}

class _Search_Bus_ScreenState extends State<Search_Bus_Screen> {
  late SearchBus data;
  //Search bus api
  String uid = "";

  // sort         => sort By
  // pickupfilter => Departure Time
  // bustype      => Bus Type
  // operatorlist => Bus Operator
  // dropfilter   => arrival drop
  // facilitylist => Bus Facility

  Future searchBusApi(String uid,boarding_id,drop_id,trip_date) async {

    Map body = {
      'uid' : uid,
      'boarding_id' : boarding_id,
      'drop_id' : drop_id,
      'trip_date' : trip_date,
      "sort": selectedvalue1.isEmpty ? "0" : selectedvalue1,
      "pickupfilter": selectedvalue2.isEmpty ? "0" : selectedvalue2,
      "bustype": selectedvalue3.isEmpty ? "0" : selectedvalue3,
      "operatorlist": selectedvalue5.isEmpty ? "0" : selectedvalue5,
      "dropfilter": selectedvalue4.isEmpty ? "0" : selectedvalue4,
      "facilitylist": checkboxlist.isEmpty ? "0" : checkboxlist.join(',')
    };

    print("+++ $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/api/bus_search.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response.body);
      if(response.statusCode == 200){
        setState(() {
        data = searchBusFromJson(response.body.toString());
        isloading = false;
        });
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        _prefs.setString("bussearch", jsonEncode(data.busData));
        _prefs.setString("bussearch1", jsonEncode(data.currency));
        print(data);
        return data;
      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

  Reviewlist? data1;

  Future Review_list(String bus_id) async {

    Map body = {
      'bus_id' : bus_id,
    };
    print("+++ $body");
    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/api/ratelist.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response.body);
      if(response.statusCode == 200){
        setState(() {
          data1 = reviewlistFromJson(response.body.toString());
          data1!.reviewdata.isEmpty ? ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:  Text('No reviews found'.tr),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
          ) : Get.bottomSheet(isScrollControlled: true,StatefulBuilder(
              builder: (context, setState)  {
                return Container(
                  // height: 200,
                  decoration:  BoxDecoration(
                    color: notifier.background,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                    child: SingleChildScrollView(
                      // scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [


                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: data1?.reviewdata.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                            return  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  horizontalTitleGap: 5,
                                  leading: CircleAvatar(backgroundColor: Colors.grey.withOpacity(0.2),radius: 25,child: Text('${data1?.reviewdata[index].userTitle[0]}',style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff7D2AFF))),),
                                  title: Text('${data1?.reviewdata[index].userTitle}',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: notifier.textColor)),
                                  subtitle: Text('${data1?.reviewdata[index].reviewDate.toString().split(" ").first}',style:  TextStyle(fontSize: 14,color: notifier.textColor)),
                                  trailing: Container(
                                    height: 25,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      // color: Colors.red,
                                      border: Border.all(color: const Color(0xff7D2AFF)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.star,color: Color(0xff7D2AFF),size: 10),
                                        const SizedBox(width: 5,),
                                        Text('${data1?.reviewdata[index].userRate}',style: const TextStyle(color: Color(0xff7D2AFF),fontSize: 14,fontWeight: FontWeight.bold),)
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10,right: 10),
                                  child: Text('${data1?.reviewdata[index].userDesc}',style: TextStyle(color: notifier.textColor)),
                                ),
                                const SizedBox(height: 10,),
                              ],
                            );
                          },),
                        ],
                      ),
                    ),
                  ),
                );
              }
          ));
        });
        print(data1);
        return data1;
      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }


  //  GET API CALLING

  Fasillity? from;

  Future FacelityApi() async {
    var response1 = await http.get(Uri.parse('${config().baseUrl}/api/facilitylist.php'),);
    if (response1.statusCode == 200) {
      var jsonData = json.decode(response1.body);
      setState(() {
        from = fasillityFromJson(response1.body);
      });
    }
  }



  //  GET API CALLING
  Operator? from1;

  Future OperatorApi() async {
    var response1 = await http.get(Uri.parse('${config().baseUrl}/api/operatorlist.php'),);
    if (response1.statusCode == 200) {
      var jsonData = json.decode(response1.body);
      setState(() {
        from1 = operatorFromJson(response1.body);
      });
    }
  }

  @override
    void initState() {
    getDataFromLocal();
    _resetSelectedDate();
    getlocledata();
    pagelistapi();
    FacelityApi();
    OperatorApi();
      super.initState();
    }

  getDataFromLocal() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
  var data = preferences.getString("loginData");
  print(jsonDecode(data!));

  var decode = jsonDecode(data);
  setState(() {
      uid = decode["id"];
  });
  print(uid);
  searchBusApi(uid, widget.boarding_id, widget.drop_id, widget.trip_date);
  }

  int selected = 0;
  bool isloading = true;
  String formattedDate = DateFormat.yMMMEd().format(DateTime.now());


  late DateTime _selectedDate;

  void _resetSelectedDate() {
    print(DateTime.parse(widget.trip_date));
    _selectedDate = (DateTime.parse(widget.trip_date)).add(const Duration(seconds: 1));
  }

  int a= 0;

  List GridviewList = [];



  late PageList from12;

  //  GET API CALLING

  Future pagelistapi() async {
    var response1 = await http.get(Uri.parse('${config().baseUrl}/api/pagelist.php'),);
    if (response1.statusCode == 200) {
      var jsonData = json.decode(response1.body);
      print(jsonData["PageList"]);
      setState(() {
        from12 = pageListFromJson(response1.body);
      });
    }
  }

  var userData;
  var ticketid;

  getlocledata() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {

      userData  = jsonDecode(_prefs.getString("loginData")!);
      ticketid  = jsonDecode(_prefs.getString("tickethistory")!);

      print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["mobile"]}');
      print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${ticketid}');

    });
  }


  // Sort By

  List upperText = [
    'Price - Low to high',
    'Best rated first',
    'Early departure',
    'Late departure'
  ];

  // Departure time list

  List Departuretitle = [
    '06:00 - 12:00',
    '12:00 - 18:00',
    '18:00 - 24:00',
    '00:00 - 06:00',
  ];

  List Departuresubtitle = [
    'Morning',
    'Afternoon',
    'Evening',
    'Night',
  ];

  List Departureleading = [
    'assets/Image1.png',
    'assets/Image2.png',
    'assets/Image3.png',
    'assets/night-mode 1.png',
  ];

  // Bus Type

  List Seattitle = [
    'SEATER',
    'SLEEPER',
    'AC',
    'NONAC',
  ];

  List Seatleading = [
    'assets/Seate1.png',
    'assets/Seate2.png',
    'assets/Seate3.png',
    'assets/Seate4.png',
  ];

  // Arrival time list

  List Arrivaltitle = [
    '06:00 - 12:00',
    '12:00 - 18:00',
    '18:00 - 24:00',
    '00:00 - 06:00',
  ];

  List Arrivalsubtitle = [
    'Morning',
    'Afternoon',
    'Evening',
    'Night',
  ];

  // Expansion Tile Icon Variable

  bool iconChange1 = false;
  bool iconChange2 = false;
  bool iconChange3 = false;
  bool iconChange4 = false;
  bool iconChange5 = false;

  // Bus Operator Variable

  bool  checkboxis = false;
  bool  checkboxis1 = false;

  // Bus Facilities Variable

  List  checkboxlist = [];
  List  checkboxlist1 = [];

  String selectedOption = '';
  String selectedOption1 = '';
  String selectedOption2 = '';
  String selectedOption3 = '';
  String selectedOption4 = '';

  String selectedvalue1 = '';
  String selectedvalue2 = '';
  String selectedvalue3 = '';
  String selectedvalue4 = '';
  String selectedvalue5 = '';

  ColorNotifier notifier = ColorNotifier();

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        iconTheme: const IconThemeData(
          color: Colors.white, // change your color here
        ),
        backgroundColor: notifier.appbarcolore,
        elevation: 0,
        actions: [
          const SizedBox(width: 60),
          SizedBox(
            height: 70,
            width: 200,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Row(
                  children: [
                    Flexible(child: Text(widget.from,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 13,),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                    const SizedBox(width: 5,),
                    const Image(image: AssetImage('assets/arrow-right.png'),color: Colors.white,height: 12,width: 12),
                    const SizedBox(width: 5,),
                    Flexible(child: Text(widget.to,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                  ],
                ),
              ),
              subtitle: Text(_selectedDate.toString().split(" ").first,style: const TextStyle(color: Colors.white,fontSize: 12)),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(top: 21,bottom: 21),
            child: InkWell(
              onTap: () {
                selectDateAndTime(context);
              },
              child: Container(
                height: 30,
                width: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  Center(child: Text('Change'.tr,style: const TextStyle(color: Colors.white,fontSize: 12),)),
              ),
            ),
          ),
          const SizedBox(width: 10,),
        ],
      ),
      backgroundColor: notifier.backgroundgray,
      floatingActionButton: isloading ? null : data.busData.isEmpty ? null : FloatingActionButton.extended(
        backgroundColor: notifier.theamcolorelight,
        onPressed: () {

          showModalBottomSheet(
            constraints: const BoxConstraints(minHeight: 600,maxHeight: 600),
            isScrollControlled: true,
            isDismissible: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
            ),
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async {
                  iconChange1 = false;
                  iconChange2 = false;
                  iconChange3 = false;
                  iconChange4 = false;
                  iconChange5 = false;
                  return true;
                },
                child: StatefulBuilder(
                    builder: (context, setState)  {
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                        child: Scaffold(
                          backgroundColor: notifier.background,
                          bottomNavigationBar: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                // height: 100,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: notifier.background,
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(10),topLeft:Radius.circular(10))
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child:  ElevatedButton(
                                          style: ButtonStyle(fixedSize: const MaterialStatePropertyAll(Size(120, 40)),elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),side: BorderSide(color: notifier.theamcolorelight))),backgroundColor:  const MaterialStatePropertyAll(Colors.transparent)),
                                          onPressed: () => {
                                            selectedOption = "",
                                            selectedOption1 = "",
                                            selectedOption2 = "",
                                            selectedOption3 = "",
                                            selectedOption4 = "",
                                            checkboxlist = [],
                                            checkboxlist1 = [],
                                            iconChange1 = false,
                                            iconChange2 = false,
                                            iconChange3 = false,
                                            iconChange4 = false,
                                            iconChange5 = false,
                                            Get.back()
                                          },
                                          child: Text('Reset'.tr,style:  TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 10,),
                                      Expanded(
                                        child: selectedOption.isEmpty && selectedOption1.isEmpty && selectedOption2.isEmpty && selectedOption3.isEmpty && selectedvalue5.isEmpty && checkboxlist.isEmpty && checkboxlist1.isEmpty ?
                                        ElevatedButton(
                                          style: ButtonStyle(fixedSize: const MaterialStatePropertyAll(Size(120, 40)),elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),backgroundColor:  const MaterialStatePropertyAll(Color(0xffD6C1F9))),
                                          onPressed: () => {
                                          },
                                          child: Text('Apply Filter'.tr,style:   const TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                        )  :  ElevatedButton(
                                          style: ButtonStyle(fixedSize: const MaterialStatePropertyAll(Size(120, 40)),elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),backgroundColor:  MaterialStatePropertyAll<Color?>(notifier.theamcolorelight)),
                                          onPressed: () => {
                                          searchBusApi(uid, widget.boarding_id, widget.drop_id, widget.trip_date),
                                            iconChange1 = false,
                                            iconChange2 = false,
                                            iconChange3 = false,
                                            iconChange4 = false,
                                            iconChange5 = false,
                                          Get.back(),
                                          },
                                          child: Text('Apply Filter'.tr,style:  const TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          appBar: AppBar(
                            backgroundColor: notifier.background,
                            automaticallyImplyLeading: false,
                            toolbarHeight: 40,
                            elevation: 0,
                            title: Center(child: Text('Apply Filter',style: TextStyle(color: notifier.textColor,fontSize: 16,fontWeight: FontWeight.bold),),),
                            actions: [
                              InkWell(
                                  onTap: () {
                                    iconChange1 = false;
                                    iconChange2 = false;
                                    iconChange3 = false;
                                    iconChange4 = false;
                                    iconChange5 = false;
                                    Get.back();
                                  },
                                  child: Icon(Icons.close,color: notifier.textColor,)
                              ),
                              const SizedBox(width: 8,),
                            ],
                          ),
                          body: Container(
                            decoration: BoxDecoration(
                              color: notifier.background,
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10,bottom: 10,left: 20,right: 20),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Sort By-',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 10,),
                                    Container(
                                      // height: 150,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ListView.separated(
                                                separatorBuilder: (context, index) {
                                                  return const SizedBox(height: 5);
                                                },
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: upperText.length,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (BuildContext context, int index) {
                                                  return  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            selectedOption = upperText[index] ;
                                                            selectedvalue1 = (index + 1).toString();
                                                            print(selectedvalue1);
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Text('${upperText[index]}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                                            const Spacer(),
                                                            Radio(
                                                              value: upperText[index],
                                                              groupValue: selectedOption,
                                                              fillColor:  MaterialStatePropertyAll<Color?>(notifier.theamcolorelight),
                                                              onChanged: (value) {

                                                                setState(() {
                                                                  selectedOption = value.toString();
                                                                  selectedvalue1 = (index + 1).toString();
                                                                  print(selectedvalue1);
                                                                });
                                                              },
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: ListTileTheme(
                                        contentPadding: const EdgeInsets.all(0),
                                        dense: true,
                                        horizontalTitleGap: 0.0,
                                        minVerticalPadding: 0,
                                        minLeadingWidth: 0,
                                        child: ExpansionTile(
                                          onExpansionChanged: (value) {
                                            setState((){
                                              iconChange1  = value;
                                            });
                                          },
                                          trailing: iconChange1? const Padding(
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Icon(Icons.remove,size: 20,),
                                          ) : const Padding(
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Icon(Icons.add,size: 20,),
                                          ),
                                          iconColor: notifier.theamcolorelight,
                                          collapsedIconColor: notifier.theamcolorelight,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          title: Padding(
                                            padding: const EdgeInsets.only(left: 10,right: 10),
                                            child: Text('Departure Time',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                          ),
                                          children: [
                                            ListView.separated(
                                                separatorBuilder: (context, index) {
                                                  return const SizedBox(width:  10);
                                                },
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: 4,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          onTap: () {
                                                            setState(() {
                                                              selectedOption1 = Departuretitle[index];
                                                              selectedvalue2 = (index + 1).toString();
                                                            });
                                                          },
                                                          leading: Image(image: AssetImage('${Departureleading[index]}'),height: 25,width: 25,color: notifier.textColor),
                                                          title: Padding(
                                                            padding: const EdgeInsets.only(left: 8.0),
                                                            child: Text('${Departuretitle[index]}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                                          ),
                                                          subtitle: Padding(
                                                            padding: const EdgeInsets.only(left: 8.0),
                                                            child: Text('${Departuresubtitle[index]}',style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                                                          ),
                                                          trailing: Radio(
                                                            value: Departuretitle[index],
                                                            groupValue: selectedOption1,
                                                            fillColor:  MaterialStatePropertyAll<Color?>(notifier.theamcolorelight),
                                                            onChanged: (value) {
                                                              print(value);
                                                              setState(() {
                                                                selectedOption1 = value.toString();
                                                                selectedvalue2 = (index + 1).toString();
                                                              });
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                })
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: ListTileTheme(
                                        contentPadding: const EdgeInsets.all(0),
                                        dense: true,
                                        horizontalTitleGap: 0.0,
                                        minVerticalPadding: 0,
                                        minLeadingWidth: 0,
                                        child: ExpansionTile(
                                          onExpansionChanged: (value) {
                                            setState((){
                                              iconChange3  = value;
                                            });
                                          },
                                          trailing: iconChange3? const Padding(
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Icon(Icons.remove,size: 20,),
                                          ) : const Padding(
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Icon(Icons.add,size: 20,),
                                          ),
                                          iconColor: notifier.theamcolorelight,
                                          collapsedIconColor: notifier.theamcolorelight,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          title: Padding(
                                            padding: const EdgeInsets.only(left: 10,right: 10),
                                            child: Text('Arrival Time',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                          ),
                                          children: [
                                            ListView.separated(
                                                separatorBuilder: (context, index) {
                                                  return const SizedBox(width:  10);
                                                },
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: 4,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          onTap: () {
                                                            setState(() {
                                                              selectedOption3 =  Arrivaltitle[index];
                                                              selectedvalue4 = (index + 1).toString();
                                                            });
                                                          },
                                                          leading: Image(image: AssetImage('${Departureleading[index]}'),height: 25,width: 25,color: notifier.textColor),
                                                          title: Padding(
                                                            padding: const EdgeInsets.only(left: 8.0),
                                                            child: Text('${Arrivaltitle[index]}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                                          ),
                                                          subtitle: Padding(
                                                            padding: const EdgeInsets.only(left: 8.0),
                                                            child: Text('${Arrivalsubtitle[index]}',style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                                                          ),
                                                          trailing: Radio(
                                                            value: Arrivaltitle[index],
                                                            groupValue: selectedOption3,
                                                            fillColor:  MaterialStatePropertyAll<Color?>(notifier.theamcolorelight),
                                                            onChanged: (value) {
                                                              print(value);
                                                              setState(() {
                                                                selectedOption3 = value.toString();
                                                                selectedvalue4 = (index + 1).toString();
                                                              });
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                })
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTileTheme(
                                        contentPadding: const EdgeInsets.all(0),
                                        dense: true,
                                        horizontalTitleGap: 0.0,
                                        minVerticalPadding: 0,
                                        minLeadingWidth: 0,
                                        child: ExpansionTile(
                                          onExpansionChanged: (value) {
                                            setState((){
                                              iconChange2  = value;
                                            });
                                          },
                                          trailing: iconChange2? const Padding(
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Icon(Icons.remove,size: 20,),
                                          ) : const Padding(
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Icon(Icons.add,size: 20,),
                                          ),
                                          iconColor: notifier.theamcolorelight,
                                          collapsedIconColor: notifier.theamcolorelight,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          title: Padding(
                                            padding: const EdgeInsets.only(left: 10,right: 10),
                                            child: Text('Bus Type',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                          ),
                                          children: [
                                            ListView.separated(
                                                separatorBuilder: (context, index) {
                                                  return const SizedBox(width:  10);
                                                },
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: 4,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          onTap: () {
                                                            setState(() {
                                                              selectedOption2 = Seattitle[index];
                                                              selectedvalue3 = (index + 1).toString();
                                                            });
                                                          },
                                                          leading: Image(image: AssetImage('${Seatleading[index]}'),height: 25,width: 25,color: notifier.textColor),
                                                          title: Padding(
                                                            padding: const EdgeInsets.only(left: 8.0),
                                                            child: Text('${Seattitle[index]}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                                          ),
                                                          trailing: Radio(
                                                            value: Seattitle[index],
                                                            groupValue: selectedOption2,
                                                            fillColor: MaterialStatePropertyAll<Color?>(notifier.theamcolorelight),
                                                            onChanged: (value) {
                                                              print(value);
                                                              setState(() {
                                                                selectedOption2 = value.toString();
                                                                selectedvalue3 = (index + 1).toString();
                                                              });
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                })
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTileTheme(
                                        contentPadding: const EdgeInsets.all(0),
                                        dense: true,
                                        horizontalTitleGap: 0.0,
                                        minVerticalPadding: 0,
                                        minLeadingWidth: 0,
                                        child: ExpansionTile(
                                          onExpansionChanged: (value) {
                                            setState((){
                                              iconChange4  = value;
                                            });
                                          },
                                          trailing: iconChange4? const Padding(
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Icon(Icons.remove,size: 20,),
                                          ) : const Padding(
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Icon(Icons.add,size: 20,),
                                          ),
                                          iconColor: notifier.theamcolorelight,
                                          collapsedIconColor: notifier.theamcolorelight,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          title: Padding(
                                            padding: const EdgeInsets.only(left: 10,right: 10),
                                            child: Text('Bus Facilities',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                          ),
                                          children: [
                                            ListView.separated(
                                                separatorBuilder: (context, index) {
                                                  return const SizedBox(width:  10);
                                                },
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: from?.facilitylist.length ?? 0,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          onTap: () {
                                                            if(checkboxlist.contains(index+1)){
                                                              setState((){
                                                                checkboxlist.remove(index+1);
                                                              });
                                                            } else{
                                                              setState((){
                                                                checkboxlist.add(index+1);
                                                              });
                                                            }
                                                          },
                                                          leading: Image(image: NetworkImage('${config().baseUrl}/${from?.facilitylist[index].img}'),height: 25,width: 25,color: notifier.textColor),
                                                          title: Padding(
                                                            padding: const EdgeInsets.only(left: 8.0),
                                                            child: Text('${from?.facilitylist[index].title}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                                          ),
                                                          trailing: Checkbox(
                                                            side: BorderSide(color: notifier.theamcolorelight,width: 2),
                                                            checkColor: Colors.white,
                                                            activeColor: notifier.theamcolorelight,
                                                            value: checkboxlist.contains(index+1) ? true : false,
                                                            onChanged: (bool? value) {
                                                              if(checkboxlist.contains(index+1)){
                                                                setState((){
                                                                checkboxlist.remove(index+1);
                                                                });
                                                              } else{
                                                               setState((){
                                                                checkboxlist.add(index+1);
                                                               });
                                                              }
                                                              print(checkboxlist.join(','));
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: ListTileTheme(
                                        contentPadding: const EdgeInsets.all(0),
                                        dense: true,
                                        horizontalTitleGap: 0.0,
                                        minVerticalPadding: 0,
                                        minLeadingWidth: 0,
                                        child: ExpansionTile(
                                          onExpansionChanged: (value) {
                                            setState((){
                                              iconChange5  = value;
                                            });
                                          },
                                          trailing: iconChange5? const Padding(
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Icon(Icons.remove,size: 20,),
                                          ) : const Padding(
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Icon(Icons.add,size: 20,),
                                          ),
                                          iconColor: notifier.theamcolorelight,
                                          collapsedIconColor: notifier.theamcolorelight,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          title: Padding(
                                            padding: const EdgeInsets.only(left: 10,right: 10),
                                            child: Text('Bus Operator',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                          ),
                                          children: [
                                            ListView.separated(
                                                separatorBuilder: (context, index) {
                                                  return const SizedBox(width:  10);
                                                },
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: from1?.operatorlist.length ?? 0,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          onTap: () {
                                                            setState(() {
                                                              selectedOption4 = from1!.operatorlist[index].title;
                                                              selectedvalue5 = (index + 1).toString();
                                                            });
                                                          },
                                                          title: Padding(
                                                            padding: const EdgeInsets.only(left: 8.0),
                                                            child: Text('${from1?.operatorlist[index].title}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                                                          ),
                                                          trailing:  Radio(
                                                            value: from1?.operatorlist[index].title,
                                                            groupValue: selectedOption4,
                                                            fillColor:  MaterialStatePropertyAll<Color?>(notifier.theamcolorelight),
                                                            onChanged: (value) {
                                                              print(value);
                                                              setState(() {
                                                                selectedOption4 = value.toString();
                                                                selectedvalue5 = (index + 1).toString();
                                                              });
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                ),
              );
            },
          );
        },
        label: const Column(
          children: [
             Text('FILTERS',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold)),
             Text('& SORT',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold)),
          ],
        ),
        icon: const Image(image: AssetImage('assets/sliders-horizontal.png'),height: 30,width: 20,color: Colors.white),
      ),
      

      // backgroundColor: notifier.background,
      body: isloading ?  Center(child: CircularProgressIndicator(color: notifier.theamcolorelight),) : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const SizedBox(height: 15),

          data.busData.isEmpty ?  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(image: AssetImage('assets/notavilabale_bus_image.png'),width: 250,height: 250,),
              // SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: Text('Routeka fulfilled buses are not available at this time.'.tr,textAlign: TextAlign.center,style: const TextStyle(fontSize: 16,color: Colors.grey ,fontFamily: 'SofiaProBold'),),
              ),
            ],
          ) : Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 15);
                },
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: data.busData.length,
                itemBuilder: (BuildContext context, int index) {

                  var date1 = DateFormat("HH:mm").parse(convertTimeTo12HourFormat(data.busData[index].busPicktime));
                  var date2 = DateFormat("HH:mm").parse(convertTimeTo12HourFormat(data.busData[index].busDroptime));

                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: notifier.containercoloreproper,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                               Navigator.push(context, MaterialPageRoute(builder: (context) =>  Seat_Book_(operator_id: data.busData[index].operatorId,is_verify: widget.is_verify,agentCommission: (double.parse(data.busData[index].ticketPrice) * double.parse(data.busData[index].agentCommission) / 100).toStringAsFixed(2),com_per: data.busData[index].agentCommission,boarding_id: widget.boarding_id,drop_id: widget.drop_id,currency: data.currency,differencePickDrop: data.busData[index].differencePickDrop,Difference_pick_drop: data.busData[index].differencePickDrop,totlSeat: data.busData[index].totlSeat,isSleeper: data.busData[index].isSleeper,busAc: data.busData[index].busAc,busRate: data.busData[index].busRate,busPicktime: data.busData[index].busPicktime,busDroptime: data.busData[index].busDroptime,ticketPrice: data.busData[index].ticketPrice.toString(),busImg: data.busData[index].busImg,id_pickup_drop: data.busData[index].idPickupDrop,busTitle: data.busData[index].busTitle,bus_id: data.busData[index].busId,trip_date: _selectedDate.toString(),uid: uid,boardingCity: data.busData[index].boardingCity,dropCity: data.busData[index].dropCity,from: widget.from,to: widget.to, ),));
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: notifier.theamcolorelight,
                                          borderRadius: BorderRadius.circular(65),
                                          image: DecorationImage(image: NetworkImage('${config().baseUrl}/${data.busData[index].busImg}'),fit: BoxFit.fill))
                                        ),
                                    const SizedBox(width: 10,),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data.busData[index].busTitle,style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: notifier.textColor)),
                                          const SizedBox(height: 5,),
                                          Row(
                                            children: [
                                              if(data.busData[index].busAc == '1')  Flexible(child: Text('AC Seater'.tr,style: TextStyle(fontSize: 13,color: notifier.textColor),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                              if(data.busData[index].isSleeper == '1')  Flexible(child: Text('Non Ac / Sleeper'.tr,style: TextStyle(fontSize: 13,color: notifier.textColor),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                              const SizedBox(width: 5,),
                                              Container(
                                                  height: 22,
                                                  width: 65,
                                                 decoration: BoxDecoration(
                                                   border: Border.all(color: notifier.seatbordercolore),
                                                   color: notifier.seatcontainere,
                                                   borderRadius: BorderRadius.circular(5)
                                                 ),
                                                  child: Center(child: Padding(
                                                    padding: const EdgeInsets.only(top: 3),
                                                    child: Text('${data.busData[index].totlSeat} Seats',style:  TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.seattextcolore),overflow: TextOverflow.ellipsis,maxLines: 1,),
                                                  ))
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4,),
                                    Column(
                                      children: [
                                        Text('${data.currency}${data.busData[index].ticketPrice}',style: TextStyle(color: notifier.theamcolorelight,fontSize: 15,fontWeight: FontWeight.bold),),
                                        const SizedBox(height: 5,),
                                        Tooltip(
                                          margin: const EdgeInsets.only(left: 30,right: 30),
                                          triggerMode: TooltipTriggerMode.tap,
                                          showDuration: const Duration(seconds: 2),
                                          message: 'Per ticket, you received the commission of ${(double.parse(data.busData[index].ticketPrice) * double.parse(data.busData[index].agentCommission) / 100).toStringAsFixed(2)}${data.currency}',
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              userData['user_type'] == 'AGENT' ? Padding(padding: const EdgeInsets.only(top: 4), child: Text('${data.currency} ${(double.parse(data.busData[index].ticketPrice) * double.parse(data.busData[index].agentCommission) / 100).toStringAsFixed(2) }',style: const TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold)),) : const SizedBox(),
                                              const SizedBox(width: 5,),
                                              userData['user_type'] == 'AGENT' ?  const Image(image: AssetImage('assets/agenticon.png'),height: 15,width: 15,color: Colors.green,):const SizedBox()
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: SizedBox(
                                        width: 100,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(data.busData[index].boardingCity,style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                            const SizedBox(height: 8,),
                                            Text(convertTimeTo12HourFormat(data.busData[index].busPicktime),style:   TextStyle(fontWeight: FontWeight.bold,color: notifier.theamcolorelight,fontSize: 12),overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8,),
                                            Text(_selectedDate.toString().split(" ").first,style:  TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.textColor),overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8,),
                                            // Text('Seat : ${data.busData[index].totlSeat}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5,),
                                    Column(
                                      children: [
                                        Image(image: const AssetImage('assets/Auto Layout Horizontal.png'),height: 50,width: 120,color: notifier.theamcolorelight),
                                        Text(data.busData[index].differencePickDrop,style: TextStyle(fontSize: 12,color: notifier.textColor)),
                                      ],
                                    ),
                                    const SizedBox(width: 5,),
                                    Flexible(
                                      child: SizedBox(
                                        width: 100,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(data.busData[index].dropCity,style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                            const SizedBox(height: 8,),
                                            Text(convertTimeTo12HourFormat(data.busData[index].busDroptime),style:  TextStyle(fontWeight: FontWeight.bold,color: notifier.theamcolorelight ,fontSize: 12),overflow: TextOverflow.ellipsis,),
                                            const SizedBox(height: 8,),
                                            Text(_selectedDate.toString().split(" ").first,style:  TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.textColor),overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8,),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: Colors.grey.withOpacity(0.4)),
                                const SizedBox(height: 8,),
                              ],
                            ),
                          ),

                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0,right: 0),
                                child: Row(
                                  children: [
                                    Expanded(flex: 4,child: InkWell(
                                        onTap: () {
                                          if(GridviewList.contains(index) == true){
                                            setState(() {
                                              GridviewList.remove(index);
                                            });
                                          }else{
                                            setState(() {
                                              GridviewList.add(index);
                                            });
                                          }
                                        },
                                        child:  Text('Amenities'.tr,style:  TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold,fontSize: 12),))),
                                    Expanded(flex: 4,child: InkWell(
                                        onTap: () {
                                          Review_list(data.busData[index].busId);
                                        },
                                        child:  Padding(
                                          padding:  const EdgeInsets.only(left: 15),
                                          child:  Text('Review'.tr,style:  TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold,fontSize: 12),),
                                        ))),
                                    Expanded(flex: 4,child: InkWell(
                                        onTap: () {
                                          Get.bottomSheet(isScrollControlled: true,StatefulBuilder(
                                              builder: (context, setState)  {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 100),
                                                  child: Container(
                                                    // height: 200,
                                                    decoration:  BoxDecoration(
                                                      color: notifier.background,
                                                      borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                                      child: SingleChildScrollView(
                                                        scrollDirection: Axis.vertical,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(from12.pagelist[3].title,style:  TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: notifier.textColor)),
                                                            const SizedBox(height: 20,),
                                                            HtmlWidget(
                                                             from12.pagelist[3].description,
                                                              textStyle:  TextStyle(
                                                                  color: notifier.textColor,
                                                                  fontSize: 20,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                          ));
                                        },
                                        child:  Text('Cancellation Policy'.tr,style:  TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold,fontSize: 12),))),
                                  ],
                                ),
                              ),
                              GridviewList.contains(index) ?
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: GridView.builder(
                                   shrinkWrap: true,
                                    gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisExtent: 20,
                                      mainAxisSpacing: 10,
                                    ),
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: data.busData[index].busFacilities.length,
                                    itemBuilder: (BuildContext context, int index1) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: Row(
                                          children: [
                                            Image(image: NetworkImage('${config().baseUrl}/${data.busData[index].busFacilities[index1].facilityimg}'),color: notifier.textColor),
                                            const SizedBox(width: 10,),
                                            Text(data.busData[index].busFacilities[index1].facilityname,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor)),
                                          ],
                                        ),
                                      );
                                    },
                                ),
                              ) : const SizedBox(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),

          const SizedBox(height: 15,),

        ],
      ),
    );
  }

  var selectedDateAndTime = DateTime.now();

  Future<void> selectDateAndTime(context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff7D2AFF), // <-- SEE HERE
              onPrimary: Colors.white, // <-- SEE HERE
              onSurface: Color(0xff7D2AFF), // <-- SEE HERE
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    print(pickedDate);
    if (pickedDate != null && pickedDate != _selectedDate) {

      setState(() {
        _selectedDate = pickedDate;
      });
      searchBusApi(uid, widget.boarding_id, widget.drop_id, _selectedDate.toString().split(" ").first);
    }
  }
}



 String convertTimeTo12HourFormat(String time24Hour) {
  // Parse the input time in 24-hour format
  final inputFormat = DateFormat('HH:mm:ss');
  final inputTime = inputFormat.parse(time24Hour);

  // Format the time in 12-hour format
  final outputFormat = DateFormat('h:mm a');
  final formattedTime = outputFormat.format(inputTime);

  return formattedTime;
}