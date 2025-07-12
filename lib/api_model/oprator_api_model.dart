// To parse this JSON data, do
//
//     final operator = operatorFromJson(jsonString);

import 'dart:convert';

Operator operatorFromJson(String str) => Operator.fromJson(json.decode(str));

String operatorToJson(Operator data) => json.encode(data.toJson());

class Operator {
  List<Operatorlist> operatorlist;
  String responseCode;
  String result;
  String responseMsg;

  Operator({
    required this.operatorlist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Operator.fromJson(Map<String, dynamic> json) => Operator(
    operatorlist: List<Operatorlist>.from(json["operatorlist"].map((x) => Operatorlist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "operatorlist": List<dynamic>.from(operatorlist.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Operatorlist {
  String id;
  String title;
  String lats;
  String longs;
  String address;
  String opImg;
  String rate;

  Operatorlist({
    required this.id,
    required this.title,
    required this.lats,
    required this.longs,
    required this.address,
    required this.opImg,
    required this.rate,
  });

  factory Operatorlist.fromJson(Map<String, dynamic> json) => Operatorlist(
    id: json["id"],
    title: json["title"],
    lats: json["lats"],
    longs: json["longs"],
    address: json["address"],
    opImg: json["op_img"],
    rate: json["rate"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "lats": lats,
    "longs": longs,
    "address": address,
    "op_img": opImg,
    "rate": rate,
  };
}
