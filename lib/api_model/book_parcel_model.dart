// To parse this JSON data, do
//
//     final bookParcelApiModel = bookParcelApiModelFromJson(jsonString);

import 'dart:convert';

BookParcelApiModel bookParcelApiModelFromJson(String str) => BookParcelApiModel.fromJson(json.decode(str));

String bookParcelApiModelToJson(BookParcelApiModel data) => json.encode(data.toJson());

class BookParcelApiModel {
  String? responseCode;
  String? result;
  String? responseMsg;

  BookParcelApiModel({
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory BookParcelApiModel.fromJson(Map<String, dynamic> json) => BookParcelApiModel(
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
