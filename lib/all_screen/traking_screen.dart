// ignore_for_file: unused_local_variable, unnecessary_import, camel_case_types, prefer_typing_uninitialized_variables, avoid_print, prefer_collection_literals

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

import '../common_code/mapcontroller.dart';
class Traking_Screen extends StatefulWidget {
  final String busId;
  final String subPickLat;
  final String subPickLong;
  const Traking_Screen({super.key, required this.busId, required this.subPickLat, required this.subPickLong});

  @override
  State<Traking_Screen> createState() => _Traking_ScreenState();
}

class _Traking_ScreenState extends State<Traking_Screen> {

//polylines to show direction
  CameraPosition? kGoogle;
  // Set<Marker> markers = Set(); // markers for google map
  late GoogleMapController mapController;
  bool isloading = true;
  MapController  mapController12 = Get.put(MapController());
  @override
  void initState() {
    
    fun();
    kGoogle = CameraPosition(
      target: LatLng(double.parse(widget.subPickLat), double.parse(widget.subPickLong)),
      zoom: 10,
    );
    // setState(() {
    // });
    super.initState();
  }

  var fields;

  fun(){
    CollectionReference collectionReference =
    FirebaseFirestore.instance.collection('driver');
    collectionReference.doc(widget.busId).get().then((value) {

      fields = value.data();
      print("+++++fieldsfieldsfieldsfieldsfields:---++++  $fields");
      print("+++++fieldsfieldsfieldsfieldsfields:---++++  ${fields['ischeck']}");
      print("+++++fieldsfieldsfieldsfieldsfields:---++++  ${fields['livelatitude']}");
      print("+++++fieldsfieldsfieldsfieldsfields:---++++  ${fields['livelongitude']}");

      if(fields['ischeck']){
        mapController12.getmarkers(lat: fields['livelatitude'],long: fields['livelongitude'],lat1:  fields['latitude'],long2: fields['longitude']);
        getMarker();

        // PolylineId id = const PolylineId("poly");
        // polylines.remove(id);

        setState(() {
        });
        
      }
      mapController12.getDirections(lat1: PointLatLng(fields['latitude'], fields['longitude']),lat2: PointLatLng(double.parse(widget.subPickLat), double.parse(widget.subPickLong)));
      // setState(() {
      // });

      setState(() {
        isloading = false;
      });

      // List<LatLng> polylineCoordinates = [];
      // addPolyLine(polylineCoordinates);
    });
  }


  Stream<DocumentSnapshot<Object?>> getdatafun(){
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('driver');
    // Stream<DocumentSnapshot<Object?>> data = collectionReference.doc(widget.busId).snapshots();
    collectionReference.doc(widget.busId).get().then((DocumentSnapshot value) {
      Map data = value.data() as Map<dynamic,dynamic>;
      // Future.delayed(Duration(seconds: 10),() {
      // },);
    });


   return collectionReference.doc(widget.busId).snapshots();
  }



  // Polyline Code





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading ? const Center(child: CircularProgressIndicator()) : Stack(
        children: [

          StreamBuilder(stream: getdatafun(), builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            }else{

              Map data = snapshot.data!.data() as Map<dynamic,dynamic>;
              mapController12.getmarkers(lat: data["livelatitude"], long: data["livelongitude"],long2: fields['longitude'],lat1: fields['latitude']);
              Future.delayed(const Duration(seconds: 0),() {
                PolylineId id = const PolylineId("poly");
                mapController12.polylines.remove(id);
                mapController12.getDirections(lat1: PointLatLng(data["livelatitude"], data["livelongitude"]),lat2: PointLatLng(double.parse(widget.subPickLat), double.parse(widget.subPickLong)));

              },);
              return
                Stack(children: [
                  SizedBox(
                    height: Get.size.height,
                    child: GetBuilder<MapController>(
                      builder: (mapController12) {
                        return GoogleMap(
                          polylines: Set<Polyline>.of(mapController12.polylines.values),
                          initialCameraPosition: kGoogle!,
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                            Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                            ),
                          ].toSet(),
                          mapType: MapType.normal,
                          markers: Set<Marker>.of(mapController12.markers),
                          myLocationEnabled: false,
                          compassEnabled: true,
                          zoomGesturesEnabled: true,
                          tiltGesturesEnabled: true,
                          zoomControlsEnabled: true,
                          onMapCreated: (controller) {
                            // setState(() {
                            //   polylines = {};
                            //   mapController = controller;
                            // });
                          },
                        );
                      }
                    ),
                  ),
                  Positioned(
                    top: 35,
                    left: 10,
                    child: Container(
                      height: 45,
                      width: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      child: BackButton(
                        onPressed: () {

                          Get.back();
                        },
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],);
            }
          },)
        ],
      ),
    );
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // getmarkers({required double lat,required double long}) async {
  //   final Uint8List markIcon = await getImages("assets/Group 427320330.png", 80);
  //
  //   mapController12.markers.add(Marker(
  //
  //     markerId: MarkerId("0"),
  //     position: LatLng(
  //       lat ,
  //       long,
  //     ),
  //     icon: BitmapDescriptor.fromBytes(markIcon), //position of marker
  //
  //     onTap: () {
  //     },
  //   ));
  //   setState(() {
  //   });
  // }

  getMarker() async {
    final Uint8List markIcon = await getImages("assets/CurrentPin.png", 80);
    mapController12.markers.add(Marker(

      markerId: MarkerId(widget.subPickLat.toString()),
      position: LatLng(
        double.parse(widget.subPickLat),
        double.parse(widget.subPickLong),
      ),
      icon: BitmapDescriptor.fromBytes(markIcon), // position of marker
      onTap: () {
      },

    ));
    setState(() {
    });
  }

}
