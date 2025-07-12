 




// ignore_for_file: deprecated_member_use, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:routekacustomernew/config/config.dart';

import 'paymentcard.dart';

class StripePaymentWeb extends StatefulWidget {
  final PaymentCardCreated paymentCard;

  const StripePaymentWeb({Key? key, required this.paymentCard})
      : super(key: key);

  @override
  State<StripePaymentWeb> createState() => _StripePaymentWebState();
}

class _StripePaymentWebState extends State<StripePaymentWeb> {
  late final WebViewController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PaymentCardCreated? payCard;
  int progress = 0;

  @override
  void initState() {
    super.initState();

    payCard = widget.paymentCard;

    final url = initialUrl;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.grey.shade200)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) => readJS(),
          onProgress: (val) {
            setState(() {
              progress = val;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  String get initialUrl =>
      '${config().baseUrl}stripe/index.php?name=${Uri.encodeComponent(payCard!.name.toString())}&email=${Uri.encodeComponent(payCard!.email.toString())}&cardno=${Uri.encodeComponent(payCard!.number.toString())}&cvc=${Uri.encodeComponent(payCard!.cvv.toString())}&amt=${Uri.encodeComponent(payCard!.amount.toString())}&mm=${Uri.encodeComponent(payCard!.month.toString())}&yyyy=${Uri.encodeComponent(payCard!.year.toString())}';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (progress < 100) {
          Fluttertoast.showToast(
            msg: 'Please don`t press back until the transaction is complete'.tr,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: Get.height * 0.02),
              SizedBox(
                width: Get.width * 0.80,
                child: Text(
                  'Please don`t press back until the transaction is complete'.tr,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5),
                ),
              ),
              SizedBox(height: Get.height * 0.01),
              SizedBox(
                height: 25,
                width: double.infinity,
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (progress < 100)
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 25,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> readJS() async {
    try {
      final jsResult =
      await _controller.runJavaScriptReturningResult('document.documentElement.innerText');
      // The returned result is dynamic, but it's JSON string wrapped in quotes, so we clean it up:

      String value = jsResult.toString();

      // Remove leading/trailing quotes if present
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }
      // Unescape common escaped quotes
      value = value.replaceAll(r'\"', '"').replaceAll(r"\'", "'");

      if (value.contains("Transaction_id")) {
        Map<String, dynamic> val;

        try {
          val = jsonDecode(value);
        } catch (_) {
          // fallback to custom parsing if JSON decode fails
          val = jsonStringToMap(value);
        }

        if (val['ResponseCode'] == "200" && val['Result'] == "true") {
          Get.back(result: val["Transaction_id"]);
          Fluttertoast.showToast(msg: val["ResponseMsg"], timeInSecForIosWeb: 4);
        } else {
          Fluttertoast.showToast(msg: val["ResponseMsg"], timeInSecForIosWeb: 4);
          Get.back();
        }
      }
    } catch (e) {
      // handle or ignore
    }
  }

  Map<String, dynamic> jsonStringToMap(String data) {
    final Map<String, dynamic> result = {};
    final List<String> pairs = data
        .replaceAll("{", "")
        .replaceAll("}", "")
        .replaceAll("\"", "")
        .replaceAll("'", "")
        .split(",");
    for (var pair in pairs) {
      final keyVal = pair.split(":");
      if (keyVal.length == 2) {
        result[keyVal[0].trim()] = keyVal[1].trim();
      }
    }
    return result;
  }
}
