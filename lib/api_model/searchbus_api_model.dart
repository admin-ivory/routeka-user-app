// To parse this JSON data, do
//
//     final searchBusApiModel = searchBusApiModelFromJson(jsonString);

import 'dart:convert';

SearchBusApiModel searchBusApiModelFromJson(String str) => SearchBusApiModel.fromJson(json.decode(str));

String searchBusApiModelToJson(SearchBusApiModel data) => json.encode(data.toJson());

class SearchBusApiModel {
  List<BusDatum>? busData;
  String? currency;
  String? responseCode;
  String? result;
  String? responseMsg;

  SearchBusApiModel({
    this.busData,
    this.currency,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory SearchBusApiModel.fromJson(Map<String, dynamic> json) => SearchBusApiModel(
    busData: json["BusData"] == null ? [] : List<BusDatum>.from(json["BusData"]!.map((x) => BusDatum.fromJson(x))),
    currency: json["currency"],
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "BusData": busData == null ? [] : List<dynamic>.from(busData!.map((x) => x.toJson())),
    "currency": currency,
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class BusDatum {
  String? busId;
  String? idPickupDrop;
  int? operatorId;
  String? busTitle;
  String? busNo;
  String? busImg;
  String? busPicktime;
  String? busDroptime;
  int? pricePerKm;
  double? distance;
  double? parcelPrice;
  int? remainingWeight;
  int? remainingCount;
  RateInfo? rateInfo;

  BusDatum({
    this.busId,
    this.idPickupDrop,
    this.operatorId,
    this.busTitle,
    this.busNo,
    this.busImg,
    this.busPicktime,
    this.busDroptime,
    this.pricePerKm,
    this.distance,
    this.parcelPrice,
    this.remainingWeight,
    this.remainingCount,
    this.rateInfo,
  });

  factory BusDatum.fromJson(Map<String, dynamic> json) => BusDatum(
    busId: json["bus_id"],
    idPickupDrop: json["id_pickup_drop"],
    operatorId: json["operator_id"],
    busTitle: json["bus_title"],
    busNo: json["bus_no"],
    busImg: json["bus_img"],
    busPicktime: json["bus_picktime"],
    busDroptime: json["bus_droptime"],
    pricePerKm: json["price_per_km"],
    distance: json["distance"]?.toDouble(),
    parcelPrice: json["parcel_price"]?.toDouble(),
    remainingWeight: json["remaining_weight"],
    remainingCount: json["remaining_count"],
    rateInfo: json["rate_info"] == null ? null : RateInfo.fromJson(json["rate_info"]),
  );

  Map<String, dynamic> toJson() => {
    "bus_id": busId,
    "id_pickup_drop": idPickupDrop,
    "operator_id": operatorId,
    "bus_title": busTitle,
    "bus_no": busNo,
    "bus_img": busImg,
    "bus_picktime": busPicktime,
    "bus_droptime": busDroptime,
    "price_per_km": pricePerKm,
    "distance": distance,
    "parcel_price": parcelPrice,
    "remaining_weight": remainingWeight,
    "remaining_count": remainingCount,
    "rate_info": rateInfo?.toJson(),
  };
}

class RateInfo {
  MatchedRate? matchedRate;
  List<AllRate>? allRates;

  RateInfo({
    this.matchedRate,
    this.allRates,
  });

  factory RateInfo.fromJson(Map<String, dynamic> json) => RateInfo(
    matchedRate: json["matched_rate"] == null ? null : MatchedRate.fromJson(json["matched_rate"]),
    allRates: json["all_rates"] == null ? [] : List<AllRate>.from(json["all_rates"]!.map((x) => AllRate.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "matched_rate": matchedRate?.toJson(),
    "all_rates": allRates == null ? [] : List<dynamic>.from(allRates!.map((x) => x.toJson())),
  };
}

class AllRate {
  double? minWeight;
  int? maxWeight;
  int? pricePerKm;

  AllRate({
    this.minWeight,
    this.maxWeight,
    this.pricePerKm,
  });

  factory AllRate.fromJson(Map<String, dynamic> json) => AllRate(
    minWeight: json["min_weight"]?.toDouble(),
    maxWeight: json["max_weight"],
    pricePerKm: json["price_per_km"],
  );

  Map<String, dynamic> toJson() => {
    "min_weight": minWeight,
    "max_weight": maxWeight,
    "price_per_km": pricePerKm,
  };
}

class MatchedRate {
  String? minWeight;
  String? maxWeight;
  String? pricePerKm;
  double? totalPrice;

  MatchedRate({
    this.minWeight,
    this.maxWeight,
    this.pricePerKm,
    this.totalPrice,
  });

  factory MatchedRate.fromJson(Map<String, dynamic> json) => MatchedRate(
    minWeight: json["min_weight"],
    maxWeight: json["max_weight"],
    pricePerKm: json["price_per_km"],
    totalPrice: json["total_price"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "min_weight": minWeight,
    "max_weight": maxWeight,
    "price_per_km": pricePerKm,
    "total_price": totalPrice,
  };
}
