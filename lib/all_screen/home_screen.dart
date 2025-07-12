// ignore_for_file: camel_case_types, non_constant_identifier_names, depend_on_referenced_packages, avoid_print, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:routekacustomernew/All_Screen/login_screen.dart';
import '../API_MODEL/home_data_api_model.dart';
import '../API_MODEL/search_get_api_model.dart';
import 'package:http/http.dart' as http;
import '../Sub_Screen/booking_details_screen.dart';
import '../Sub_Screen/search_bus_screen.dart';
import '../api_controller/sms_api_controller.dart';
import '../config/config.dart';
import '../config/light_and_dark.dart';
import 'my_account_screen.dart';

import 'dart:io'; // For SocketException
import 'dart:async';



String MAPKEY = "";

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {


   ScrollController controller = ScrollController();

   TextEditingController controllerfrom = TextEditingController();
   TextEditingController controllerto = TextEditingController();

   int currentIndex = 0;
   int selectcontain = 0;
   int currentIndex1 = -1;

   bool updown = false;

   final _suggestionTextFiledControoler = TextEditingController();
   final _suggestionTextFiledControoler1 = TextEditingController();



   String bordingId= "";
   String dropId= "";
   bool isloading = true;



  @override
    void initState() {
      // TODO: implement initState
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   checkServerStatus();
    // });
      getlocledata();
      super.initState();
    }



   // Future<void> checkServerStatus() async {
   //   try {
   //     // Replace with your API endpoint
   //     final response = await http
   //         .get(Uri.parse('${config().baseUrl}'))
   //         .timeout(const Duration(seconds: 10)); // Timeout after 10 seconds
   //
   //     if (response.statusCode != 200) {
   //       _showErrorDialog(
   //           'Server Error', 'Server returned status: ${response.statusCode}');
   //     }
   //   } on TimeoutException {
   //     // Handle timeout
   //     _showErrorDialog(
   //         'Server Timeout', 'Server is not responding. Please try again later.');
   //   } on SocketException {
   //     // Handle no internet or server unreachable
   //     _showErrorDialog('Connection Error',
   //         'Unable to connect to the server. Please check your internet connection.');
   //   } catch (e) {
   //     // Handle other errors
   //     _showErrorDialog('Error', 'An unexpected error occurred: $e');
   //   }
   // }
   //
   //
   //
   // void _showErrorDialog(String title, String message) {
   //   showDialog(
   //     context: context,
   //     barrierDismissible: false, // Prevent dismissing by tapping outside
   //     builder: (BuildContext context) {
   //       return AlertDialog(
   //         title: Text(title),
   //         content: Text(message),
   //         actions: <Widget>[
   //           TextButton(
   //             onPressed: () {
   //               Navigator.of(context).pop(); // Close dialog
   //               // Optionally retry the API call
   //               checkServerStatus();
   //             },
   //             child: const Text('Retry'),
   //           ),
   //           TextButton(
   //             onPressed: () {
   //               Navigator.of(context).pop(); // Close dialog
   //               // Optionally exit or navigate elsewhere
   //             },
   //             child: const Text('OK'),
   //           ),
   //         ],
   //       );
   //     },
   //   );
   // }




  //  GET API CALLING
  FromtoModel? from12;
   bool searchloading = true;

  Future SearchGet() async {
    var response1 = await http.get(Uri.parse('${config().baseUrl}/api/citylist.php'),);
    if (response1.statusCode == 200) {
      var jsonData = json.decode(response1.body);
      print(jsonData["citylist"]);
      setState(() {
        searchloading = false;
        from12 = fromtoModelFromJson(response1.body);
      });
    }
  }

  //Share preferance
   var userData;
   var searchbus;

 getlocledata() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    userData  = jsonDecode(prefs.getString("loginData")!);
    searchbus = jsonDecode(prefs.getString('currency')!);
    SearchGet();
    Home_Data_Api(userData['id']);

    print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["id"]}');
    // print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["id"]}');
  });
}

 // Home_Data_Api Api Calling

 Homedata? data1;

  Future Home_Data_Api(String uid) async {

    Map body = {
      'uid' : uid,
    };

    print("+++ $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/api/home_data.php'), body: jsonEncode(body),headers: {
        'Content-Type': 'application/json',
      });

      if(response.statusCode == 200){
      print(response.body);

        setState(() {
          data1 = homedataFromJson(response.body);
          isloading = false;
        });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("withdrawlimit", jsonEncode(data1?.withdrawLimit));
      prefs.setString("currency", jsonEncode(data1?.currency));
      prefs.setString("tax", jsonEncode(data1?.tax));

      // print("GOOGLE MAP KEY:- ${data1?.g_key}");
      // MAPKEY = data1!.g_key;
      // print("MAPKEY:- ${MAPKEY}");
      // config().mapkey = MAPKEY;
      // print("CONFIG MAP KEY:- ${config().mapkey}");


      print("GOOGLE MAP KEY:- ${data1?.g_key}");
      MAPKEY = data1!.g_key;
      print("MAPKEY:- ${MAPKEY}");

      final cfg = config(); // Only one instance now
      cfg.mapkey = MAPKEY;
      print("CONFIG MAP KEY:- ${config().mapkey}");

      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> _refresh()async {
    Future.delayed(const Duration(seconds: 1),() {
      setState(() {
        SearchGet();
        Home_Data_Api(userData['id']);
      });
    },);
  }

  ColorNotifier notifier = ColorNotifier();

  bool isHover=false;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Image(image: AssetImage('assets/log_routeka.png'),height: 60,width: 60),
            const SizedBox(width: 10,),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Routeka'.tr,style: TextStyle(color: notifier.theamcolorelight,fontSize: 20,fontFamily: 'SofiaProBold'),),
            ),
          ],
        ),
      ),
      backgroundColor: notifier.background,
      body: searchloading == true ? Center(child: CircularProgressIndicator(color: notifier.theamcolorelight),) : isloading ?  Center(child: CircularProgressIndicator(color: notifier.theamcolorelight),) : RefreshIndicator(
        color: const Color(0xff7D2AFF),
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [



                      Stack(
                        children: [
                          Column(
                            children: [
                              textfildefrom(),
                              const SizedBox(height: 10,),
                              textfildeto(),
                            ],
                          ),
                          Positioned.directional(
                            textDirection:Directionality.of(context),
                            // right: 20,
                            end: 20,
                            top: 30,
                            child: InkWell(
                              onTap: () {
                                setState((){
                                  fun();
                                },
                              );
                             },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: notifier.background,
                                    border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                    borderRadius: BorderRadius.circular(10),
                                    // image: DecorationImage(image: AssetImage(''))
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Image(image: AssetImage('assets/arrow-down-arrow-up.png'),height: 25,width: 25,),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15,),

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

                              const Spacer(),

                              Row(
                                children: [
                                  Container(
                                    height: 30,
                                    width: 80,
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: selectcontain == 0 ? notifier.theamcolorelight :  const Color(0xffD6C1F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child:  ElevatedButton(
                                        style: ButtonStyle(elevation: const MaterialStatePropertyAll(0),textStyle: MaterialStatePropertyAll(TextStyle(color: selectcontain == 0 ? Colors.white : Colors.black)),backgroundColor: MaterialStatePropertyAll<Color?>(selectcontain == 0 ? notifier.theamcolorelight :  const Color(0xffD6C1F9)),shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))))),
                                        onPressed: () {

                                          setState(() {
                                            selectcontain = 0;
                                            selectedDateAndTime = DateTime.now();
                                          });

                                        },
                                        child: Center(child: Text('Today'.tr,style:  TextStyle(color: selectcontain == 0 ? Colors.white : Colors.white,fontSize: 13),))),
                                  ),
                                  Container(
                                    height: 30,
                                    margin:  const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child:  ElevatedButton(
                                        style: ButtonStyle(elevation: const MaterialStatePropertyAll(0),textStyle: MaterialStatePropertyAll(TextStyle(color: selectcontain == 1 ? Colors.white : Colors.black)),backgroundColor: MaterialStatePropertyAll<Color?>(selectcontain == 1 ? notifier.theamcolorelight :  const Color(0xffD6C1F9)),shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))))),
                                        onPressed: () {
                                          final now = DateTime.now();

                                          setState(() {
                                            selectcontain = 1;
                                            selectedDateAndTime =DateTime(now.year, now.month, now.day + 1);
                                          });

                                        },
                                        child: Text('Tomorrow'.tr,style:  TextStyle(color: selectcontain == 1 ? Colors.white : Colors.white,fontSize: 13),)),
                                  ),
                                ],
                              ),

                            ],
                          )
                      ),
                      const SizedBox(height: 10),
                      Container(
                         height: 40,
                         decoration: BoxDecoration(
                           color: notifier.theamcolorelight,
                           borderRadius: BorderRadius.circular(10),
                         ),
                         child:  ElevatedButton(
                           style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color?>(notifier.theamcolorelight),shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))))),
                             onPressed: () {
                               DateTime now = DateTime.now();
                               String nowDate = now.toString().split(" ").first;
                               String dynamiDate = selectedDateAndTime.toString().split(" ").first;
                               print(nowDate);
                               print(dynamiDate);
                               print(nowDate.compareTo(dynamiDate));

                               bool isnot = false;
                               bool isnot1 = false;


                               if(data1?.isBlock != "1"){



                               for(int a = 0;a<from12!.citylist.length;a++){

                                 if(from12!.citylist[a].title.compareTo(_suggestionTextFiledControoler.text) == 0 ){
                                   setState(() {
                                     isnot = true;
                                   });
                                 }else{

                                 }
                                 if(from12!.citylist[a].title.compareTo(_suggestionTextFiledControoler1.text) == 0 ){
                                   setState(() {
                                     isnot1 = true;
                                   });
                                 }else{

                                 }
                               }
                               if(isnot && isnot1){
                                 if(nowDate.compareTo(dynamiDate) == -1 || nowDate.compareTo(dynamiDate) == 0){
                                   if(_suggestionTextFiledControoler.text.isNotEmpty && _suggestionTextFiledControoler1.text.isNotEmpty) {
                                     Navigator.push(context, MaterialPageRoute(
                                       builder: (context) => Search_Bus_Screen(
                                         is_verify: data1!.isVerify,
                                           from: _suggestionTextFiledControoler.text,
                                           to: _suggestionTextFiledControoler1.text,
                                           boarding_id: bordingId,
                                           drop_id: dropId,
                                           trip_date: selectedDateAndTime
                                               .toString()
                                               .split(" ")
                                               .first),));
                                   }else{
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(content:  Text('Plese Enter Input'.tr),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                                     );
                                   }
                                 }else{
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content:  Text('Service Not Provide At This Date'.tr),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                                   );
                                 }
                               }else{

                                 _suggestionTextFiledControoler.clear();
                                 _suggestionTextFiledControoler1.clear();

                                 if(_suggestionTextFiledControoler.text.isEmpty){
                                   Fluttertoast.showToast(msg: 'Please enter your Origin City'.tr,);
                                 }
                                 if(_suggestionTextFiledControoler1.text.isEmpty){

                                   Fluttertoast.showToast(msg: 'Please enter your Destination City'.tr,);
                                 }

                               }
                               }else{
                                 Get.offAll(const Login_Screen());
                                 resetNew();
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content:  Text('Your profile has been blocked by the administrator, preventing you from using our app as a regular user.'.tr),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                                 );
                               }

                             },
                             child: Center(child: Text('Search Buses'.tr,style: const TextStyle(color: Colors.white,fontSize: 16),))),
                       ),

                       const SizedBox(height: 20,),

                       data1!.tickethistory.isEmpty ? const SizedBox() : Column (
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recent Booking'.tr,style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold,fontSize: 20),),
                          const SizedBox(height: 15,),
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 0);
                                },
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: data1!.tickethistory.length,
                                itemBuilder: (BuildContext context, int index) {

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Booking_Details(cancel: false,ticket_id: data1!.tickethistory[index].ticketId,isDownload: true),));
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*0.8,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(

                                        color: notifier.containercolore,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                    height: 35,
                                                    width: 35,
                                                    decoration: BoxDecoration(
                                                        color: const Color(0xff7D2AFF),
                                                        borderRadius: BorderRadius.circular(65),
                                                        image: DecorationImage(image: NetworkImage('${config().baseUrl}/${data1?.tickethistory[index].busImg}'),fit: BoxFit.fill))
                                                ),
                                                const SizedBox(width: 10,),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('${data1?.tickethistory[index].busName}',style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: notifier.textColor)),
                                                    const SizedBox(height: 5,),
                                                    Row(
                                                      children: [
                                                        if(data1?.tickethistory[index].isAc == '1')  Text('AC Seater'.tr,style: TextStyle(fontSize: 12,color: notifier.textColor)),

                                                      ],
                                                    )
                                                  ],
                                                ),
                                                const Spacer(),
                                                const SizedBox(width: 4,),
                                                Text('${data1?.currency}${data1?.tickethistory[index].ticketPrice}',style:  TextStyle(color: notifier.theamcolorelight,fontSize: 15,fontWeight: FontWeight.bold),),
                                              ],
                                            ),
                                            const SizedBox(height: 10,),
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
                                                        Text(data1!.tickethistory[index].boardingCity,style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor),overflow: TextOverflow.ellipsis,maxLines: 1),
                                                        const SizedBox(height: 8,),
                                                        Text(convertTimeTo12HourFormat(data1!.tickethistory[index].busPicktime),style:  TextStyle(fontWeight: FontWeight.bold,color: notifier.theamcolorelight),overflow: TextOverflow.ellipsis,maxLines: 1),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10,),
                                                Column(
                                                  children: [
                                                    Image(image: const AssetImage('assets/Auto Layout Horizontal.png'),height: 50,width: 100,color: notifier.theamcolorelight),
                                                    Text('${data1?.tickethistory[index].differencePickDrop}',style: TextStyle(fontSize: 12,color: notifier.textColor)),
                                                  ],
                                                ),
                                                const SizedBox(width: 10,),
                                                Flexible(
                                                  child: SizedBox(
                                                    width: 100,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Text('${data1?.tickethistory[index].dropCity}',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor),overflow: TextOverflow.ellipsis,maxLines: 1),
                                                        const SizedBox(height: 8,),
                                                        Text(convertTimeTo12HourFormat(data1!.tickethistory[index].busDroptime),style:  TextStyle(fontWeight: FontWeight.bold,color: notifier.theamcolorelight),overflow: TextOverflow.ellipsis,maxLines: 1),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                       const SizedBox(height: 15,),

                       Text('Special Offer'.tr,style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold,fontSize: 20),),
                       const SizedBox(height: 15,),
                       LayoutBuilder(builder: (context, constraints) {
                         return CarouselSlider(
                             items: [
                               for(int a =0; a< data1!.banner.length; a++) Column(
                                 children: [
                                   Container(
                                     height: constraints.maxWidth> 380 ? 165 : 135,
                                     width: MediaQuery.of(context).size.width,
                                     margin: const EdgeInsets.only(right: 10),
                                     decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(20),
                                         image: DecorationImage(image: NetworkImage('${config().baseUrl}/${data1?.banner[a].img}'),fit: BoxFit.fill)
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                             options: CarouselOptions(
                               height: 200,
                               // aspectRatio: 16/9,
                               viewportFraction: 0.8,
                               initialPage: 0,
                               enableInfiniteScroll: true,
                               reverse: false,
                               autoPlay: true,
                               autoPlayInterval: const Duration(seconds: 2),
                               autoPlayAnimationDuration: const Duration(milliseconds: 800),
                               autoPlayCurve: Curves.fastOutSlowIn,
                               enlargeCenterPage: true,
                               enlargeFactor: 0,
                               scrollDirection: Axis.horizontal,
                             )
                         );
                       },),


                       const SizedBox(height: 15,),

                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      )
    );
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



  Widget textfildefrom(){
   return SizedBox(
     height: 45,
     child: Center(
       child: AutoCompleteTextField(
         controller: _suggestionTextFiledControoler,
         clearOnSubmit: false,
         suggestions: from12!.citylist,
         style: TextStyle(color: notifier.textColor,fontSize: 16.0),
         decoration:  InputDecoration(
           contentPadding: const EdgeInsets.only(top: 30),
           prefixIcon: const Padding(
             padding: EdgeInsets.all(9),
             child: Image(image: AssetImage('assets/bus.png')),
           ),
           hintText: 'From'.tr,hintStyle: TextStyle(color: notifier.textColor),
           focusedBorder:  OutlineInputBorder(
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
           )
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
           });

           _suggestionTextFiledControoler.text = item.title;

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
         }, key: key1,
       ),
     ),
   );
  }

  GlobalKey<AutoCompleteTextFieldState<dynamic>> key = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<dynamic>> key1 = GlobalKey();

  Widget textfildeto(){
    return SizedBox(
      height: 45,
      child: Center(
        child: AutoCompleteTextField(
          controller: _suggestionTextFiledControoler1,
          clearOnSubmit: false,
          suggestions: from12!.citylist,
          style:  TextStyle(color: notifier.textColor,fontSize: 16.0),
          decoration:  InputDecoration(
            contentPadding: const EdgeInsets.only(top: 10),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(9),
              child: Image(image: AssetImage('assets/bus.png'),height: 25,width: 25,),
            ),
            hintText: 'to'.tr,hintStyle: TextStyle(color: notifier.textColor),
                focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: notifier.theamcolorelight),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            )
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
            });

            _suggestionTextFiledControoler1.text = item.title;

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

}
