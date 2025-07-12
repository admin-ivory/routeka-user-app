import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:routekacustomernew/config/light_and_dark.dart';
import 'package:routekacustomernew/sub_screen/book_parcel_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Sub_Screen/search_bus_screen.dart';
import '../api_model/searchbus_api_model.dart';
import '../config/config.dart';


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class ParcelSearchBus extends StatefulWidget {
  final String from_add;
  final String to_add;
  final String bordingId;
  final String dropId;
  final String from_id;
  final String to_id;
  final String trip_date;
  final String weight;
  final String wallete;
  final double From_Lat;
  final double From_Long;
  final double To_Lat;
  final double To_Long;
  const ParcelSearchBus({super.key, required this.from_add, required this.to_add, required this.from_id, required this.to_id, required this.bordingId, required this.dropId, required this.trip_date, required this.weight, required this.From_Lat, required this.From_Long, required this.To_Lat, required this.To_Long, required this.wallete});

  @override
  State<ParcelSearchBus> createState() => _ParcelSearchBusState();
}

class _ParcelSearchBusState extends State<ParcelSearchBus> {

  @override
  void initState() {
    getlocledata();
    print("from_add:- ${widget.from_add}");
    print("to_add:- ${widget.to_add}");
    print("bordingId:- ${widget.bordingId}");
    print("dropId:- ${widget.dropId}");
    print("from_id:- ${widget.from_id}");
    print("to_id:- ${widget.to_id}");
    print("From_Lat:- ${widget.From_Lat}");
    print("From_Long:- ${widget.From_Long}");
    print("To_Lat:- ${widget.To_Lat}");
    print("To_Long:- ${widget.To_Long}");
    // TODO: implement initState
    super.initState();
  }


  var userData;
  var searchbus;

  getlocledata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData  = jsonDecode(prefs.getString("loginData")!);
      searchbus = jsonDecode(prefs.getString('currency')!);
      kmDistance();

      Parcel_Bus_Search(uid: userData["id"].toString());

      print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["id"]}');
      // print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["id"]}');
    });
  }

  double totaldistance = 0.00;

  kmDistance(){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((widget.To_Lat - widget.From_Lat) * p) / 2 + cos(widget.From_Lat * p) * cos(widget.To_Lat * p) * (1 - cos((widget.To_Long - widget.From_Long) * p)) / 2;
    double totalKms  = 12742 * asin(sqrt(a));
    totaldistance = double.parse(totalKms.toStringAsFixed(2));
   print("DISTANCE OF KM:- ${totaldistance}");
  }


  bool isloading = true;

  SearchBusApiModel? searchBusApiModel;

  Future Parcel_Bus_Search({required String uid}) async {

    Map body = {
      "uid": uid,
      "boarding_id": widget.bordingId,
      "drop_id": widget.dropId,
      "from_point_id": widget.from_id,
      "to_point_id": widget.to_id,
      "trip_date": widget.trip_date,
      "weight": widget.weight,
      "distance": totaldistance
    };

    print("+++ $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/api/parcel_bus_search.php'), body: jsonEncode(body),headers: {
        'Content-Type': 'application/json',
      });

      if(response.statusCode == 200){
        print("---------- Parcel-Bus-Search ---------- :- ${response.body}");

        setState(() {
          searchBusApiModel = searchBusApiModelFromJson(response.body);
          isloading = false;
        });

      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.backgroundgray,

      appBar: AppBar(
        toolbarHeight: 70,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        backgroundColor: notifier.appbarcolore,
        title: Transform.translate(
          offset: const Offset(-15, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.from_add}  to  ${widget.to_add}', style: const TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 5,),
              Text(widget.trip_date.toString().split(" ").first, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ),


      // appBar: AppBar(
      //   toolbarHeight: 70,
      //   iconTheme: const IconThemeData(
      //     color: Colors.white,
      //   ),
      //   backgroundColor: notifier.appbarcolore,
      //   elevation: 0,
      //   actions: [
      //     const SizedBox(width: 60),
      //     SizedBox(
      //       height: 70,
      //       width: 200,
      //       child: ListTile(
      //         dense: true,
      //         contentPadding: EdgeInsets.zero,
      //         title: Padding(
      //           padding: const EdgeInsets.only(top: 0),
      //           child: Row(
      //             children: [
      //               Flexible(child: Text(widget.from_add,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 13,),maxLines: 1,overflow: TextOverflow.ellipsis,)),
      //               const SizedBox(width: 5,),
      //               const Image(image: AssetImage('assets/arrow-right.png'),color: Colors.white,height: 12,width: 12),
      //               const SizedBox(width: 5,),
      //               Flexible(child: Text(widget.to_add,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis,)),
      //             ],
      //           ),
      //         ),
      //         subtitle: Text(widget.trip_date,style: const TextStyle(color: Colors.white,fontSize: 12)),
      //       ),
      //     ),
      //     const Spacer(),
      //   ],
      // ),
      body: isloading == true ? Center(child: CircularProgressIndicator(color: theamcolore,),) : Column(
        children: [
          const SizedBox(height: 15,),

          searchBusApiModel!.busData!.isEmpty ?  Column(
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
              physics: BouncingScrollPhysics(),
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 15);
                },
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: searchBusApiModel!.busData!.length,
                itemBuilder: (BuildContext context, int index) {

                  // var date1 = DateFormat("HH:mm").parse(convertTimeTo12HourFormat(searchBusApiModel!.busData![index].busPicktime.toString()));
                  // var date2 = DateFormat("HH:mm").parse(convertTimeTo12HourFormat(searchBusApiModel!.busData![index].busDroptime.toString()));

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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => BookParcelScreen(
                                to_add: widget.to_add,
                                trip_date: widget.trip_date,
                                from_add: widget.from_add,
                                bus_id: searchBusApiModel!.busData![index].busId.toString(),
                                Operater_id: searchBusApiModel!.busData![index].operatorId.toString(),
                                from_city_id: widget.bordingId,
                                to_city_id: widget.dropId,
                                from_point_id: widget.from_id,
                                to_point_id: widget.to_id,
                                // parcel_weight: searchBusApiModel!.busData![index].remainingWeight.toString(),
                                parcel_weight: widget.weight,
                                price: searchBusApiModel!.busData![index].parcelPrice.toString(),
                                price_per_km: searchBusApiModel!.busData![index].pricePerKm.toString(),
                                distance: searchBusApiModel!.busData![index].distance.toString(),
                                wallete: widget.wallete,
                              ),));
                            },
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            color: notifier.theamcolorelight,
                                            borderRadius: BorderRadius.circular(65),
                                            image: DecorationImage(image: NetworkImage('${config().baseUrl}/${searchBusApiModel!.busData![index].busImg}'),fit: BoxFit.fill))
                                    ),
                                    const SizedBox(width: 10,),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(searchBusApiModel!.busData![index].busTitle.toString(),style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: notifier.textColor)),
                                          const SizedBox(height: 5,),
                                          // Row(
                                          //   children: [
                                          //     // if(searchBusApiModel!.busData![index].busAc == '1')  Flexible(child: Text('AC Seater'.tr,style: TextStyle(fontSize: 13,color: notifier.textColor),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                          //     // if(data.busData[index].isSleeper == '1')  Flexible(child: Text('Non Ac / Sleeper'.tr,style: TextStyle(fontSize: 13,color: notifier.textColor),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                          //     const SizedBox(width: 5,),
                                          //     Container(
                                          //         height: 22,
                                          //         width: 65,
                                          //         decoration: BoxDecoration(
                                          //             border: Border.all(color: notifier.seatbordercolore),
                                          //             color: notifier.seatcontainere,
                                          //             borderRadius: BorderRadius.circular(5)
                                          //         ),
                                          //         child: Center(child: Padding(
                                          //           padding: const EdgeInsets.only(top: 3),
                                          //           child: Text('${searchBusApiModel!.busData[index].totlSeat} Seats',style:  TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.seattextcolore),overflow: TextOverflow.ellipsis,maxLines: 1,),
                                          //         ))
                                          //     ),
                                          //   ],
                                          // )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4,),
                                    Spacer(),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text('${searchBusApiModel!.currency}${searchBusApiModel!.busData![index].parcelPrice}',style: TextStyle(color: notifier.theamcolorelight,fontSize: 15,fontWeight: FontWeight.bold),),
                                            SizedBox(width: 5),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 4.0),
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      Get.bottomSheet(isScrollControlled: true,StatefulBuilder(
                                                          builder: (context, setState)  {
                                                            return Container(
                                                              // height: 200,
                                                              decoration: BoxDecoration(
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
                                                                      SizedBox(height: 10),
                                                                      Container(
                                                                        padding: EdgeInsets.all(10),
                                                                        decoration: BoxDecoration(
                                                                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                                                          borderRadius: BorderRadiusGeometry.all(Radius.circular(10))
                                                                        ),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Column(
                                                                                  children: [
                                                                                    Text("Min weight".tr,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)
                                                                                  ],
                                                                                ),
                                                                                Spacer(),
                                                                                Column(
                                                                                  children: [
                                                                                    Text("Max weight".tr,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)
                                                                                  ],
                                                                                ),
                                                                                Spacer(),
                                                                                Column(
                                                                                  children: [
                                                                                    Text("Price Per Km".tr,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)
                                                                                  ],
                                                                                ),
                                                                                Spacer(),
                                                                                Column(
                                                                                  children: [
                                                                                    Text("Total".tr,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(height: 5),
                                                                            Divider(color: Colors.grey.withOpacity(0.4),),
                                                                            SizedBox(height: 5),
                                                                            Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Text("${searchBusApiModel!.busData![index].rateInfo!.matchedRate!.minWeight} kg",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.green),)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Spacer(),
                                                                                Expanded(
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Text("${searchBusApiModel!.busData![index].rateInfo!.matchedRate!.maxWeight} kg",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.green),)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Spacer(),
                                                                                Expanded(
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Text("${searchbus}${searchBusApiModel!.busData![index].rateInfo!.matchedRate!.pricePerKm}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.green),)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Spacer(),
                                                                                Expanded(
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Text("${searchbus}${searchBusApiModel!.busData![index].rateInfo!.matchedRate!.totalPrice}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.green),maxLines: 1)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),



                                                                            ListView.builder(
                                                                              physics: NeverScrollableScrollPhysics(),
                                                                              shrinkWrap: true,
                                                                              padding: EdgeInsets.zero,
                                                                              clipBehavior: Clip.none,
                                                                              itemCount: searchBusApiModel!.busData![index].rateInfo!.allRates!.length,
                                                                              itemBuilder: (context, index1) {
                                                                              return Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  SizedBox(height: 5),
                                                                                  Divider(color: Colors.grey.withOpacity(0.4),),
                                                                                  SizedBox(height: 5),
                                                                                  Row(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: Column(
                                                                                          children: [
                                                                                            Text("${searchBusApiModel!.busData![index].rateInfo!.allRates![index1].minWeight} kg",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: theamcolore),)
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      Spacer(),
                                                                                      Expanded(
                                                                                        child: Column(
                                                                                          children: [
                                                                                            Text("${searchBusApiModel!.busData![index].rateInfo!.allRates![index1].maxWeight} kg",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: theamcolore),)
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      Spacer(),
                                                                                      Expanded(
                                                                                        child: Column(
                                                                                          children: [
                                                                                            Text("${searchbus}${searchBusApiModel!.busData![index].rateInfo!.allRates![index1].pricePerKm}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: theamcolore),)
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      Spacer(),
                                                                                      Expanded(
                                                                                        child: Column(
                                                                                          children: [
                                                                                            Text("${searchbus}${searchBusApiModel!.busData![index].rateInfo!.allRates![index1].pricePerKm! * searchBusApiModel!.busData![index].distance!}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: theamcolore),maxLines: 1,)
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },)

                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 20),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                      ));
                                                    });
                                                  },
                                                  child: Icon(Icons.info_outline_rounded,color: theamcolore,size: 20,)),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 5,),
                                        // Tooltip(
                                        //   margin: const EdgeInsets.only(left: 30,right: 30),
                                        //   triggerMode: TooltipTriggerMode.tap,
                                        //   showDuration: const Duration(seconds: 2),
                                        //   message: 'Per ticket, you received the commission of ${(double.parse(searchBusApiModel!.busData![index].parcelPrice) * double.parse(data.busData[index].agentCommission) / 100).toStringAsFixed(2)}${data.currency}',
                                        //   child: Row(
                                        //     mainAxisAlignment: MainAxisAlignment.start,
                                        //     children: [
                                        //       userData['user_type'] == 'AGENT' ? Padding(padding: const EdgeInsets.only(top: 4), child: Text('${data.currency} ${(double.parse(data.busData[index].ticketPrice) * double.parse(data.busData[index].agentCommission) / 100).toStringAsFixed(2) }',style: const TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold)),) : const SizedBox(),
                                        //       const SizedBox(width: 5,),
                                        //       userData['user_type'] == 'AGENT' ?  const Image(image: AssetImage('assets/agenticon.png'),height: 15,width: 15,color: Colors.green,):const SizedBox()
                                        //     ],
                                        //   ),
                                        // ),
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
                                            Text(widget.from_add,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                            const SizedBox(height: 8,),
                                            Text(convertTimeTo12HourFormat(searchBusApiModel!.busData![index].busPicktime.toString()),style:   TextStyle(fontWeight: FontWeight.bold,color: notifier.theamcolorelight,fontSize: 12),overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8,),
                                            Text(widget.trip_date,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.textColor),overflow: TextOverflow.ellipsis),
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
                                        // Text(searchBusApiModel!.busData![index].differencePickDrop,style: TextStyle(fontSize: 12,color: notifier.textColor)),
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
                                            Text(widget.to_add,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor),overflow: TextOverflow.ellipsis,),
                                            const SizedBox(height: 8,),
                                            Text(convertTimeTo12HourFormat(searchBusApiModel!.busData![index].busDroptime.toString()),style:  TextStyle(fontWeight: FontWeight.bold,color: notifier.theamcolorelight ,fontSize: 12),overflow: TextOverflow.ellipsis,),
                                            const SizedBox(height: 8,),
                                            Text(widget.trip_date,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.textColor),overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8,),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Divider(color: Colors.grey.withOpacity(0.4)),
                                // const SizedBox(height: 8,),
                              ],
                            ),
                          ),

                          // Column(
                          //   children: [
                          //     Padding(
                          //       padding: const EdgeInsets.only(left: 0,right: 0),
                          //       child: Row(
                          //         children: [
                          //           Expanded(flex: 4,child: InkWell(
                          //               onTap: () {
                          //                 if(GridviewList.contains(index) == true){
                          //                   setState(() {
                          //                     GridviewList.remove(index);
                          //                   });
                          //                 }else{
                          //                   setState(() {
                          //                     GridviewList.add(index);
                          //                   });
                          //                 }
                          //               },
                          //               child:  Text('Amenities'.tr,style:  TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold,fontSize: 12),))),
                          //           Expanded(flex: 4,child: InkWell(
                          //               onTap: () {
                          //                 Review_list(data.busData[index].busId);
                          //               },
                          //               child:  Padding(
                          //                 padding:  const EdgeInsets.only(left: 15),
                          //                 child:  Text('Review'.tr,style:  TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold,fontSize: 12),),
                          //               ))),
                          //           Expanded(flex: 4,child: InkWell(
                          //               onTap: () {
                          //                 Get.bottomSheet(isScrollControlled: true,StatefulBuilder(
                          //                     builder: (context, setState)  {
                          //                       return Padding(
                          //                         padding: const EdgeInsets.only(top: 100),
                          //                         child: Container(
                          //                           // height: 200,
                          //                           decoration:  BoxDecoration(
                          //                             color: notifier.background,
                          //                             borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                          //                           ),
                          //                           child: Padding(
                          //                             padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                          //                             child: SingleChildScrollView(
                          //                               scrollDirection: Axis.vertical,
                          //                               child: Column(
                          //                                 mainAxisAlignment: MainAxisAlignment.center,
                          //                                 crossAxisAlignment: CrossAxisAlignment.center,
                          //                                 mainAxisSize: MainAxisSize.min,
                          //                                 children: [
                          //                                   Text(from12.pagelist[3].title,style:  TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: notifier.textColor)),
                          //                                   const SizedBox(height: 20,),
                          //                                   HtmlWidget(
                          //                                     from12.pagelist[3].description,
                          //                                     textStyle:  TextStyle(
                          //                                       color: notifier.textColor,
                          //                                       fontSize: 20,
                          //                                     ),
                          //                                   ),
                          //                                 ],
                          //                               ),
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       );
                          //                     }
                          //                 ));
                          //               },
                          //               child:  Text('Cancellation Policy'.tr,style:  TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold,fontSize: 12),))),
                          //         ],
                          //       ),
                          //     ),
                          //     GridviewList.contains(index) ?
                          //     Padding(
                          //       padding: const EdgeInsets.only(top: 15),
                          //       child: GridView.builder(
                          //         shrinkWrap: true,
                          //         gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                          //           crossAxisCount: 2,
                          //           mainAxisExtent: 20,
                          //           mainAxisSpacing: 10,
                          //         ),
                          //         physics: const NeverScrollableScrollPhysics(),
                          //         itemCount: data.busData[index].busFacilities.length,
                          //         itemBuilder: (BuildContext context, int index1) {
                          //           return Padding(
                          //             padding: const EdgeInsets.only(left: 20),
                          //             child: Row(
                          //               children: [
                          //                 Image(image: NetworkImage('${config().baseUrl}/${data.busData[index].busFacilities[index1].facilityimg}'),color: notifier.textColor),
                          //                 const SizedBox(width: 10,),
                          //                 Text(data.busData[index].busFacilities[index1].facilityname,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor)),
                          //               ],
                          //             ),
                          //           );
                          //         },
                          //       ),
                          //     ) : const SizedBox(),
                          //   ],
                          // ),
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
}
