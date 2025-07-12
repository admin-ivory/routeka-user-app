import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:routekacustomernew/sub_screen/parcel_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Sub_Screen/search_bus_screen.dart';
import '../api_model/parcel_list_api_model.dart';
import '../config/config.dart';
import '../config/light_and_dark.dart';

class ParcelListScreen extends StatefulWidget {
  const ParcelListScreen({super.key});

  @override
  State<ParcelListScreen> createState() => _ParcelListScreenState();
}

class _ParcelListScreenState extends State<ParcelListScreen> {

  @override
  void initState() {
    getlocledata();
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
      Parcel_List(uid: userData["id"].toString());
      print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["id"]}');
    });
  }


  bool isloading = true;
  PracelListApiModel? pracelListApiModel;

  Future Parcel_List({required String uid}) async {

    Map body = {
      "uid": uid,
    };

    print("---------- Parcel_List ---------- :- $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/api/get_parcel_history.php'), body: jsonEncode(body),headers: {
        'Content-Type': 'application/json',
      });

      if(response.statusCode == 200){
        print("---------- Parcel_List ---------- :- ${response.body}");

        setState(() {
          pracelListApiModel = pracelListApiModelFromJson(response.body);
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
        backgroundColor: notifier.appbarcolore,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title:  Text('Luggage Booking'.tr,style: const TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)),
      ),
      body: isloading ?  Center(child: CircularProgressIndicator(color: notifier.theamcolorelight)) :  SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            if (pracelListApiModel!.parcelHistory!.isEmpty) Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(image: AssetImage('assets/amyticket.png'),height: 70,width: 70,),
                  const SizedBox(height: 15,),
                  Text('No booking found'.tr,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: notifier.textColor),),
                  const SizedBox(height: 25,),
                  Text('You dont`t have any booking records!'.tr,style: const TextStyle(color: Colors.grey),),
                ],
              ),
            ) else ListView.separated(
              physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 0);
                },
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: pracelListApiModel!.parcelHistory!.length,
                itemBuilder: (BuildContext context, int index) {

                  return Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ParcelDetailScreen(parcel_id: pracelListApiModel!.parcelHistory![index].parcelId.toString()),));
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => Booking_Details(isDownload: true,ticket_id: data.tickethistory[index].ticketId,cancel: true),));
                      },
                      child: Container(
                        // height: 200,
                        width: MediaQuery.of(context).size.width*0.8,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: notifier.containercoloreproper,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                          color: const Color(0xff7D2AFF),
                                          borderRadius: BorderRadius.circular(65),
                                          image: DecorationImage(image: NetworkImage('${config().baseUrl}/${pracelListApiModel!.parcelHistory![index].busImg}'),fit: BoxFit.fill))
                                  ),
                                  const SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(pracelListApiModel!.parcelHistory![index].busTitle.toString(),style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: notifier.textColor)),
                                      const SizedBox(height: 5),
                                      Text(pracelListApiModel!.parcelHistory![index].tripDate.toString().split(' ').first,style: TextStyle(color: notifier.theamcolorelight,fontSize: 12,fontWeight: FontWeight.bold),),
                                      // Row(
                                      //   children: [
                                      //     if(data.tickethistory[index].isAc == '1')  Text('AC Seater'.tr,style: TextStyle(fontSize: 12,color: notifier.textColor))  else Text('Non Ac'.tr,style: TextStyle(fontSize: 12,color: notifier.textColor)),
                                      //   ],
                                      // )
                                    ],
                                  ),
                                  const Spacer(),
                                  const SizedBox(width: 4,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('$searchbus${pracelListApiModel!.parcelHistory![index].price}',style: TextStyle(color: notifier.theamcolorelight,fontSize: 15,fontWeight: FontWeight.bold),),
                                      const SizedBox(height: 5),
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
                                          Text(pracelListApiModel!.parcelHistory![index].fromCity.toString(),style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor),maxLines: 1,overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 8,),
                                          Text(pracelListApiModel!.parcelHistory![index].tripDate.toString().split(" ").first,style:  TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.theamcolorelight)),
                                          const SizedBox(height: 8,),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  Column(
                                    children: [
                                      Image(image: const AssetImage('assets/Auto Layout Horizontal.png'),color:notifier.theamcolorelight,width: 120,height: 50,),
                                      Text("${pracelListApiModel!.parcelHistory![index].distance.toString()} Km",style:  TextStyle(fontSize: 12,color: notifier.textColor)),
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
                                          Text(pracelListApiModel!.parcelHistory![index].toCity.toString(),style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: notifier.textColor),maxLines: 1,overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 8,),
                                          Text(pracelListApiModel!.parcelHistory![index].tripDate.toString().split(" ").first,style:  TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.theamcolorelight)),
                                          const SizedBox(height: 8,),
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
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
