import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:routekacustomernew/Common_Code/common_button.dart';
import 'package:routekacustomernew/sub_screen/parcel_search_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API_MODEL/search_get_api_model.dart';
import '../API_MODEL/wallet_report_api_model.dart';
import '../api_model/point_api_model.dart';
import '../config/config.dart';
import '../config/light_and_dark.dart';

class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {


  var userData;
  var searchbus;

  getlocledata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData  = jsonDecode(prefs.getString("loginData")!);
      searchbus = jsonDecode(prefs.getString('currency')!);
      SearchGet();
      Point_Api(city_id: "0");
      Walletreport(uid: userData["id"].toString());

      print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["id"]}');
      // print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["id"]}');
    });
  }

  @override
  void initState() {
    getlocledata();
    // TODO: implement initState
    super.initState();
  }

  bool isloading = true;
  bool textfildeloading = true;


  String bordingId= "";
  String dropId= "";

  ColorNotifier notifier = ColorNotifier();

  //  GET API CALLING
  FromtoModel? from12;

  Future SearchGet() async {
    var response1 = await http.get(Uri.parse('${config().baseUrl}/api/citylist.php'),);
    if (response1.statusCode == 200) {
      var jsonData = json.decode(response1.body);
      print(jsonData["citylist"]);
      setState(() {
        from12 = fromtoModelFromJson(response1.body);
        isloading = false;
        textfildeloading = false;
        print("FROM 12:- ${from12!.citylist[0].title}");
      });
    }
  }


  var selectedDateAndTime = DateTime.now();

  Future<void> selectDateAndTime(context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateAndTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2080),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff7D2AFF),
              onPrimary: Colors.white,
              onSurface: Color(0xff7D2AFF),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                // primary: Colors.black,
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    print(pickedDate);
    if (pickedDate != null && pickedDate != selectedDateAndTime) {
      setState(() {
        selectedDateAndTime = pickedDate;
      });
    }
  }





  // POINT API


  PointApiModel? pointApiModel;

  // Future Point_Api({required String city_id}) async {
  //
  //   Map body = {
  //     'city_id' : city_id,
  //   };
  //
  //   print("+++ $body");
  //
  //
  //   try{
  //     var response = await http.post(Uri.parse('${config().baseUrl}/api/point.php'), body: jsonEncode(body),headers: {
  //       'Content-Type': 'application/json',
  //     });
  //
  //     if(response.statusCode == 200){
  //       print(response.body);
  //
  //       setState(() {
  //         print("++ RESPONSE BODY ++ :- ${response.body}");
  //         pointApiModel = pointApiModelFromJson(response.body);
  //         isloading = false;
  //         suggestionontap = false;
  //       });
  //       setState((){});
  //
  //     }else {
  //       print('failed');
  //     }
  //   }catch(e){
  //     print(e.toString());
  //   }
  // }


  Future<PointApiModel?> Point_Api({required String city_id}) async {
    Map body = {
      'city_id': city_id,
    };

    try {
      var response = await http.post(
        Uri.parse('${config().baseUrl}/api/point.php'),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("++ RESPONSE BODY ++ :- ${response.body}");
        PointApiModel parsedModel = pointApiModelFromJson(response.body);

        // Also set it to state if needed
        setState(() {
          pointApiModel = parsedModel;
          isloading = false;
          suggestionontap = false;
          FromLoader = false;
          ToLoader = false;
        });

        return parsedModel;
      } else {
        print('API call failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during API call: ${e.toString()}');
      return null;
    }
  }


  WalletReport? data;

  Future Walletreport({required String uid}) async {

    Map body = {
      'uid' : uid,
    };

    print("+++ $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/api/wallet_report.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response.body);
      if(response.statusCode == 200){
        setState(() {
          data = walletReportFromJson(response.body);
          isloading = false;
          print('+-+-+-+-+-+-+-+-+-+-+-+-+- WALLETE +-+-+-+-+-+-+-+-+-+-+-+-+:- ${data!.wallet}');
        });
      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }


  TextEditingController Parcel_Weight = TextEditingController();


  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.backgroundgray,
      appBar: AppBar(
        backgroundColor:notifier.appbarcolore,
        // backgroundColor: theamcolore,
        elevation: 0,
        centerTitle: true,
        title: Text("Luggage".tr,style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: isloading == true ? Center(child: CircularProgressIndicator(color: theamcolore,)) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            // color: Colors.red,
                            // border: Border.all(color: _suggestionTextFiledControoler.text.isEmpty ? Colors.grey.withOpacity(0.4) : theamcolore),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(_suggestionTextFiledControoler.text.isEmpty ? 0.0 : 8.0),
                            child: Column(
                              children: [
                                textfildefrom(),
                                _suggestionTextFiledControoler.text.isEmpty ? SizedBox() : const SizedBox(height: 10,),
                                 _suggestionTextFiledControoler.text.isEmpty ? SizedBox() : Row(
                                  children: [
                                    FromLoader == true ? Container(
                                      height: 20,
                                      width: 20,
                                      margin: EdgeInsets.only(right: 10),
                                      child: CircularProgressIndicator(color: theamcolore,strokeWidth: 3,),
                                    ) : Expanded(flex: 1,child: Icon(Icons.keyboard_arrow_down_outlined)),

                                    FromLoader == true ? Expanded(flex: 12,child: textfildefrom_sub_dummy()) :  Expanded(flex: 12,child: textfildefrom_sub()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ),
                      const SizedBox(height: 10),


                      Container(
                        decoration: BoxDecoration(
                          // color: Colors.red,
                          // border: Border.all(color: _suggestionTextFiledControoler1.text.isEmpty ? Colors.grey.withOpacity(0.4) : theamcolore),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(_suggestionTextFiledControoler1.text.isEmpty ? 0.0 : 8.0),
                          child: Column(
                            children: [
                              textfildeto(),
                              _suggestionTextFiledControoler1.text.isEmpty ? SizedBox() : const SizedBox(height: 10,),
                               _suggestionTextFiledControoler1.text.isEmpty ? SizedBox() : Row(
                                children: [
                                  ToLoader == true ? Container(
                                    height: 20,
                                    width: 20,
                                    margin: EdgeInsets.only(right: 10),
                                    child: CircularProgressIndicator(color: theamcolore,strokeWidth: 3,),
                                  ) : Expanded(flex: 1,child: Icon(Icons.keyboard_arrow_down_outlined)),
                                  ToLoader == true ? Expanded(flex: 12,child: textfildeto_sub_dummy()) : Expanded(flex: 12,child: textfildeto_sub()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      //
                      // textfildeto(),
                      // _suggestionTextFiledControoler1.text.isEmpty ? SizedBox() : const SizedBox(height: 10,),
                      // _suggestionTextFiledControoler1.text.isEmpty ? SizedBox() : textfildeto_sub(),
                    ],
                  ),
                  // Positioned.directional(
                  //   textDirection:Directionality.of(context),
                  //   // right: 20,
                  //   end: 20,
                  //   top: 30,
                  //   child: InkWell(
                  //     onTap: () {
                  //       setState((){
                  //         fun();
                  //       },
                  //       );
                  //     },
                  //     child: Container(
                  //       height: 40,
                  //       width: 40,
                  //       decoration: BoxDecoration(
                  //         color: notifier.background,
                  //         border: Border.all(color: Colors.grey.withOpacity(0.4)),
                  //         borderRadius: BorderRadius.circular(10),
                  //         // image: DecorationImage(image: AssetImage(''))
                  //       ),
                  //       child: const Padding(
                  //         padding: EdgeInsets.all(8.0),
                  //         child: Image(image: AssetImage('assets/arrow-down-arrow-up.png'),height: 25,width: 25,),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 10),
              // CommonTextfiled10(context: context,txt: "Parcel weight"),
              TextField(
                controller: Parcel_Weight,
                keyboardType: TextInputType.number,
                // obscureText: true,
                style: TextStyle(color: notifier.textColor),
                decoration:  InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                  focusedBorder:  OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: notifier.theamcolorelight)),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)),),
                  enabledBorder:  OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: Colors.grey.withOpacity(0.4))),
                  hintText: "Luggage weight".tr,hintStyle: TextStyle(color: notifier.textColor,fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 10,),
                      InkWell(
                        onTap: () {
                          selectDateAndTime(context);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 7,),
                            Text('Date'.tr,style: TextStyle(color: notifier.textColor),),
                            Text("${selectedDateAndTime.day}/${selectedDateAndTime.month}/${selectedDateAndTime.year}",style:  TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: notifier.textColor)),
                          ],
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            selectDateAndTime(context);
                          },
                          child:  const Padding(
                            padding: EdgeInsets.only(left: 10,right: 10),
                            child: Image(image: AssetImage('assets/calendar-empty-alt.png'),height: 25,width: 25,),
                          )),
                    ],
                  )
              ),
              SizedBox(height: 10),
              CommonButton(containcolore: theamcolore, onPressed1: () {


                if(
                _suggestionTextFiledControoler.text.isNotEmpty &&
                _suggestionTextFiledControoler1.text.isNotEmpty &&
                _suggestionTextFiledControoler_sub.text.isNotEmpty &&
                _suggestionTextFiledControoler1_sub.text.isNotEmpty &&
                Parcel_Weight.text.isNotEmpty
                ){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ParcelSearchBus(
                    from_add: _suggestionTextFiledControoler_sub.text,
                    to_add: _suggestionTextFiledControoler1_sub.text,
                    bordingId: bordingId.toString(),
                    dropId: dropId.toString(),
                    from_id: from_point_id.toString(),
                    to_id: to_point_id.toString(),
                    trip_date: "${selectedDateAndTime.year}/${selectedDateAndTime.month}/${selectedDateAndTime.day}",
                    weight: Parcel_Weight.text,
                    From_Lat: From_Lat,
                    From_Long: From_Long,
                    To_Lat: To_Lat,
                    To_Long: To_Long,
                    wallete: data!.wallet,
                  )));
                }else{
                  if(
                  _suggestionTextFiledControoler.text.isEmpty ||
                      _suggestionTextFiledControoler1.text.isEmpty ||
                      _suggestionTextFiledControoler_sub.text.isEmpty ||
                      _suggestionTextFiledControoler1_sub.text.isEmpty
                  ){
                    Fluttertoast.showToast(
                      msg: "Select From and To",
                    );
                  }else{
                    Fluttertoast.showToast(
                      msg: "Enter Luggage weight",
                    );
                  }

                }

              },context: context,txt1: "Search Bus".tr),
            ],
          ),
        ),
      ),
    );
  }



  bool suggestionontap = false;



  // Widget textfildefrom(){
  //   return SizedBox(
  //     height: 45,
  //     child: Center(
  //       child: AutoCompleteTextField(
  //         controller: _suggestionTextFiledControoler,
  //         clearOnSubmit: false,
  //         suggestions: from12!.citylist,
  //         style: TextStyle(color: notifier.textColor,fontSize: 16.0),
  //         decoration: InputDecoration(
  //             contentPadding: const EdgeInsets.only(top: 30),
  //             prefixIcon: const Padding(
  //               padding: EdgeInsets.all(9),
  //               child: Image(image: AssetImage('assets/bus.png')),
  //             ),
  //             hintText: 'From'.tr,hintStyle: TextStyle(color: notifier.textColor),
  //             focusedBorder: OutlineInputBorder(
  //               borderSide: BorderSide(color: notifier.theamcolorelight),
  //               borderRadius: const BorderRadius.all(Radius.circular(10)),
  //             ),
  //             border: const OutlineInputBorder(
  //               borderSide: BorderSide(color: Colors.red),
  //               borderRadius: BorderRadius.all(Radius.circular(10)),
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
  //               borderRadius: const BorderRadius.all(Radius.circular(10)),
  //             ),
  //         ),
  //         itemFilter: (item,query){
  //           print(query);
  //           return item.title.toLowerCase().contains(query.toLowerCase());
  //         },
  //         itemSorter: (a,b){
  //           print("$a $b");
  //           return a.title.compareTo(b.title);
  //         },
  //         cursorColor: notifier.textColor,
  //         itemSubmitted: (item){
  //
  //           print("ITEM:- ${item.title}");
  //           setState(() {
  //             bordingId = item.id;
  //           });
  //
  //           _suggestionTextFiledControoler.text = item.title;
  //
  //           setState(() {
  //
  //           });
  //
  //         },
  //         itemBuilder: (context , item){
  //           return Accordion(
  //             contentBorderColor: Colors.black,
  //             contentBorderRadius: 20,
  //             headerBorderColor: Colors.black,
  //             contentBorderWidth: 1,
  //             disableScrolling: true,
  //             flipRightIconIfOpen: true,
  //             contentVerticalPadding: 0,
  //             scrollIntoViewOfItems: ScrollIntoViewOfItems.fast,
  //             maxOpenSections: 1,
  //             headerBackgroundColorOpened: Colors.red,
  //             // headerPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
  //             children: [
  //                 AccordionSection(
  //                   contentBorderColor: Colors.black,
  //                   // headerBackgroundColorOpened: theamcolore,
  //                   paddingBetweenOpenSections: 0,
  //                   paddingBetweenClosedSections: 0,
  //                   headerPadding: const EdgeInsets.all(15),
  //                   headerBackgroundColor: Colors.grey.shade100,
  //                   contentBackgroundColor: Colors.grey.shade100,
  //                   onOpenSection: () {
  //                     setState(() {
  //                       suggestionontap = true;
  //                       print("IIDIDIDDIDIDIDIDD:- ${item.id}");
  //                       print("suggestionontap:- ${suggestionontap}");
  //                       Point_Api(city_id: "${item.id}");
  //                     });
  //                   },
  //                   rightIcon: Icon(Icons.keyboard_arrow_down_outlined,color: Colors.black,),
  //                   header: Text(
  //                     "${item.title}",
  //                     style: TextStyle(
  //                       color: Colors.black,
  //                       fontSize: 15,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   content: suggestionontap == true ? Center(child: CircularProgressIndicator(color: theamcolore,),) : ListView.builder(
  //                     padding: EdgeInsets.zero,
  //                     shrinkWrap: true,
  //                     itemCount: pointApiModel!.citylist!.length,
  //                     itemBuilder: (context, index) {
  //                       return Padding(
  //                         padding: const EdgeInsets.only(bottom: 10),
  //                         child: Container(
  //                           // height: 40,
  //                           padding: EdgeInsets.all(10),
  //                           width: Get.width,
  //                           decoration: BoxDecoration(
  //                             color: theamcolore,
  //                               // color: Colors.grey.withOpacity(0.1),
  //                               borderRadius: BorderRadius.circular(15)
  //                           ),
  //                           child: ListTile(
  //                             contentPadding: EdgeInsets.zero,
  //                             title: Text("${pointApiModel!.citylist![index].title}",style: TextStyle(color: Colors.white),),
  //                             subtitle: Text("${pointApiModel!.citylist![index].address}",style: TextStyle(color: Colors.white),),
  //                           ),
  //                         ),
  //                       );
  //                     },),
  //                   contentHorizontalPadding: 20,
  //                   contentVerticalPadding: 10,
  //                   contentBorderWidth: 1,
  //                 ),
  //             ],
  //           );
  //         }, key: key1,
  //       ),
  //     ),
  //   );
  // }


  GlobalKey<AutoCompleteTextFieldState<dynamic>> key = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<dynamic>> key1 = GlobalKey();

  GlobalKey<AutoCompleteTextFieldState<dynamic>> key_sub = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<dynamic>> key1_sub = GlobalKey();

  final _suggestionTextFiledControoler = TextEditingController();
  final _suggestionTextFiledControoler1 = TextEditingController();
  final _suggestionTextFiledControoler_sub = TextEditingController();
  final _suggestionTextFiledControoler1_sub = TextEditingController();
  void fun(){
    setState(() {

      var temp2 = bordingId;
      bordingId = dropId;
      dropId = temp2;

      var temp = _suggestionTextFiledControoler.text;
      _suggestionTextFiledControoler.text = _suggestionTextFiledControoler1.text;
      _suggestionTextFiledControoler1.text = temp;

    });
  }


  String FromId = "";
  String ToId = "";

  Widget textfildefrom(){
    return textfildeloading == true ? SizedBox() : SizedBox(
      height: 45,
      child: Center(
        child: AutoCompleteTextField(
          controller: _suggestionTextFiledControoler,
          clearOnSubmit: false,
          suggestions: from12!.citylist,
          style: TextStyle(color: notifier.textColor,fontSize: 16.0),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(top: 30),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(9),
              child: Image(image: AssetImage('assets/bus.png')),
            ),
            hintText: 'From'.tr,hintStyle: TextStyle(color: notifier.textColor),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: notifier.theamcolorelight),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          itemFilter: (item,query){
            print(query);
            return item.title.toLowerCase().contains(query.toLowerCase());
          },
          itemSorter: (a,b){
            print("$a $b");
            return a.title.compareTo(b.title);
          },
          cursorColor: notifier.textColor,
          itemSubmitted: (item){
            print("ITEM:- ${item.title}");
            setState(() {
              bordingId = item.id;
              FromId = item.id;
            });
            // _suggestionTextFiledControoler.text = item.title;
            _suggestionTextFiledControoler.text = item.title;


               setState(() {
                 FromLoader = true;
               });
              Point_Api(city_id: FromId).then((value) {
                if (value != null) {
                  setState(() {
                    pointApiModel = value;
                    key_sub = GlobalKey<AutoCompleteTextFieldState>();
                    print("MY API DATA:- ${pointApiModel!.citylist![0].address}");
                  });
                }
              });

            setState(() {});
          },
          itemBuilder: (context , item){
            return Container(
              color: notifier.containercolore,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(
                    item.title,
                    style: TextStyle(color: notifier.textColor),
                  ),
                ],
              ),
            );
          }, key: key1,
        ),
      ),
    );
  }

  Widget textfildeto(){
    return textfildeloading == true ? SizedBox() : SizedBox(
      height: 45,
      child: Center(
        child: AutoCompleteTextField(
          controller: _suggestionTextFiledControoler1,
          clearOnSubmit: false,
          suggestions: from12!.citylist,
          style: TextStyle(color: notifier.textColor,fontSize: 16.0),
          decoration:  InputDecoration(
              contentPadding: const EdgeInsets.only(top: 10),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(9),
                child: Image(image: AssetImage('assets/bus.png'),height: 25,width: 25),
              ),
              hintText: 'To'.tr,hintStyle: TextStyle(color: notifier.textColor),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: notifier.theamcolorelight),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
          ),
          cursorColor: notifier.textColor,
          itemFilter: (item,query){
            print("---q---$query");
            print("--item --${item.title}");
            return item.title.toLowerCase().contains(query.toLowerCase());
          },
          itemSorter: (a,b){
            print("++++++++++++++++++++++++------------526844565$a $b");
            print("++++++++++++++++++++++++------------526844565");
            return a.title.compareTo(b.title);
          },
          itemSubmitted: (item){

            setState(() {
              dropId = item.id;
              ToId = item.id;
            });

            _suggestionTextFiledControoler1.text = item.title;
            setState(() {
              ToLoader = true;
            });
              Point_Api(city_id: ToId).then((value) {
                if (value != null) {
                  setState(() {
                    pointApiModel = value;
                    key1_sub = GlobalKey<AutoCompleteTextFieldState>();
                    print("MY API DATA:- ${pointApiModel!.citylist![0].address}");
                  });
                }
              });


          },
          itemBuilder: (context , item){
            return Container(
              color: notifier.containercolore,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(
                    item.title,
                    style: TextStyle(color: notifier.textColor),
                  ),
                ],
              ),
            );
          },key: key,
        ),
      ),
    );
  }



  bool FromLoader = false;
  bool ToLoader = false;


  // SUB SCREEN
  FocusNode _focusNode_sub = FocusNode();
  FocusNode _focusNode_sub1 = FocusNode();


  String from_point_id = "";
  String to_point_id = "";

  double From_Lat = 0.0;
  double From_Long = 0.0;
  double To_Lat = 0.0;
  double To_Long = 0.0;

  Widget textfildefrom_sub(){
    return SizedBox(
      height: 45,
      child: Center(
        child: AutoCompleteTextField(
          focusNode: _focusNode_sub,
          controller: _suggestionTextFiledControoler_sub,
          clearOnSubmit: false,
          suggestions: pointApiModel!.citylist!,
          style: TextStyle(color: notifier.textColor,fontSize: 16.0),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(top: 30,left: 10,right: 10),
            hintText: 'From Sub'.tr,hintStyle: TextStyle(color: notifier.textColor),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: notifier.theamcolorelight),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onFocusChanged: (hasFocus) {
            if (hasFocus && FromId.isNotEmpty) {
              Point_Api(city_id: FromId).then((value) {
                if (value != null) {
                  setState(() {
                    pointApiModel = value;
                    // key_sub = GlobalKey<AutoCompleteTextFieldState>();
                    print("MY API DATA:- ${pointApiModel!.citylist![0].address}");
                  });
                }
              });
            }
          },
          itemFilter: (item,query){
            print(query);
            return item.title.toLowerCase().contains(query.toLowerCase());
          },
          itemSorter: (a,b){
            print("$a $b");
            return a.title.compareTo(b.title);
          },
          cursorColor: notifier.textColor,
          itemSubmitted: (item){

            setState(() {});

            _suggestionTextFiledControoler_sub.text = item.title;
            from_point_id = item.id;
            From_Lat  = double.parse(item.lats);
            From_Long = double.parse(item.longs);

            print("FROM LAT :- ${From_Lat}");
            print("FROM LONG :- ${From_Long}");

            // Future.delayed(Duration(milliseconds: 10), () {
            //   FocusScope.of(context).requestFocus(FocusNode()); // unfocus
            //   FocusScope.of(context).requestFocus(FocusNode()); // optional reset
            //   FocusScope.of(context).requestFocus(_focusNode_sub); // refocus
            // });

            setState(() {

            });

          },
          itemBuilder: (context , item){
            return Container(
              color: notifier.containercolore,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(
                    item.title,
                    style: TextStyle(color: notifier.textColor),
                  ),
                ],
              ),
            );
          }, key: key_sub,
        ),
      ),
    );
  }


  Widget textfildefrom_sub_dummy(){
    return SizedBox(
      height: 45,
      child: Center(
        child: AbsorbPointer(
          child: AutoCompleteTextField(
            focusNode: _focusNode_sub,
            controller: _suggestionTextFiledControoler_sub,
            clearOnSubmit: false,
            suggestions: pointApiModel!.citylist!,
            style: TextStyle(color: notifier.textColor,fontSize: 16.0),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(top: 30,left: 10,right: 10),
              hintText: 'From Sub'.tr,hintStyle: TextStyle(color: notifier.textColor),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: notifier.theamcolorelight),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onFocusChanged: (hasFocus) {
              if (hasFocus && FromId.isNotEmpty) {
                Point_Api(city_id: FromId).then((value) {
                  if (value != null) {
                    setState(() {
                      pointApiModel = value;
                      // key_sub = GlobalKey<AutoCompleteTextFieldState>();
                      print("MY API DATA:- ${pointApiModel!.citylist![0].address}");
                    });
                  }
                });
              }
            },
            itemFilter: (item,query){
              print(query);
              return item.title.toLowerCase().contains(query.toLowerCase());
            },
            itemSorter: (a,b){
              print("$a $b");
              return a.title.compareTo(b.title);
            },
            cursorColor: notifier.textColor,
            itemSubmitted: (item){
          
              setState(() {});
          
              _suggestionTextFiledControoler_sub.text = item.title;
              from_point_id = item.id;
              From_Lat  = double.parse(item.lats);
              From_Long = double.parse(item.longs);
          
              print("FROM LAT :- ${From_Lat}");
              print("FROM LONG :- ${From_Long}");
          
              // Future.delayed(Duration(milliseconds: 10), () {
              //   FocusScope.of(context).requestFocus(FocusNode()); // unfocus
              //   FocusScope.of(context).requestFocus(FocusNode()); // optional reset
              //   FocusScope.of(context).requestFocus(_focusNode_sub); // refocus
              // });
          
              setState(() {
          
              });
          
            },
            itemBuilder: (context , item){
              return Container(
                color: notifier.containercolore,
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(color: notifier.textColor),
                    ),
                  ],
                ),
              );
            }, key: key_sub,
          ),
        ),
      ),
    );
  }

  Widget textfildeto_sub(){
    return SizedBox(
      height: 45,
      child: Center(
        child: AutoCompleteTextField(
          focusNode: _focusNode_sub1,
          controller: _suggestionTextFiledControoler1_sub,
          clearOnSubmit: false,
          suggestions: pointApiModel!.citylist!,
          style:  TextStyle(color: notifier.textColor,fontSize: 16.0),
          decoration:  InputDecoration(
            contentPadding: const EdgeInsets.only(top: 10,left: 10,right: 10),
            hintText: 'To Sub'.tr,hintStyle: TextStyle(color: notifier.textColor),
            focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: notifier.theamcolorelight),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          cursorColor: notifier.textColor,
          onFocusChanged: (hasFocus) {
            if (hasFocus && ToId.isNotEmpty) {
              Point_Api(city_id: ToId).then((value) {
                if (value != null) {
                  setState(() {
                    pointApiModel = value;
                    // key1_sub = GlobalKey<AutoCompleteTextFieldState>();
                    print("MY API DATA:- ${pointApiModel!.citylist![0].address}");
                  });
                }
              });
            }
          },
          itemFilter: (item,query){
            print("---q---$query");
            print("--item --${item.title}");
            return item.title.toLowerCase().contains(query.toLowerCase());
          },
          itemSorter: (a,b){
            print("++++++++++++++++++++++++------------526844565$a $b");
            print("++++++++++++++++++++++++------------526844565");
            return a.title.compareTo(b.title);
          },
          itemSubmitted: (item){

            setState(() {
            });

            _suggestionTextFiledControoler1_sub.text = item.title;
            to_point_id = item.id;

            To_Lat  = double.parse(item.lats);
            To_Long = double.parse(item.longs);

            print("TO LAT :- ${To_Lat}");
            print("TO LONG :- ${To_Long}");

            // Future.delayed(Duration(milliseconds: 100), () {
            //   FocusScope.of(context).requestFocus(FocusNode()); // unfocus
            //   FocusScope.of(context).requestFocus(FocusNode()); // optional reset
            //   FocusScope.of(context).requestFocus(_focusNode_sub1); // refocus
            // });
            setState(() {
            });

          },
          itemBuilder: (context , item){
            return Container(
              color: notifier.containercolore,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(
                    item.title,
                    style: TextStyle(color: notifier.textColor),
                  ),
                ],
              ),
            );
          },key: key1_sub,
        ),
      ),
    );
  }

  Widget textfildeto_sub_dummy(){
    return SizedBox(
      height: 45,
      child: Center(
        child: AbsorbPointer(
          child: AutoCompleteTextField(
            focusNode: _focusNode_sub1,
            controller: _suggestionTextFiledControoler1_sub,
            clearOnSubmit: false,
            suggestions: pointApiModel!.citylist!,
            style:  TextStyle(color: notifier.textColor,fontSize: 16.0),
            decoration:  InputDecoration(
              contentPadding: const EdgeInsets.only(top: 10,left: 10,right: 10),
              hintText: 'To Sub'.tr,hintStyle: TextStyle(color: notifier.textColor),
              focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: notifier.theamcolorelight),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
            cursorColor: notifier.textColor,
            onFocusChanged: (hasFocus) {
              if (hasFocus && ToId.isNotEmpty) {
                Point_Api(city_id: ToId).then((value) {
                  if (value != null) {
                    setState(() {
                      pointApiModel = value;
                      // key1_sub = GlobalKey<AutoCompleteTextFieldState>();
                      print("MY API DATA:- ${pointApiModel!.citylist![0].address}");
                    });
                  }
                });
              }
            },
            itemFilter: (item,query){
              print("---q---$query");
              print("--item --${item.title}");
              return item.title.toLowerCase().contains(query.toLowerCase());
            },
            itemSorter: (a,b){
              print("++++++++++++++++++++++++------------526844565$a $b");
              print("++++++++++++++++++++++++------------526844565");
              return a.title.compareTo(b.title);
            },
            itemSubmitted: (item){
          
              setState(() {
              });
          
              _suggestionTextFiledControoler1_sub.text = item.title;
              to_point_id = item.id;
          
              To_Lat  = double.parse(item.lats);
              To_Long = double.parse(item.longs);
          
              print("TO LAT :- ${To_Lat}");
              print("TO LONG :- ${To_Long}");
          
              // Future.delayed(Duration(milliseconds: 100), () {
              //   FocusScope.of(context).requestFocus(FocusNode()); // unfocus
              //   FocusScope.of(context).requestFocus(FocusNode()); // optional reset
              //   FocusScope.of(context).requestFocus(_focusNode_sub1); // refocus
              // });
              setState(() {
              });
          
            },
            itemBuilder: (context , item){
              return Container(
                color: notifier.containercolore,
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(color: notifier.textColor),
                    ),
                  ],
                ),
              );
            },key: key1_sub,
          ),
        ),
      ),
    );
  }


}
