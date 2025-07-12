



// ignore_for_file: prefer_final_fields, unused_field, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, avoid_print, prefer_const_constructors, avoid_unnecessary_containers, file_names
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:routekacustomernew/config/config.dart';

class MidTrans extends StatefulWidget {
  final String? email;
  final String? mobilenumber;
  final String? totalAmount;

  const MidTrans({this.email, this.totalAmount, this.mobilenumber});

  @override
  State<MidTrans> createState() => _MidTransState();
}

class _MidTransState extends State<MidTrans> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final WebViewController _controller;
  bool isLoading = true;
  int progress = 0;

  String? accessToken;
  String? payerID;

  @override
  void initState() {
    super.initState();

    final url = "${config().baseUrl}/Midtrans/index.php"
        "?name=test"
        "&email=${widget.email}"
        "&phone=${widget.mobilenumber}"
        "&amt=${widget.totalAmount}";

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);

            if (uri.queryParameters["transaction_status"] == null) {
              accessToken = uri.queryParameters["token"];
            } else {
              if (uri.queryParameters["status_code"] == "200") {
                payerID = uri.queryParameters["order_id"];
                Get.back(result: payerID);
              } else {
                Get.back();
                Fluttertoast.showToast(
                  msg: "${uri.queryParameters["status"]}",
                );
              }
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onProgress: (int newProgress) {
            setState(() {
              progress = newProgress;
              if (progress == 100) isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isLoading) {
          Fluttertoast.showToast(
            msg: "Please don't press back until the transaction is complete".tr,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (isLoading)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(value: progress / 100),
                      SizedBox(height: Get.height * 0.02),
                      SizedBox(
                        width: Get.width * 0.8,
                        child: Text(
                          'Please don`t press back until the transaction is complete'.tr,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
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
    );
  }
}
