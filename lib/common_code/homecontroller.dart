// ignore_for_file: unnecessary_import, prefer_collection_literals

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';
class HomeController extends  GetxController implements GetxService{


  int selectpage = 0;
  int selectpage1 = 0;
  Set<Marker> markers = Set();

  setselectpage(int value){
    selectpage = value;
    update();
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }


  getmarkers({required double lat,required double long}) async {
    final Uint8List markIcon = await getImages("assets/Group 427320330.png", 80);

    markers.add(Marker(

      markerId: const MarkerId("0"),
      position: LatLng(
        lat ,
        long,
      ),
      icon: BitmapDescriptor.fromBytes(markIcon), //position of marker

      onTap: () {
      },
    ));
   update();
  }
}