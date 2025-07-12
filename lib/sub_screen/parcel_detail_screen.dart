import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../All_Screen/bottom_navigation_bar_screen.dart';
import '../Common_Code/common_button.dart';
import '../Common_Code/homecontroller.dart';
import '../Sub_Screen/search_bus_screen.dart';
import '../api_model/cancel_parcel_api_model.dart';
import '../api_model/parcel_detail_model.dart';
import '../config/config.dart';
import '../config/light_and_dark.dart';

class ParcelDetailScreen extends StatefulWidget {
  final String parcel_id;
  const ParcelDetailScreen({super.key, required this.parcel_id});

  @override
  State<ParcelDetailScreen> createState() => _ParcelDetailScreenState();
}

class _ParcelDetailScreenState extends State<ParcelDetailScreen> {


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
      Parcel_Details(uid: userData["id"].toString(), parcel_id: widget.parcel_id.toString());
      print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["id"]}');
    });
  }


  bool isloading = true;
  ParcelDetailApiModel? parcelDetailApiModel;

  Future Parcel_Details({required String uid,required String parcel_id}) async {

    Map body = {
      "uid": uid,
      "parcel_id": parcel_id,
    };

    print("---------- Parcel Details ---------- :- $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/api/parcel_details.php'), body: jsonEncode(body),headers: {
        'Content-Type': 'application/json',
      });

      if(response.statusCode == 200){
        print("---------- Parcel Details ---------- :- ${response.body}");

        setState(() {
          parcelDetailApiModel = parcelDetailApiModelFromJson(response.body);
          isloading = false;
        });

      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

  HomeController homeController = Get.put(HomeController());

  CancelParcelModel? cancelParcelModel;

  Future Cancel_Parcel_Api({required String uid,required String parcel_id}) async {
    Map body = {
      "uid": uid,
      "parcel_id": parcel_id,
    };

    print("+++--++ $body");

    try {
      var response = await http.post(Uri.parse('${config().baseUrl}/api/Cancel_Parcel.php'), body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });

      print(response.body);

      if (response.statusCode == 200) {

        setState(() {
          cancelParcelModel = cancelParcelModelFromJson(response.body);
          homeController.setselectpage(0);
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  const Bottom_Navigation(),));
          Get.offAll(const Bottom_Navigation());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cancelParcelModel!.responseMsg.toString()),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
        );
      } else {
        print('failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }


  ColorNotifier notifier = ColorNotifier();

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      bottomNavigationBar: isloading ? SizedBox() :  parcelDetailApiModel!.parcelHistory![0].status == "Pending" ? Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: CommonButton(containcolore: notifier.theamcolorelight, txt1: 'Cancel Order'.tr, context: context,onPressed1: () {
          setState(() {
            showModalBottomSheet<void>(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))),
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 200,
                  decoration:  BoxDecoration(
                      color: notifier.containercoloreproper,
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 25,),
                      Text('Cancel Order'.tr,style: TextStyle(color: notifier.theamcolorelight,fontWeight: FontWeight.bold,fontSize: 20)),
                      const SizedBox(height: 25,),
                      Text('Are you sure you want to cancel?'.tr,style: TextStyle(color: notifier.textColor,fontSize: 16,fontWeight: FontWeight.bold)),
                      const SizedBox(height: 25,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(fixedSize: const MaterialStatePropertyAll(Size(120, 40)),elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),backgroundColor: const MaterialStatePropertyAll(Colors.white)),
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'.tr,style: const TextStyle(color: Colors.black)),
                          ),
                          const SizedBox(width: 10,),
                          ElevatedButton(
                            style: ButtonStyle(fixedSize: const MaterialStatePropertyAll(Size(120, 40)),elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),backgroundColor:  MaterialStatePropertyAll<Color?>(notifier.theamcolorelight)),
                            onPressed: () => {
                              setState(() {
                               Cancel_Parcel_Api(uid: userData["id"].toString(), parcel_id: widget.parcel_id.toString());
                              })
                            },
                            child: Text('Cancel Order'.tr,style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );

          });
        }),
      ) : SizedBox(),
      backgroundColor: notifier.backgroundgray,
      appBar: AppBar(
        backgroundColor: notifier.appbarcolore,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text('Luggage Details'.tr, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: isloading ? Center(child: CircularProgressIndicator(color: notifier.theamcolorelight)) :  SingleChildScrollView(
        child:  Column(
          children: [
            const SizedBox(height: 10,),
            ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 0);
                },
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: parcelDetailApiModel!.parcelHistory!.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: InkWell(
                      onTap: () {
                      },
                      child: Container(
                        // height: 200,
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: const EdgeInsets.only(bottom: 0),
                        decoration: BoxDecoration(
                          color: notifier.containercoloreproper,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Row(
                                  children: [
                                    const Image(image: AssetImage('assets/Rectangle_2.png'), height: 40),
                                    const SizedBox(width: 15,),
                                    Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            color: const Color(0xff7D2AFF),
                                            borderRadius: BorderRadius.circular(65),
                                            image: DecorationImage(image: NetworkImage('${config().baseUrl}/${parcelDetailApiModel!.parcelHistory![index].busImg}'), fit: BoxFit.fill))),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text('${parcelDetailApiModel!.parcelHistory![index].busTitle}',style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: notifier.textColor)),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Text('${parcelDetailApiModel!.parcelHistory![0].busNo}',style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: notifier.textColor)),
                                            // if (data1?.tickethistory[index].isAc == '1') Text('AC Seater'.tr, style: TextStyle(fontSize: 12, color: notifier.textColor)) else Text('Non Ac'.tr,style: TextStyle(fontSize: 12,color: notifier.textColor)),
                                          ],
                                        )
                                        // const Text('Economy'),
                                      ],
                                    ),
                                    const Spacer(),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      '$searchbus${parcelDetailApiModel!.parcelHistory![index].price}',
                                      style:  TextStyle(
                                          color: notifier.theamcolorelight,
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15,),
                              Padding(
                                padding: const EdgeInsets.only(left: 15,right: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: SizedBox(
                                        width: 100,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(parcelDetailApiModel!.parcelHistory![index].fromCity.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: notifier.textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8,),
                                            // Text(convertTimeTo12HourFormat(data1!.tickethistory[index].busPicktime), style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: notifier.theamcolorelight), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8,),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    Column(
                                      children: [
                                        Image(image: const AssetImage('assets/Auto Layout Horizontal.png'), height: 50, width: 120, color: notifier.theamcolorelight),
                                        Text('${parcelDetailApiModel!.parcelHistory![index].distance} km', style: TextStyle(fontSize: 12, color: notifier.textColor)),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: SizedBox(
                                        width: 100,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text('${parcelDetailApiModel!.parcelHistory![index].toCity}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: notifier.textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8,),
                                            // Text(convertTimeTo12HourFormat(data1!.tickethistory[index].busDroptime), style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: notifier.theamcolorelight), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8,),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            const SizedBox(height: 10,),
            Container(
              // height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: notifier.containercoloreproper,
              ),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Image(
                            image:
                            AssetImage('assets/Rectangle_2.png'),
                            height: 40),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Bus Details'.tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: notifier.textColor),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        children: [
                          // Row(
                          //   children: [
                          //     Text('Bus No'.tr,
                          //         style: TextStyle(
                          //             fontWeight: FontWeight.bold,
                          //             fontSize: 12,
                          //             color: notifier.textColor
                          //         )),
                          //     const Spacer(),
                          //     Text(
                          //         '${parcelDetailApiModel!.parcelHistory![0].busNo}',
                          //         style: TextStyle(
                          //             fontWeight: FontWeight.bold,
                          //             fontSize: 12,
                          //             color: notifier.textColor)),
                          //   ],
                          // ),
                          // const SizedBox(
                          //   height: 15,
                          // ),
                          Row(
                            children: [
                              Text('Booking Date'.tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                              const Spacer(),
                              Text(
                                  parcelDetailApiModel!.parcelHistory![0].tripDate.toString().split(" ").first,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text('Payment Method'.tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                              const Spacer(),
                              Text(
                                  '${parcelDetailApiModel!.parcelHistory![0].pMethodName}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text('Transaction Id'.tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                              const Spacer(),
                              Text(
                                  '${parcelDetailApiModel!.parcelHistory![0].transactionId}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text('Luggage Id'.tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                              const Spacer(),
                              Text(
                                  '${parcelDetailApiModel!.parcelHistory![0].parcelId}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text('Status'.tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                              const Spacer(),
                              Container(
                                height: 30,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: theamcolore),
                                  borderRadius: BorderRadiusGeometry.all(Radius.circular(10))
                                ),
                                child: Center(
                                  child: Text(
                                      '${parcelDetailApiModel!.parcelHistory![0].status}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: notifier.textColor)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              // height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: notifier.containercoloreproper,
                // borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Image(
                            image:
                            AssetImage('assets/Rectangle_2.png'),
                            height: 40),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Contact Details'.tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: notifier.textColor),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Sender Name'.tr,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: notifier.textColor)),
                              const Spacer(),
                              Text(
                                  '${parcelDetailApiModel!.parcelHistory![0].senderName}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text('Sender Number'.tr,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: notifier.textColor)),
                              const Spacer(),
                              Text(
                                  '${parcelDetailApiModel!.parcelHistory![0].senderMobile}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text('Receiver Name'.tr,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: notifier.textColor)),
                              const Spacer(),
                              Text(
                                  '${parcelDetailApiModel!.parcelHistory![0].receiverName}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text('Receiver Number'.tr,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: notifier.textColor)),
                              const Spacer(),
                              Text(
                                  '${parcelDetailApiModel!.parcelHistory![0].receiverMobile}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: notifier.textColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              // height: 120,
              width: MediaQuery.of(context).size.width,
              color: notifier.containercoloreproper,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      const Image(
                          image: AssetImage('assets/Rectangle_2.png'),
                          height: 40),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10, left: 15, bottom: 10),
                        child: Text(
                          'Price Details'.tr,
                          style: TextStyle(
                              color: notifier.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Luggage weight".tr,style: TextStyle(fontSize: 14,color: notifier.textColor),),
                            Text("${parcelDetailApiModel!.parcelHistory![0].parcelWeight.toString()} Kg",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: notifier.textColor),),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Price per km".tr,style: TextStyle(fontSize: 14,color: notifier.textColor),),
                            Text("${parcelDetailApiModel!.parcelHistory![0].pricePerKm.toString()} ${searchbus}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: notifier.textColor),),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Distance of km".tr,style: TextStyle(fontSize: 14,color: notifier.textColor),),
                            Text("${parcelDetailApiModel!.parcelHistory![0].distance.toString()} Km",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: notifier.textColor),),
                          ],
                        ),
                        parcelDetailApiModel!.parcelHistory![0].wall_amt == "0" ? SizedBox() : SizedBox(height: 20),
                        parcelDetailApiModel!.parcelHistory![0].wall_amt == "0" ? SizedBox() : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Wallete".tr,style: TextStyle(fontSize: 14,color: Colors.green),),
                            Text(parcelDetailApiModel!.parcelHistory![0].wall_amt.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.green),),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.grey.withOpacity(0.4),),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("Total Price  ".tr,style: TextStyle(fontSize: 14,color: notifier.textColor),),
                                Text("(${parcelDetailApiModel!.parcelHistory![0].pricePerKm.toString()} ${searchbus}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: notifier.textColor),),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(" * ",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: notifier.textColor),),
                                ),
                                Text("${parcelDetailApiModel!.parcelHistory![0].distance.toString()} Km)",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: notifier.textColor),),
                              ],
                            ),
                            // Text("Total Price  (${widget.price_per_km} * ${widget.distance})",style: TextStyle(fontSize: 14),),
                            Text("$searchbus ${parcelDetailApiModel!.parcelHistory![0].price.toString()}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: notifier.textColor),),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
