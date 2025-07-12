import 'dart:convert';
import 'package:routekacustomernew/config/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../api_model/twilyo_api_model.dart';

class TwilioapiController extends GetxController implements GetxService {
  TwilioApiModel? twilioApiModel;

  Future twilioApi(
      {
        required String mobilenumber,
        context
      }) async {
    Map body = {
      "mobile": mobilenumber,
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };

    var response = await http.post(Uri.parse(config().baseUrl + config().twilioapi),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + Twailyo api + + + + + + $body');
    print('- - - - - Twailyo api - - - - - - ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == "true") {


        twilioApiModel = twilioApiModelFromJson(response.body);
        update();

        Fluttertoast.showToast(
          // msg: "${data["ResponseMsg"]}",
          msg: "Otp:- ${data["otp"]}",
        );
      } else {
        Fluttertoast.showToast(
          msg: "${data["ResponseMsg"]}",
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Somthing went wrong!.....",
      );
    }
  }
}