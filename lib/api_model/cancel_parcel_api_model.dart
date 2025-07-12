// To parse this JSON data, do
//
//     final cancelParcelModel = cancelParcelModelFromJson(jsonString);

import 'dart:convert';

CancelParcelModel cancelParcelModelFromJson(String str) => CancelParcelModel.fromJson(json.decode(str));

String cancelParcelModelToJson(CancelParcelModel data) => json.encode(data.toJson());

class CancelParcelModel {
  String? responseCode;
  String? result;
  String? responseMsg;

  CancelParcelModel({
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory CancelParcelModel.fromJson(Map<String, dynamic> json) => CancelParcelModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}
