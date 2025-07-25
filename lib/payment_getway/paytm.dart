// // ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_final_fields, await_only_futures, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, unused_local_variable, prefer_collection_literals, unused_field, avoid_print, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
//
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:routekacustomernew/config/config.dart';
//
// class PayTmPayment extends StatefulWidget {
//   final String? uid;
//   final String? totalAmount;
//
//   const PayTmPayment({this.uid, this.totalAmount});
//
//   @override
//   State<PayTmPayment> createState() => _PayTmPaymentState();
// }
//
// class _PayTmPaymentState extends State<PayTmPayment> {
//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   late WebViewController _controller;
//   var progress;
//   String? accessToken;
//   String? payerID;
//   bool isLoading = true;
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (_scaffoldKey.currentState == null) {
//       return WillPopScope(
//         onWillPop: () async {
//           return Future(() => true);
//         },
//         child: Scaffold(
//           body: SafeArea(
//             child: Stack(
//               children: [
//                 WebView(
//                   initialUrl:
//                   "${config().baseUrl + "/paytm/index.php?amt=${widget.totalAmount}&uid=${widget.uid}"}",
//                   javascriptMode: JavascriptMode.unrestricted,
//                   navigationDelegate: (NavigationRequest request) async {
//                     final uri = Uri.parse(request.url);
//
//                     if (uri.queryParameters["status"] == null) {
//                       accessToken = uri.queryParameters["token"];
//                     } else {
//                       if (uri.queryParameters["status"] == "successful") {
//                         payerID = await uri.queryParameters["transaction_id"];
//                         Get.back(result: payerID);
//                       } else {
//                         Get.back();
//                         Fluttertoast.showToast(msg: "${uri.queryParameters["status"]}",timeInSecForIosWeb: 4);
//                       }
//                     }
//
//                     return NavigationDecision.navigate;
//                   },
//                   gestureNavigationEnabled: true,
//                   onWebViewCreated: (controller) {
//                     _controller = controller;
//                   },
//                   onPageFinished: (finish) {
//                     setState(() async {
//                       isLoading = false;
//                     });
//                   },
//                   onProgress: (val) {
//                     progress = val;
//                     setState(() {});
//                   },
//                 ),
//                 isLoading
//                     ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         child: CircularProgressIndicator(),
//                       ),
//                       SizedBox(height: Get.height * 0.02),
//                       SizedBox(
//                         width: Get.width * 0.80,
//                         child: Text(
//                           'Please don`t press back until the transaction is complete'
//                               .tr,
//                           maxLines: 2,
//                           textAlign: TextAlign.center,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w500,
//                               letterSpacing: 0.5),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//                     : Stack(),
//               ],
//             ),
//           ),
//         ),
//       );
//     } else {
//       return Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Get.back(),
//           ),
//           backgroundColor: Colors.black12,
//           elevation: 0.0,
//         ),
//         body: Center(
//           child: Container(
//             child: CircularProgressIndicator(),
//           ),
//         ),
//       );
//     }
//   }
// }



// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_final_fields, await_only_futures, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, unused_local_variable, prefer_collection_literals, unused_field, avoid_print, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:routekacustomernew/config/config.dart';

class PayTmPayment extends StatefulWidget {
  final String? uid;
  final String? totalAmount;

  const PayTmPayment({this.uid, this.totalAmount});

  @override
  State<PayTmPayment> createState() => _PayTmPaymentState();
}

class _PayTmPaymentState extends State<PayTmPayment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final WebViewController _controller;

  bool isLoading = true;
  int progress = 0;

  String? accessToken;
  String? payerID;

  @override
  void initState() {
    super.initState();

    final url = "${config().baseUrl}/paytm/index.php?amt=${widget.totalAmount}&uid=${widget.uid}";

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);

            if (uri.queryParameters["status"] == null) {
              accessToken = uri.queryParameters["token"];
            } else {
              if (uri.queryParameters["status"] == "successful") {
                payerID = uri.queryParameters["transaction_id"];
                Get.back(result: payerID);
              } else {
                Get.back();
                Fluttertoast.showToast(
                  msg: "${uri.queryParameters["status"]}",
                  timeInSecForIosWeb: 4,
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
            msg: "Please don`t press back until the transaction is complete".tr,
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
                        width: Get.width * 0.80,
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
