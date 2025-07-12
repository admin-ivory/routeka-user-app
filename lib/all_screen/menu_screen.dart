// ignore_for_file: unused_local_variable, depend_on_referenced_packages, unnecessary_import, camel_case_types, non_constant_identifier_names, prefer_collection_literals, avoid_function_literals_in_foreach_calls, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../api_model/oprator_api_model.dart';
import '../config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import '../config/light_and_dark.dart';

 dynamic height;
 dynamic width;

class Menu_Screen extends StatefulWidget {
  const Menu_Screen({super.key});

  @override
  State<Menu_Screen> createState() => _Menu_ScreenState();
}

class _Menu_ScreenState extends State<Menu_Screen> {

  //  GET API CALLING

  Operator? from1;

  Future OperatorApi() async {
    var response1 = await http.get(Uri.parse('${config().baseUrl}/api/operatorlist.php'),);
    if (response1.statusCode == 200) {
      var jsonData = json.decode(response1.body);
      setState(() async {
        from1 = operatorFromJson(response1.body);
        isloading = false;

        print("+++++++++++++++++********** ${from1?.operatorlist[0].lats}");
        final Uint8List markIcon = await getImages("assets/Pin.png", 80);

        setState(() {
        });

        markers.add(Marker(
          // add first marker
          markerId: MarkerId("0".toString()),
          position: LatLng(
            double.parse(from1?.operatorlist[0].lats ?? "0"),
            double.parse(from1?.operatorlist[0].longs ?? "0"),
          ),
          icon: BitmapDescriptor.fromBytes(markIcon), // position of marker
          onTap: () {
          },
        ));

        getDirections(lat1: PointLatLng(startLocation.latitude, startLocation.longitude),lat2: PointLatLng(double.parse(from1?.operatorlist[0].lats ?? "0"), double.parse(from1?.operatorlist[0].longs ?? "")));

        List<LatLng> polylineCoordinates = [];
        addPolyLine(polylineCoordinates);

      });
    }
  }

  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {

    _getCurrentLocation().then((value) {
      getUserCurrentLocation().then((value) async {
        startLocation = LatLng(value.latitude, value.longitude);
        setState(() {
        });
        OperatorApi();
        final Uint8List markIcon = await getImages("assets/CurrentPin.png", 80);
        markers.add(Marker(

          markerId: MarkerId(value.toString()),
          position: LatLng(
            value.latitude,
            value.longitude,
          ),
          icon: BitmapDescriptor.fromBytes(markIcon), // position of marker
          onTap: () {
          },
        ));
        setState(() {
        });
      });
    },);


    super.initState();
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  PageController pageController = PageController();
  late GoogleMapController mapController;

  PolylinePoints polylinePoints = PolylinePoints();


  Set<Marker> markers = Set(); // markers for google map
  Map<PolylineId, Polyline> polylines = {}; // polylines to show direction

  LatLng startLocation = const LatLng(21.1702, 72.8311);
  LatLng endLocation = const LatLng(22.2442, 68.9685);



  getDirections({required PointLatLng lat1,required PointLatLng lat2}) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: config().mapkey,
      request: PolylineRequest(
        origin: lat1,
        destination: lat2,
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else{
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  bool isloading = true;






  Position? _currentPosition;
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get the current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        // CameraPosition kGoogle = const CameraPosition(
        //   target: LatLng(21.1702, 72.8311),
        //   zoom: 5,
        // );
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return isloading ? Center(child: CircularProgressIndicator(color: notifier.theamcolorelight),) : Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: Get.size.height,
                  child: GoogleMap(
                    polylines: Set<Polyline>.of(polylines.values),
                    // initialCameraPosition: CameraPosition(target: target),
                    initialCameraPosition: CameraPosition(
                        target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude
                        ),zoom: 5),
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                      Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                      ),
                    ].toSet(),
                    mapType: MapType.normal,
                    markers: Set<Marker>.of(markers),
                    myLocationEnabled: false,
                    compassEnabled: true,
                    zoomGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    onMapCreated: (controller) {
                      setState(() {
                        polylines = {};
                        mapController = controller;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              margin: const EdgeInsets.all(10),
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (value) {
                  print(value);
                  print(markers);

                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          double.parse(from1?.operatorlist[value].lats ?? "0"),
                          double.parse(from1?.operatorlist[value].longs ?? ""),
                        ),
                        zoom: 12,
                      ),
                    ),
                  );
                  getmarkers(value);
                  getDirections(lat1: PointLatLng(startLocation.latitude, startLocation.longitude),lat2: PointLatLng(double.parse(from1?.operatorlist[value].lats ?? "0"), double.parse(from1?.operatorlist[value].longs ?? "")));

                  markers.clear();
                  getMarker();

                  PolylineId id = const PolylineId("poly");
                  polylines.remove(id);

                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          double.parse(from1?.operatorlist[value].lats ?? "0"),
                          double.parse(from1?.operatorlist[value].longs ?? ""),
                        ),
                        zoom: 12,
                      ),
                    ),
                  )
                      .then((val) {
                    setState(() {});
                  });

                },
                scrollDirection: Axis.horizontal,
                itemCount: from1?.operatorlist.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 2,right: 2),
                      height: 80,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: notifier.containercoloreproper,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Image(image: NetworkImage('${config().baseUrl}/${from1?.operatorlist[index].opImg}'),height: 100,width: 50),
                        title: Transform.translate(offset: const Offset(0, -6),child: Text('${from1?.operatorlist[index].title}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold))),
                        subtitle: Transform.translate(offset: const Offset(0, -12),child: Text('${from1?.operatorlist[index].address}',style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 12),maxLines: 2,)),
                        trailing: Container(
                          height: 20,
                          width: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xffFFB733),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                              child: Row(
                               children: [
                                 const Spacer(),
                                 const Icon(Icons.star,color: Colors.white,size: 12),
                                 const SizedBox(width: 2,),
                                 Text('${from1?.operatorlist[index].rate}',style: const TextStyle(fontSize: 12,color: Colors.white)),
                                 const Spacer(),
                            ],
                          )),
                        ),
                      ),
                    ),
                  );
                },),
            ),
          ),
        ],
      ),
    );
  }

  getMarker() async {
    final Uint8List markIcon = await getImages("assets/CurrentPin.png", 80);
    markers.add(Marker(

      markerId: MarkerId(startLocation.toString()),
      position: LatLng(
        startLocation.latitude,
        startLocation.longitude,
      ),
      icon: BitmapDescriptor.fromBytes(markIcon), // position of marker
      onTap: () {
      },

    ));
    setState(() {
    });
  }

  Widget conference() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: from1?.operatorlist.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  print(from1?.operatorlist[index].title);
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          double.parse(from1?.operatorlist[index].lats ?? "0"),
                          double.parse(from1?.operatorlist[index].longs ?? ""),
                        ),
                        zoom: 12,
                      ),
                    ),
                  );
                  getmarkers(index);
                  getDirections(lat1: PointLatLng(startLocation.latitude, startLocation.longitude),lat2: PointLatLng(double.parse(from1?.operatorlist[index].lats ?? "0"), double.parse(from1?.operatorlist[index].longs ?? "")));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8,right: 8),
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Image(image: NetworkImage('${config().baseUrl}/${from1?.operatorlist[index].opImg}'),height: 100,width: 50),
                        title: Text('${from1?.operatorlist[index].title}',style: TextStyle(color: notifier.textColor,fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('${from1?.operatorlist[index].address}',style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 12)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  getmarkers(i) async {
    final Uint8List markIcon = await getImages("assets/Pin.png", 80);

      markers.add(Marker(

        markerId: MarkerId(i.toString()),
        position: LatLng(
          double.parse(from1?.operatorlist[i].lats ?? "0"),
          double.parse(from1?.operatorlist[i].longs ?? ""),
        ),
        icon: BitmapDescriptor.fromBytes(markIcon), //position of marker

        onTap: () {
          print(i.toString());
        },
      ));
  }



}
