import 'dart:convert';

import 'package:routekacustomernew/config/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import '../api_model/msg_api_model.dart';
import '../common_code/common_button.dart';

class MasgapiController extends GetxController implements GetxService {
  MsgApiModel? msgApiModel;

  Future msgApi(
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

    var response = await http.post(Uri.parse(config().baseUrl + config().msgapi),
        body: jsonEncode(body), headers: userHeader);

    print('+ + + + + + MSG OTP + + + + + $body');
    print('- - - - - - MSG OTP - - - - - ${response.body}');

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["Result"] == "true") {
        msgApiModel = msgApiModelFromJson(response.body);
        update();
        Fluttertoast.showToast(
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