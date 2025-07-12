import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API_MODEL/payment_getway_api_model.dart';
import '../All_Screen/bottom_navigation_bar_screen.dart';
import '../Common_Code/common_button.dart';
import '../Common_Code/homecontroller.dart';
import '../Payment_Getway/flutterwave.dart';
import '../Payment_Getway/inputformater.dart';
import '../Payment_Getway/paymentcard.dart';
import '../Payment_Getway/paypal.dart';
import '../Payment_Getway/paytm.dart';
import '../Payment_Getway/razorpay.dart';
import '../Payment_Getway/senangpay.dart';
import '../Payment_Getway/stripeweb.dart';
import '../api_model/book_parcel_model.dart';
import '../config/config.dart';
import '../config/light_and_dark.dart';
import '../payment_getway/mercadopogo.dart';
import '../payment_getway/midtranc.dart';

class BookParcelScreen extends StatefulWidget {
  final String from_add;
  final String to_add;
  final String trip_date;
  final String bus_id;
  final String from_city_id;
  final String to_city_id;
  final String Operater_id;
  final String parcel_weight;
  final String price;
  final String price_per_km;
  final String distance;
  final String to_point_id;
  final String from_point_id;
  final String wallete;
  const BookParcelScreen({super.key, required this.from_add, required this.to_add, required this.trip_date, required this.bus_id, required this.from_city_id, required this.to_city_id, required this.Operater_id, required this.parcel_weight, required this.price, required this.price_per_km, required this.distance, required this.to_point_id, required this.from_point_id, required this.wallete});

  @override
  State<BookParcelScreen> createState() => _BookParcelScreenState();
}

class _BookParcelScreenState extends State<BookParcelScreen> {

  // bool error = false;

  @override
  void initState() {
    print("from_add :- ${widget.from_add}");
    print("to_add :- ${widget.to_add}");
    print("trip_date :- ${widget.trip_date}");
    print("bus_id :- ${widget.bus_id}");
    print("from_city_id :- ${widget.from_city_id}");
    print("to_city_id :- ${widget.to_city_id}");
    print("Operater_id :- ${widget.Operater_id}");
    print("parcel_weight :- ${widget.parcel_weight}");
    print("price :- ${widget.price}");
    print("price_per_km :- ${widget.price_per_km}");
    print("distance :- ${widget.distance}");
    print("to_point_id :- ${widget.to_point_id}");
    print("from_point_id :- ${widget.from_point_id}");
    print("wallete :- ${widget.wallete}");

    total = double.parse(widget.price.toString());
    tempWallet = double.parse(widget.wallete);

    getlocledata();
    razorPayClass.initiateRazorPay(handlePaymentSuccess: handlePaymentSuccess, handlePaymentError: handlePaymentError, handleExternalWallet: handleExternalWallet);
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

      Payment_Getway();
      print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["id"]}');
      // print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${userData["id"]}');
    });
  }


  TextEditingController Sender_Name = TextEditingController();
  TextEditingController Sender_Mobile = TextEditingController();
  TextEditingController Receiver_Name = TextEditingController();
  TextEditingController Receiver_Mobile = TextEditingController();


  // Payment List

  late PaymentGetway from12;
  Future Payment_Getway() async {
    var response1 = await http.get(Uri.parse('${config().baseUrl}/api/paymentgateway.php'),);
    if (response1.statusCode == 200) {
      var jsonData = json.decode(response1.body);
      print(jsonData["paymentdata"]);
      setState(() {
        from12 = paymentGetwayFromJson(response1.body);
      });
    }
  }



  HomeController homeController = Get.put(HomeController());
  BookParcelApiModel? bookParcelApiModel;

  bool orederloader = false;
  Future Book_Parcel({required String uid,required String paymentId}) async {

    if(orederloader){
      return;
    }else{
      orederloader = true;
    }

    setState(() {
      booking_loader = true;
    });

    Map body = {
      "operator_id": widget.Operater_id,
      "bus_id": widget.bus_id,
      "trip_date": widget.trip_date,
      "sender_name": Sender_Name.text,
      "sender_mobile": Sender_Mobile.text,
      "receiver_name": Receiver_Name.text,
      "receiver_mobile": Receiver_Mobile.text,
      "from_city": widget.from_city_id,
      "to_city": widget.to_city_id,
      "parcel_weight": widget.parcel_weight,
      // "price": widget.price,
      "price": total.toString(),
      "uid": uid,
      "price_per_km": widget.price_per_km,
      "distance": widget.distance,
      "to_point_id": widget.to_point_id,
      "from_point_id": widget.from_point_id,
      "p_method_id" : paymentmethodId,
      "wall_amt" : useWallet.toString(),
      "transaction_id" : paymentId
    };

    print("---------- Book Parcel ---------- :- $body");

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/api/book_parcel.php'), body: jsonEncode(body),headers: {
        'Content-Type': 'application/json',
      });

      if(response.statusCode == 200){
        print("---------- Book Parcel ---------- :- ${response.body}");

        setState(() {
          bookParcelApiModel = bookParcelApiModelFromJson(response.body);
          showDialog<String>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => WillPopScope(
              onWillPop: () async {
                homeController.setselectpage(0);
                // Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  const Bottom_Navigation(),));
                Get.offAll(const Bottom_Navigation());
                return Future(() => false);
              },
              child: AlertDialog(
                backgroundColor: notifier.containercoloreproper,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                title: Column(
                  children: [
                    SizedBox(
                        height: 150,
                        width: 150,
                        child: Lottie.asset('assets/lottie/ticket-confirm.json',fit: BoxFit.cover)),
                    Text('Parcel Confirmed!'.tr,style: const TextStyle(fontWeight: FontWeight.bold,color: Color(0xff7D2AFF)),),
                    const SizedBox(height: 12,),
                    Text('Congratulation! your bus ticket is confirmed. For more details check the My Booking tab.'.tr,style: TextStyle(color: notifier.textColor,fontSize: 15,),textAlign: TextAlign.center,),
                    const SizedBox(height: 50,),
                    ElevatedButton(
                      onPressed: () {
                        homeController.setselectpage(0);
                        Get.offAll(Bottom_Navigation());
                        // Get.offAll(Bottom_Navigation());
                        // homeController.setselectpage(5);
                      },
                      style: ButtonStyle(shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),backgroundColor: const MaterialStatePropertyAll(Color(0xff7D2AFF))),
                      child: Text('Confirmed'.tr,style: const TextStyle(color: Colors.white)),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Get.offAll(Bottom_Navigation());
                    //   },
                    //   style: ButtonStyle(elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),backgroundColor: const MaterialStatePropertyAll(Colors.white)),
                    //   child:  Text('Back to Home'.tr,style: const TextStyle(color: Color(0xff7D2AFF))),
                    // ),
                  ],
                ),
              ),
            ),
          );
          setState(() {
            booking_loader = false;
          });
        });

      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }


  int payment = -1;
  String selectedOption = '';
  String selectBoring = "";
  String paymentmethodId = '5';

  // Razorpay Code
  RazorPayClass  razorPayClass = RazorPayClass();


  // Razorpay? _razorpay;

  void handlePaymentSuccess(PaymentSuccessResponse response){
    Book_Parcel(uid: userData["id"].toString(),paymentId: "${response.paymentId}");
    // Fluttertoast.showToast(msg: 'SUCCESS PAYMENT : ${response.paymentId}',timeInSecForIosWeb: 4);
  }
  void handlePaymentError(PaymentFailureResponse response){
    Fluttertoast.showToast(msg: 'ERROR HERE: ${response.code} - ${response.message}',timeInSecForIosWeb: 4);
  }
  void handleExternalWallet(ExternalWalletResponse response){
    Fluttertoast.showToast(msg: 'EXTERNAL_WALLET IS: ${response.walletName}',timeInSecForIosWeb: 4);
  }

  bool light = false;


  double total = 0.00;
  double tempWallet = 0.00;
  double useWallet = 0.00;

  bool booking_loader = false;
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  bool hasSenderNameError = false;

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: notifier.containercoloreproper,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Amount :'.tr,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: notifier.textColor,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '$searchbus ${widget.price}',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: notifier.theamcolorelight),
                              ),
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     Text('(Exclusive of Taxes)'.tr,style: TextStyle(fontSize: 10, color: notifier.textColor),),
                          //   ],
                          // ),
                          const SizedBox(height: 8,)
                        ],
                      ),
                      const Spacer(),
                      const Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: CommonButton(containcolore: notifier.theamcolorelight, txt1: 'PROCEED'.tr, context: context,onPressed1: () {

                    if(_formKey1.currentState!.validate()){
                        showModalBottomSheet(
                          isDismissible: false,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                          ),
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                                builder: (context, setState)  {
                                  return ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                                    child: Scaffold(
                                      backgroundColor: Colors.red,
                                      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                                      floatingActionButton: Padding(
                                        padding:const EdgeInsets.only(bottom: 10,left: 10,right: 10),
                                        child: Container(
                                            height: 42,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              color: notifier.theamcolorelight,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: ElevatedButton(
                                              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color?>(notifier.theamcolorelight),shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))))),
                                              onPressed: () {


                                                if(total == 0){
                                                  Book_Parcel(uid: userData["id"].toString(),paymentId: "0");
                                                  Get.back();
                                                  // Fluttertoast.showToast(msg: 'Payment Wallets',timeInSecForIosWeb: 4);
                                                }else{
                                                  if(from12.paymentdata[payment].title == "Razorpay"){
                                                    razorPayClass.openCheckout(key: from12.paymentdata[0].attributes, amount: total.toString(), number: '${userData['mobile']}', name: '${userData['email']}');
                                                    Get.back();
                                                  }
                                                  else if(from12.paymentdata[payment].title == "Paypal"){
                                                    List ids = from12.paymentdata[1].attributes.toString().split(",");
                                                    print('++++++++++ids:------$ids');
                                                    paypalPayment(
                                                      context: context,
                                                      function: (e){
                                                        Book_Parcel(uid: userData["id"].toString(),paymentId: "$e");
                                                      },
                                                      amt: total.toString(),
                                                      clientId: ids[0],
                                                      secretKey: ids[1],
                                                    );
                                                  }
                                                  else if(from12.paymentdata[payment].title == "Stripe"){
                                                    Get.back();
                                                    stripePayment();
                                                  }
                                                  else if(from12.paymentdata[payment].title == "FlutterWave"){
                                                    Get.to(() => Flutterwave(
                                                        totalAmount: total.toString(),
                                                        email: userData['email']
                                                    ))!
                                                        .then((otid) {
                                                      if (otid != null) {
                                                        Book_Parcel(uid: userData["id"].toString(),paymentId: "$otid");
                                                        // Book_Ticket( uid: widget.uid, bus_id: widget.bus_id,pick_id: widget.pick_id, dropId: widget.dropId, ticketPrice: widget.ticketPrice,trip_date: widget.trip_date,paymentId: "$otid",boardingCity: widget.boardingCity,dropCity: widget.dropCity,busPicktime: widget.busPicktime,busDroptime: widget.busDroptime,Difference_pick_drop: widget.differencePickDrop);
                                                        Fluttertoast.showToast(msg: 'Payment Successfully',timeInSecForIosWeb: 4);
                                                      } else {
                                                        Get.back();
                                                      }
                                                    });
                                                  }
                                                  else if(from12.paymentdata[payment].title == "Paytm"){
                                                    Get.to(() => PayTmPayment(
                                                        totalAmount: total.toString(),
                                                        uid: userData['id']
                                                    ))!
                                                        .then((otid) {
                                                      if (otid != null) {
                                                        Book_Parcel(uid: userData["id"].toString(),paymentId: "$otid");
                                                        // Book_Ticket( uid: widget.uid, bus_id: widget.bus_id,pick_id: widget.pick_id, dropId: widget.dropId, ticketPrice: widget.ticketPrice,trip_date: widget.trip_date,paymentId: "$otid",boardingCity: widget.boardingCity,dropCity: widget.dropCity,busPicktime: widget.busPicktime,busDroptime: widget.busDroptime,Difference_pick_drop: widget.differencePickDrop);
                                                        Fluttertoast.showToast(msg: 'Payment Successfully',timeInSecForIosWeb: 4);
                                                      } else {
                                                        Get.back();
                                                      }
                                                    });
                                                  }
                                                  else if(from12.paymentdata[payment].title == "SenangPay"){
                                                    Get.to(SenangPay(
                                                        email: userData['email'],
                                                        totalAmount: total.toString(),
                                                        name: userData['name'],
                                                        phon: userData['mobile']))!
                                                        .then((otid) {
                                                      if (otid != null) {
                                                        Book_Parcel(uid: userData["id"].toString(),paymentId: "$otid");
                                                        // Book_Ticket( uid: widget.uid, bus_id: widget.bus_id,pick_id: widget.pick_id, dropId: widget.dropId, ticketPrice: widget.ticketPrice,trip_date: widget.trip_date,paymentId: "$otid",boardingCity: widget.boardingCity,dropCity: widget.dropCity,busPicktime: widget.busPicktime,busDroptime: widget.busDroptime,Difference_pick_drop: widget.differencePickDrop);
                                                      } else {
                                                        Get.back();
                                                      }
                                                    });
                                                  }
                                                  else if(from12.paymentdata[payment].title == "Midtrans"){
                                                    Get.to(() => MidTrans(
                                                      totalAmount: total.toString(),
                                                      email: userData['email'],
                                                      mobilenumber: userData['mobile'],
                                                    ))!
                                                        .then((otid) {
                                                      if (otid != null) {
                                                        Book_Parcel(uid: userData["id"].toString(),paymentId: "$otid");
                                                        // Book_Ticket( uid: widget.uid, bus_id: widget.bus_id,pick_id: widget.pick_id, dropId: widget.dropId, ticketPrice: widget.ticketPrice,trip_date: widget.trip_date,paymentId: "$otid",boardingCity: widget.boardingCity,dropCity: widget.dropCity,busPicktime: widget.busPicktime,busDroptime: widget.busDroptime,Difference_pick_drop: widget.differencePickDrop);
                                                      } else {
                                                        Get.back();
                                                      }
                                                    });
                                                  }
                                                  else if(from12.paymentdata[payment].title == "MercadoPago"){
                                                    Get.to(() => merpago(
                                                      totalAmount: total.toString(),
                                                    ))!
                                                        .then((otid) {
                                                      if (otid != null) {
                                                        // WalletUpdateApi(userData['id']);
                                                        Book_Parcel(uid: userData["id"].toString(),paymentId: "$otid");
                                                        // Book_Ticket( uid: widget.uid, bus_id: widget.bus_id,pick_id: widget.pick_id, dropId: widget.dropId, ticketPrice: widget.ticketPrice,trip_date: widget.trip_date,paymentId: "$otid",boardingCity: widget.boardingCity,dropCity: widget.dropCity,busPicktime: widget.busPicktime,busDroptime: widget.busDroptime,Difference_pick_drop: widget.differencePickDrop);
                                                        Fluttertoast.showToast(msg: 'Payment Successfully',timeInSecForIosWeb: 4);
                                                      } else {
                                                        Get.back();
                                                      }
                                                    });
                                                  }
                                                  else{
                                                    Get.back();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Not Valid'.tr),behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                                                    );
                                                  }
                                                }


                                              },
                                              child: Center(
                                                child: RichText(text:  TextSpan(
                                                    children: [
                                                      TextSpan(text: 'CONTINUE'.tr,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                                                    ]
                                                )),
                                              ),
                                            )
                                        ),
                                      ),
                                      body: Container(
                                        // height: 450,
                                        decoration:  BoxDecoration(
                                            color: notifier.containercoloreproper,
                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10,right: 10,bottom: 50),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget> [

                                              const SizedBox(height: 13,),
                                              Text('Payment Gateway Method'.tr,style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: notifier.textColor)),
                                              const SizedBox(height: 4,),
                                              widget.wallete == "0" ? SizedBox() : ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Image(image: const AssetImage('assets/credit-card.png'),height: 25,width: 25,color: notifier.textColor),
                                                title: Transform.translate(offset: const Offset(-15, 0),child:  Text('Pay from Wallet (${tempWallet})'.tr,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: notifier.textColor))),
                                                trailing: Transform.scale(
                                                  scale: 0.7,
                                                  child: CupertinoSwitch(
                                                    value: light,
                                                    activeColor: notifier.theamcolorelight,
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        light = value;
                                                      });



                                                      if (value == true) {
                                                        if (double.parse(widget.wallete.toString()) < double.parse(total.toString())) {
                                                          tempWallet = double.parse(total.toString()) - double.parse(widget.wallete.toString());
                                                          useWallet = double.parse(widget.wallete.toString());
                                                          total = (double.parse(total.toString()) - double.parse(widget.wallete.toString()));
                                                          tempWallet = 0;
                                                          setState(() {});
                                                        } else {
                                                          tempWallet = double.parse(widget.wallete.toString()) - double.parse(total.toString());
                                                          useWallet = double.parse(widget.wallete.toString()) - tempWallet;
                                                          total = 0;
                                                          setState(() {});
                                                          print("USE OF WALLET $total > $useWallet");
                                                        }
                                                      } else {
                                                        tempWallet = 0;
                                                        tempWallet = double.parse(widget.wallete.toString());
                                                        print("USE End WALLET $total > $useWallet");
                                                        total = total + useWallet;
                                                        useWallet = 0;
                                                        setState(() {});
                                                      }




                                                      //////////////////////////////////////////////////////////////////////////////////////

                                                      // print("wallet main : ${widget.wallet}");
                                                      // print("totalPayment : $totalPayment");
                                                      // print("walletValue : $walletValue");
                                                      // print("totalAmount : $totalAmount");
                                                      //
                                                      // if(value) {
                                                      //   if (totalPayment > walletMain) {
                                                      //     print("1");
                                                      //     walletValue = walletMain;
                                                      //     totalPayment -= walletValue;
                                                      //     walletMain = 0 ;
                                                      //   }else {
                                                      //     print("2");
                                                      //     walletValue = totalPayment;
                                                      //     totalPayment -= totalPayment;
                                                      //
                                                      //     double good = double.parse(widget.wallet);
                                                      //     print(walletValue);
                                                      //     print(double.parse(widget.wallet));
                                                      //     walletMain = (good - walletValue);
                                                      //   }
                                                      // }else{
                                                      //   print("3");
                                                      //   // isOnlyWallet = false;
                                                      //   walletValue = 0;
                                                      //   walletMain = double.parse(widget.wallet);
                                                      //   totalPayment = widget.bottom + (widget.bottom * int.parse(taxamount) / 100);
                                                      //   coupon = 0;
                                                      // }
                                                      //
                                                      //
                                                      // print("-------------------------------------------------");
                                                      // print("wallet main : $walletMain");
                                                      // print("totalPayment : $totalPayment");
                                                      // print("walletValue : $walletValue");
                                                      // print("totalAmount : $totalAmount");

                                                    },
                                                  ),
                                                ),
                                              ),
                                              widget.wallete == "0" ? SizedBox() : const SizedBox(height: 4),
                                              Expanded(
                                                child: ListView.separated(
                                                    separatorBuilder: (context, index) {
                                                      return const SizedBox(width: 0,);
                                                    },
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.vertical,
                                                    physics: const BouncingScrollPhysics(),
                                                    itemCount: from12.paymentdata.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      return InkWell(
                                                        onTap: () {
                                                          setState(() {

                                                            if(total == 0){

                                                            }else{
                                                              payment = index;
                                                              paymentmethodId = from12.paymentdata[index].id;
                                                              print(paymentmethodId);
                                                            }


                                                          });
                                                        },
                                                        child: Container(
                                                          height: 90,
                                                          margin: const EdgeInsets.only(left: 10,right: 10,top: 6,bottom: 6),
                                                          padding: const EdgeInsets.all(5),
                                                          decoration: BoxDecoration(
                                                            // color: Colors.red,
                                                            border: Border.all(color: payment == index ? notifier.theamcolorelight : Colors.grey.withOpacity(0.4)),
                                                            borderRadius: BorderRadius.circular(15),
                                                          ),
                                                          child: Center(
                                                            child: ListTile(
                                                              leading: Transform.translate(offset: const Offset(-5, 0),child: Container(
                                                                height: 100,
                                                                width: 60,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(15),
                                                                    border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                                                    image: DecorationImage(image: NetworkImage('${config().baseUrl}/${from12.paymentdata[index].img}'))
                                                                ),
                                                              ),),
                                                              title: Padding(
                                                                padding: const EdgeInsets.only(bottom: 4),
                                                                child: Text(from12.paymentdata[index].title,style:  TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: notifier.textColor),maxLines: 2,),
                                                              ),
                                                              subtitle: Padding(
                                                                padding: const EdgeInsets.only(bottom: 4),
                                                                child: Text(from12.paymentdata[index].subtitle,style:  TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: notifier.textColor),maxLines: 2,),
                                                              ),
                                                              trailing: Radio(
                                                                value: payment == index ? true : false,
                                                                fillColor:  MaterialStatePropertyAll<Color?>(notifier.theamcolorelight),
                                                                groupValue: true,
                                                                onChanged: (value) {
                                                                  print(value);
                                                                  setState(() {
                                                                    selectedOption = value.toString();
                                                                    selectBoring = from12.paymentdata[index].img;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            );
                          },
                        );
                        print("DONE DONE DONE");
                    }

                  }),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: notifier.backgroundgray,
      appBar: AppBar(
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
              Text(widget.trip_date.toString().split(" ").first, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey1,
        child: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  SizedBox(height: 20),
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
                                'Luggage Details'.tr,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sender Name'.tr, style: TextStyle(fontSize: 14,color: notifier.textColor),maxLines: 1),
                                  const SizedBox(height: 6),
                                  CommonTextfiled2(txt: 'Enter Your Sender Name'.tr,controller: Sender_Name,context: context,validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },),
                                  // TextFormField(
                                  //   controller: Sender_Name,
                                  //   style: TextStyle(color: notifier.textColor),
                                  //   onChanged: (value) {
                                  //     // if(FullnameController.text.isNotEmpty){
                                  //     //   setState(() {
                                  //     //     error = false;
                                  //     //   });
                                  //     // }else{
                                  //     //   setState(() {
                                  //     //     error = true;
                                  //     //   });
                                  //     // }
                                  //   },
                                  //   decoration: InputDecoration(
                                  //     errorStyle: const TextStyle(fontSize: 0.1),
                                  //     isDense: true,
                                  //     contentPadding: const EdgeInsets.symmetric(vertical: 13,horizontal: 10 ),
                                  //     border: OutlineInputBorder(
                                  //         borderRadius: BorderRadius.circular(10),
                                  //         borderSide:
                                  //         const BorderSide(color: Colors.pink)),
                                  //     focusedBorder:  OutlineInputBorder(
                                  //         borderRadius:
                                  //         const BorderRadius.all(Radius.circular(10)),
                                  //         borderSide:
                                  //         BorderSide(color: notifier.theamcolorelight)),
                                  //     enabledBorder: OutlineInputBorder(
                                  //         borderRadius: BorderRadius.circular(10),
                                  //         borderSide: BorderSide(
                                  //             color:  Colors.grey.withOpacity(0.4))),
                                  //     hintText: 'Enter Your Sender Name'.tr,
                                  //     hintStyle: const TextStyle(
                                  //         fontSize: 13, color: Colors.grey),
                                  //   ),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sender Contact Details'.tr, style: TextStyle(fontSize: 14, color: notifier.textColor), maxLines: 1),
                                  const SizedBox(height: 6),
                                  CommonTextfiled2(txt: 'Enter Sender Mobile Number'.tr,controller: Sender_Mobile,context: context,validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;

                                  },),
                                  // TextFormField(
                                  //   style: TextStyle(color: notifier.textColor),
                                  //   keyboardType: TextInputType.number,
                                  //   controller: Sender_Mobile,
                                  //   onChanged: (value) {
                                  //   },
                                  //   decoration: InputDecoration(
                                  //       errorStyle: const TextStyle(fontSize: 0.1),
                                  //       isDense: true,
                                  //       contentPadding: const EdgeInsets.symmetric(vertical: 13,horizontal: 10 ),
                                  //       border: OutlineInputBorder(
                                  //           borderRadius: BorderRadius.circular(10),
                                  //           borderSide: const BorderSide(
                                  //               color: Colors.pink)),
                                  //       focusedBorder:  OutlineInputBorder(
                                  //           borderRadius: const BorderRadius.all(
                                  //               Radius.circular(10)),
                                  //           borderSide: BorderSide(
                                  //               color: notifier.theamcolorelight)),
                                  //       enabledBorder: OutlineInputBorder(
                                  //           borderRadius: BorderRadius.circular(10),
                                  //           borderSide: BorderSide(
                                  //               color: Colors.grey.withOpacity(0.4))),
                                  //       hintText: 'Enter Sender Mobile Number'.tr,
                                  //       hintStyle: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Receiver Name'.tr, style: TextStyle(fontSize: 14, color: notifier.textColor), maxLines: 1),
                                  const SizedBox(height: 6),
                                  CommonTextfiled2(txt: 'Enter Receiver Name'.tr,controller: Receiver_Name,context: context,validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },),
                                  // TextFormField(
                                  //   style: TextStyle(color: notifier.textColor),
                                  //   controller: Receiver_Name,
                                  //   onChanged: (value) {
                                  //   },
                                  //   decoration: InputDecoration(
                                  //       errorStyle: const TextStyle(fontSize: 0.1),
                                  //       isDense: true,
                                  //       contentPadding: const EdgeInsets.symmetric(vertical: 13,horizontal: 10 ),
                                  //       border: OutlineInputBorder(
                                  //           borderRadius: BorderRadius.circular(10),
                                  //           borderSide: const BorderSide(
                                  //               color: Colors.pink)),
                                  //       focusedBorder:  OutlineInputBorder(
                                  //           borderRadius: const BorderRadius.all(
                                  //               Radius.circular(10)),
                                  //           borderSide: BorderSide(
                                  //               color: notifier.theamcolorelight)),
                                  //       enabledBorder: OutlineInputBorder(
                                  //           borderRadius: BorderRadius.circular(10),
                                  //           borderSide: BorderSide(
                                  //               color: Colors.grey.withOpacity(0.4))),
                                  //       hintText: 'Enter Receiver Name'.tr,
                                  //       hintStyle: const TextStyle(
                                  //           fontSize: 13, color: Colors.grey)),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Receiver Contact Details'.tr, style: TextStyle(fontSize: 14, color: notifier.textColor), maxLines: 1),
                                  const SizedBox(height: 6),
                                  CommonTextfiled2(txt: 'Enter Receiver Mobile Number'.tr,controller: Receiver_Mobile,context: context,validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },),
                                  // TextFormField(
                                  //   style: TextStyle(color: notifier.textColor),
                                  //   keyboardType: TextInputType.number,
                                  //   controller: Receiver_Mobile,
                                  //   onChanged: (value) {
                                  //   },
                                  //   decoration: InputDecoration(
                                  //       errorStyle: const TextStyle(fontSize: 0.1),
                                  //       isDense: true,
                                  //       contentPadding: const EdgeInsets.symmetric(vertical: 13,horizontal: 10 ),
                                  //       border: OutlineInputBorder(
                                  //           borderRadius: BorderRadius.circular(10),
                                  //           borderSide: const BorderSide(
                                  //               color: Colors.pink)),
                                  //       focusedBorder:  OutlineInputBorder(
                                  //           borderRadius: const BorderRadius.all(
                                  //               Radius.circular(10)),
                                  //           borderSide: BorderSide(
                                  //               color: notifier.theamcolorelight)),
                                  //       enabledBorder: OutlineInputBorder(
                                  //           borderRadius: BorderRadius.circular(10),
                                  //           borderSide: BorderSide(
                                  //               color: Colors.grey.withOpacity(0.4))),
                                  //       hintText: 'Enter Receiver Mobile Number'.tr,
                                  //       hintStyle: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  // ),
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
                  SizedBox(height: 20),
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
                                'Details'.tr,
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
                                  Text("${widget.parcel_weight} Kg",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: notifier.textColor),),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Price per km".tr,style: TextStyle(fontSize: 14,color: notifier.textColor),),
                                  Text("${widget.price_per_km} $searchbus",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: notifier.textColor),),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Distance of km".tr,style: TextStyle(fontSize: 14,color: notifier.textColor),),
                                  Text("${widget.distance} Km",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: notifier.textColor),),
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
                                      Text("(${widget.price_per_km} $searchbus",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: notifier.textColor),),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text(" * ",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: notifier.textColor),),
                                      ),
                                      Text("${widget.distance} Km)",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: notifier.textColor),),
                                    ],
                                  ),
                                  // Text("Total Price  (${widget.price_per_km} * ${widget.distance})",style: TextStyle(fontSize: 14),),
                                  Text("$searchbus ${widget.price}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: notifier.textColor),),
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
                ],
              ),
              booking_loader == true ? CircularProgressIndicator(color: theamcolore,) : SizedBox()
            ],
          ),
        ),
      ),
    );
  }





  //Strip code


  final _formKey = GlobalKey<FormState>();
  var numberController = TextEditingController();
  final _paymentCard = PaymentCardCreated();
  var _autoValidateMode = AutovalidateMode.disabled;

  final _card = PaymentCardCreated();


  stripePayment() {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: notifier.background,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Ink(
                    child: Column(
                      children: [
                        SizedBox(height: Get.height / 45),
                        Center(
                          child: Container(
                            height: Get.height / 85,
                            width: Get.width / 5,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                borderRadius: const BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: Get.height * 0.03),
                              Text("Add Your payment information".tr,
                                  style:  TextStyle(
                                      color: notifier.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5)),
                              SizedBox(height: Get.height * 0.02),
                              Form(
                                key: _formKey,
                                autovalidateMode: _autoValidateMode,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      style:  TextStyle(color: notifier.textColor),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(19),
                                        CardNumberInputFormatter()
                                      ],
                                      controller: numberController,
                                      onSaved: (String? value) {
                                        _paymentCard.number =
                                            CardUtils.getCleanedNumber(value!);

                                        CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(
                                            _paymentCard.number.toString());
                                        setState(() {
                                          _card.name = cardType.toString();
                                          _paymentCard.type = cardType;
                                        });
                                      },
                                      onChanged: (val) {
                                        CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(val);
                                        setState(() {
                                          _card.name = cardType.toString();
                                          _paymentCard.type = cardType;
                                        });
                                      },
                                      validator: CardUtils.validateCardNum,
                                      decoration: InputDecoration(
                                        prefixIcon: SizedBox(
                                          height: 10,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 6,
                                            ),
                                            child: CardUtils.getCardIcon(_paymentCard.type,),
                                          ),
                                        ),
                                        focusedErrorBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.4),
                                          ),
                                        ),
                                        errorBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.4),
                                          ),
                                        ),
                                        enabledBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.4),
                                          ),
                                        ),
                                        focusedBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.4),
                                          ),
                                        ),
                                        hintText:
                                        "What number is written on card?".tr,
                                        hintStyle: const TextStyle(color: Colors.grey),
                                        labelStyle: const TextStyle(color: Colors.grey),
                                        labelText: "Number".tr,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Flexible(
                                          flex: 4,
                                          child: TextFormField(
                                            style:  TextStyle(color: notifier.textColor),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(4),
                                            ],
                                            decoration: InputDecoration(
                                                prefixIcon: const SizedBox(
                                                  height: 10,
                                                  child: Padding(
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 14),
                                                    child: Icon(Icons.credit_card,color: Color(0xff7D2AFF)),
                                                  ),
                                                ),
                                                focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.withOpacity(0.4),
                                                  ),
                                                ),
                                                errorBorder:  OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.withOpacity(0.4),
                                                  ),
                                                ),
                                                enabledBorder:  OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.withOpacity(0.4),
                                                  ),
                                                ),
                                                focusedBorder:  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                        Colors.grey.withOpacity(0.4))),
                                                hintText: "Number behind the card".tr,
                                                hintStyle:
                                                const TextStyle(color: Colors.grey),
                                                labelStyle:
                                                const TextStyle(color: Colors.grey),
                                                labelText: 'CVV'),
                                            validator: CardUtils.validateCVV,
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) {
                                              _paymentCard.cvv = int.parse(value!);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: Get.width * 0.03),
                                        Flexible(
                                          flex: 4,
                                          child: TextFormField(
                                            style:  TextStyle(color: notifier.textColor),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(4),
                                              CardMonthInputFormatter()
                                            ],
                                            decoration: InputDecoration(
                                              prefixIcon: const SizedBox(
                                                height: 10,
                                                child: Padding(
                                                  padding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14),
                                                  child: Icon(Icons.calendar_month,color: Color(0xff7D2AFF)),
                                                ),
                                              ),
                                              errorBorder:  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey.withOpacity(0.4),
                                                ),
                                              ),
                                              focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey.withOpacity(0.4),
                                                ),
                                              ),
                                              enabledBorder:  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey.withOpacity(0.4),
                                                ),
                                              ),
                                              focusedBorder:  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey.withOpacity(0.4),
                                                ),
                                              ),
                                              hintText: 'MM/YY',
                                              hintStyle:  const TextStyle(color: Colors.grey),
                                              labelStyle: const TextStyle(color: Colors.grey),
                                              labelText: "Expiry Date".tr,
                                            ),
                                            validator: CardUtils.validateDate,
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) {
                                              List<int> expiryDate =
                                              CardUtils.getExpiryDate(value!);
                                              _paymentCard.month = expiryDate[0];
                                              _paymentCard.year = expiryDate[1];
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: Get.height * 0.055),
                                    Container(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: Get.width,
                                        child: CupertinoButton(
                                          onPressed: () {
                                            _validateInputs();
                                          },
                                          color: const Color(0xff7D2AFF),
                                          child: Text(
                                            "Pay $searchbus${widget.price}",
                                            style:  const TextStyle(fontSize: 17.0,color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: Get.height * 0.065),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.always;
      });

      Fluttertoast.showToast(msg: "Please fix the errors in red before submitting.".tr,timeInSecForIosWeb: 4);
    } else {
      var username = userData["name"] ?? "";

      var email = userData["email"] ?? "";
      _paymentCard.name = username;
      _paymentCard.email = email;
      _paymentCard.amount = total.toString();
      form.save();

      Get.to(() => StripePaymentWeb(paymentCard: _paymentCard))!.then((otid) {
        Get.back();
        if (otid != null) {
          Book_Parcel(uid: userData["id"].toString(),paymentId: "$otid");
          // Book_Ticket( uid: widget.uid, bus_id: widget.bus_id,pick_id: widget.pick_id, dropId: widget.dropId, ticketPrice: widget.ticketPrice,trip_date: widget.trip_date,paymentId: "$otid",boardingCity: widget.boardingCity,dropCity: widget.dropCity,busPicktime: widget.busPicktime,busDroptime: widget.busDroptime,Difference_pick_drop: widget.differencePickDrop);
        }
      });
      Fluttertoast.showToast(msg: "Payment card is valid".tr,timeInSecForIosWeb: 4);
    }
  }

}
