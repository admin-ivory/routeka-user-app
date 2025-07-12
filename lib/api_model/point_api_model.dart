// To parse this JSON data, do
//
//     final pointApiModel = pointApiModelFromJson(jsonString);

import 'dart:convert';

PointApiModel pointApiModelFromJson(String str) => PointApiModel.fromJson(json.decode(str));

String pointApiModelToJson(PointApiModel data) => json.encode(data.toJson());

class PointApiModel {
  List<Citylist>? citylist;
  String? responseCode;
  String? result;
  String? responseMsg;

  PointApiModel({
    this.citylist,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory PointApiModel.fromJson(Map<String, dynamic> json) => PointApiModel(
    citylist: json["citylist"] == null ? [] : List<Citylist>.from(json["citylist"]!.map((x) => Citylist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "citylist": citylist == null ? [] : List<dynamic>.from(citylist!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Citylist {
  String? id;
  String? title;
  String? address;
  String? mobile;
  String? lats;
  String? longs;

  Citylist({
    this.id,
    this.title,
    this.address,
    this.mobile,
    this.lats,
    this.longs,
  });

  factory Citylist.fromJson(Map<String, dynamic> json) => Citylist(
    id: json["id"],
    title: json["title"],
    address: json["address"],
    mobile: json["mobile"],
    lats: json["lats"],
    longs: json["longs"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "address": address,
    "mobile": mobile,
    "lats": lats,
    "longs": longs,
  };
}
