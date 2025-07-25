import 'dart:convert';
import 'package:routekacustomernew/config/config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_model/sms_api_model.dart';
import 'package:http/http.dart' as http;



// String show_parcel = "";

class SmstypeApiController extends GetxController implements GetxService {

  SmaApiModel? smaApiModel;
  bool isLoading = true;
  smsApi(context) async {

    Map<String,String> userHeader = {"Content-type": "application/json", "Accept": "application/json"};
    var response = await http.get(Uri.parse(config().baseUrl + config().smstypeapi),headers: userHeader);

    print("++++++++++ sms type ++++++++++:-- ${response.body}");

    var data = jsonDecode(response.body);
    if(response.statusCode == 200){
      if(data["Result"] == "true"){
        smaApiModel = smaApiModelFromJson(response.body);
        isLoading = false;
        // show_parcel = data["show_parcel"].toString();

        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString("showparcel", jsonEncode(data["show_parcel"]));

        update();
      }
      else{
        Get.back();
        Fluttertoast.showToast(msg: "${data["Result"]}");
      }
    }
    else{
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went Wrong....!!!")));
    }
  }
}
