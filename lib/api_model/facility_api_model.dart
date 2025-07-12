// To parse this JSON data, do
//
//     final fasillity = fasillityFromJson(jsonString);

import 'dart:convert';

Fasillity fasillityFromJson(String str) => Fasillity.fromJson(json.decode(str));

String fasillityToJson(Fasillity data) => json.encode(data.toJson());

class Fasillity {
  List<Facilitylist> facilitylist;
  String responseCode;
  String result;
  String responseMsg;

  Fasillity({
    required this.facilitylist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Fasillity.fromJson(Map<String, dynamic> json) => Fasillity(
    facilitylist: List<Facilitylist>.from(json["facilitylist"].map((x) => Facilitylist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "facilitylist": List<dynamic>.from(facilitylist.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Facilitylist {
  String id;
  String title;
  String img;

  Facilitylist({
    required this.id,
    required this.title,
    required this.img,
  });

  factory Facilitylist.fromJson(Map<String, dynamic> json) => Facilitylist(
    id: json["id"],
    title: json["title"],
    img: json["img"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "img": img,
  };
}
