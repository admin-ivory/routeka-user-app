// // ignore_for_file: prefer_final_fields, unused_field, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, avoid_print, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:routekacustomernew/config/config.dart';
//
// class Flutterwave extends StatefulWidget {
//   final String? email;
//   final String? totalAmount;
//
//   const Flutterwave({this.email, this.totalAmount});
//
//   @override
//   State<Flutterwave> createState() => _FlutterwaveState();
// }
//
// class _FlutterwaveState extends State<Flutterwave> {
//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   late WebViewController _controller;
//   var progress;
//   String? accessToken;
//   String? payerID;
//   bool isLoading = true;
//
//   @override
//   Widget build(BuildContext context) {
//     if (_scaffoldKey.currentState == null) {
//       print("Flutterwave ++++++++++++++++++++++----${config().baseUrl + "/flutterwave/index.php?amt=${widget.totalAmount}&email=${widget.email}"}");
//       return WillPopScope (
//         onWillPop: () {
//           return Future(() => true);
//         },
//         child: Scaffold(
//           body: SafeArea(
//             child: Stack(
//               children: [
//                 WebView(
//                   initialUrl:
//                   "${config().baseUrl + "/flutterwave/index.php?amt=${widget.totalAmount}&email=${widget.email}"}",
//                   javascriptMode: JavascriptMode.unrestricted,
//                   navigationDelegate: (NavigationRequest request) async {
//                     final uri = Uri.parse(request.url);
//                     if (uri.queryParameters["status"] == null) {
//                       accessToken = uri.queryParameters["token"];
//                     } else {
//                       if (uri.queryParameters["status"] == "successful") {
//                         payerID = await uri.queryParameters["transaction_id"];
//                         Get.back(result: payerID);
//                       } else {
//
//                         Get.back();
//
//                         Fluttertoast.showToast(msg: "${uri.queryParameters["status"]}",timeInSecForIosWeb: 4);
//                       }
//                     }
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



import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:routekacustomernew/config/config.dart';

class Flutterwave extends StatefulWidget {
  final String? email;
  final String? totalAmount;

  const Flutterwave({this.email, this.totalAmount});

  @override
  State<Flutterwave> createState() => _FlutterwaveState();
}

class _FlutterwaveState extends State<Flutterwave> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final WebViewController _controller;

  bool isLoading = true;
  int progress = 0;

  String? accessToken;
  String? payerID;

  @override
  void initState() {
    super.initState();

    final url = "${config().baseUrl}/flutterwave/index.php?amt=${widget.totalAmount}&email=${widget.email}";

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
              if (progress == 100) {
                isLoading = false;
              }
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (isLoading) {
          Fluttertoast.showToast(msg: "Please wait until the transaction is complete");
          return Future.value(false);
        }
        return Future.value(true);
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: Get.width * 0.8,
                        child: Text(
                          'Please don`t press back until the transaction is complete'.tr,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
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
