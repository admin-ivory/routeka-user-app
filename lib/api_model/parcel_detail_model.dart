// To parse this JSON data, do
//
//     final parcelDetailApiModel = parcelDetailApiModelFromJson(jsonString);

import 'dart:convert';

ParcelDetailApiModel parcelDetailApiModelFromJson(String str) => ParcelDetailApiModel.fromJson(json.decode(str));

String parcelDetailApiModelToJson(ParcelDetailApiModel data) => json.encode(data.toJson());

class ParcelDetailApiModel {
  String? responseCode;
  String? result;
  String? responseMsg;
  List<ParcelHistory>? parcelHistory;

  ParcelDetailApiModel({
    this.responseCode,
    this.result,
    this.responseMsg,
    this.parcelHistory,
  });

  factory ParcelDetailApiModel.fromJson(Map<String, dynamic> json) => ParcelDetailApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    parcelHistory: json["parcel_history"] == null ? [] : List<ParcelHistory>.from(json["parcel_history"]!.map((x) => ParcelHistory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "parcel_history": parcelHistory == null ? [] : List<dynamic>.from(parcelHistory!.map((x) => x.toJson())),
  };
}

class ParcelHistory {
  String? parcelId;
  String? busId;
  String? busTitle;
  String? busNo;
  String? busImg;
  DateTime? tripDate;
  String? senderName;
  String? senderMobile;
  String? receiverName;
  String? receiverMobile;
  String? wall_amt;
  String? fromCity;
  String? toCity;
  String? parcelWeight;
  String? price;
  String? status;
  DateTime? createdAt;
  String? pricePerKm;
  String? distance;
  String? transactionId;
  dynamic pMethodName;

  ParcelHistory({
    this.parcelId,
    this.busId,
    this.busTitle,
    this.busNo,
    this.busImg,
    this.tripDate,
    this.senderName,
    this.senderMobile,
    this.receiverName,
    this.receiverMobile,
    this.wall_amt,
    this.fromCity,
    this.toCity,
    this.parcelWeight,
    this.price,
    this.status,
    this.createdAt,
    this.pricePerKm,
    this.distance,
    this.transactionId,
    this.pMethodName,
  });

  factory ParcelHistory.fromJson(Map<String, dynamic> json) => ParcelHistory(
    parcelId: json["parcel_id"],
    busId: json["bus_id"],
    busTitle: json["bus_title"],
    busNo: json["bus_no"],
    busImg: json["bus_img"],
    tripDate: json["trip_date"] == null ? null : DateTime.parse(json["trip_date"]),
    senderName: json["sender_name"],
    senderMobile: json["sender_mobile"],
    receiverName: json["receiver_name"],
    receiverMobile: json["receiver_mobile"],
    wall_amt: json["wall_amt"],
    fromCity: json["from_city"],
    toCity: json["to_city"],
    parcelWeight: json["parcel_weight"],
    price: json["price"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    pricePerKm: json["price_per_km"],
    distance: json["distance"],
    transactionId: json["transaction_id"],
    pMethodName: json["p_method_name"],
  );

  Map<String, dynamic> toJson() => {
    "parcel_id": parcelId,
    "bus_id": busId,
    "bus_title": busTitle,
    "bus_no": busNo,
    "bus_img": busImg,
    "trip_date": "${tripDate!.year.toString().padLeft(4, '0')}-${tripDate!.month.toString().padLeft(2, '0')}-${tripDate!.day.toString().padLeft(2, '0')}",
    "sender_name": senderName,
    "sender_mobile": senderMobile,
    "receiver_name": receiverName,
    "receiver_mobile": receiverMobile,
    "wall_amt": wall_amt,
    "from_city": fromCity,
    "to_city": toCity,
    "parcel_weight": parcelWeight,
    "price": price,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "price_per_km": pricePerKm,
    "distance": distance,
    "transaction_id": transactionId,
    "p_method_name": pMethodName,
  };
}
