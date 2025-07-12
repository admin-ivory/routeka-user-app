// ignore_for_file: prefer_collection_literals, avoid_function_literals_in_foreach_calls, avoid_print

import 'package:routekacustomernew/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends  GetxController implements GetxService{

  Set<Marker> markers = Set();
  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
  Map<PolylineId, Polyline> polylines = {};
  getmarkers({required double lat,required double long,required double lat1,required double long2,}) async {

    markers.removeWhere((m) => m.markerId.value == '0');



    final Uint8List markIcon = await getImages("assets/Group 427320330.png", 80);

    markers.add(Marker(

      markerId: const MarkerId("0"),
      position: LatLng(
        lat ,
        long,
      ),
      icon: BitmapDescriptor.fromBytes(markIcon), // position of marker

      onTap: () {
      },

    ));



    // code add for remove polyline


    getDirections(lat1: PointLatLng(lat1, long2),lat2: PointLatLng(lat, long));

    update();
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
    update();
  }

  PolylinePoints polylinePoints = PolylinePoints();


  getDirections({required PointLatLng lat1, required PointLatLng lat2}) async {
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

}