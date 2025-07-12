// To parse this JSON data, do
//
//     final buslayout = buslayoutFromJson(jsonString);

import 'dart:convert';

Buslayout buslayoutFromJson(String str) => Buslayout.fromJson(json.decode(str));

String buslayoutToJson(Buslayout data) => json.encode(data.toJson());

class Buslayout {
  List<BusLayoutDatum> busLayoutData;
  String responseCode;
  String result;
  String responseMsg;
  String wallet;

  Buslayout({
    required this.busLayoutData,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.wallet,
  });

  factory Buslayout.fromJson(Map<String, dynamic> json) => Buslayout(
    busLayoutData: List<BusLayoutDatum>.from(json["BusLayoutData"].map((x) => BusLayoutDatum.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    wallet: json["wallet"],
  );

  Map<String, dynamic> toJson() => {
    "BusLayoutData": List<dynamic>.from(busLayoutData.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "wallet": wallet,
  };
}

class BusLayoutDatum {
  String driverDirection;
  String ticketPrice;
  String decker;
  String totlSeat;
  String bookLimit;
  List<List<ErLayout>> lowerLayout;
  List<List<ErLayout>> upperLayout;

  BusLayoutDatum({
    required this.driverDirection,
    required this.ticketPrice,
    required this.decker,
    required this.totlSeat,
    required this.bookLimit,
    required this.lowerLayout,
    required this.upperLayout,
  });

  factory BusLayoutDatum.fromJson(Map<String, dynamic> json) => BusLayoutDatum(
    driverDirection: json["driver_direction"],
    ticketPrice: json["ticket_price"],
    decker: json["decker"],
    totlSeat: json["totl_seat"],
    bookLimit: json["book_limit"],
    lowerLayout: List<List<ErLayout>>.from(json["lower_layout"].map((x) => List<ErLayout>.from(x.map((x) => ErLayout.fromJson(x))))),
    upperLayout: List<List<ErLayout>>.from(json["upper_layout"].map((x) => List<ErLayout>.from(x.map((x) => ErLayout.fromJson(x))))),
  );

  Map<String, dynamic> toJson() => {
    "driver_direction": driverDirection,
    "ticket_price": ticketPrice,
    "decker": decker,
    "totl_seat": totlSeat,
    "book_limit": bookLimit,
    "lower_layout": List<dynamic>.from(lowerLayout.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
    "upper_layout": List<dynamic>.from(upperLayout.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
  };
}

class ErLayout {
  String seatNumber;
  String seatType;
  bool isBooked;
  dynamic gender;

  ErLayout({
    required this.seatNumber,
    required this.seatType,
    required this.isBooked,
    this.gender,
  });

  factory ErLayout.fromJson(Map<String, dynamic> json) => ErLayout(
    seatNumber: json["seat_number"],
    seatType: json["seat_type"],
    isBooked: json["is_booked"],
    gender: json["gender"],
  );

  Map<String, dynamic> toJson() => {
    "seat_number": seatNumber,
    "seat_type": seatType,
    "is_booked": isBooked,
    "gender": gender,
  };
}
// class ErLayout {
//   String seatNumber;
//   String seattype;
//   bool isBooked;
//   String? gender;
//
//   ErLayout({
//     required this.seatNumber,
//     required this.seattype,
//     required this.isBooked,
//     required this.gender,
//   });
//
//   factory ErLayout.fromJson(Map<String, dynamic> json) => ErLayout(
//     seatNumber: json["seat_number"],
//     seattype: json["seat_type"],
//     isBooked: json["is_booked"],
//     gender: json["gender"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "seat_number": seatNumber,
//     "seat_type": seattype,
//     "is_booked": isBooked,
//     "gender": gender,
//   };
// }


















// // To parse this JSON data, do
// //
// //     final buslayout = buslayoutFromJson(jsonString);
//
// import 'dart:convert';
//
// Buslayout buslayoutFromJson(String str) => Buslayout.fromJson(json.decode(str));
//
// String buslayoutToJson(Buslayout data) => json.encode(data.toJson());
//
// class Buslayout {
//   List<BusLayoutDatum> busLayoutData;
//   String responseCode;
//   String result;
//   String responseMsg;
//   String wallet;
//
//   Buslayout({
//    required this.busLayoutData,
//    required this.responseCode,
//    required this.result,
//    required this.responseMsg,
//    required this.wallet,
//   });
//
//   factory Buslayout.fromJson(Map<String, dynamic> json) => Buslayout(
//     busLayoutData: List<BusLayoutDatum>.from(json["BusLayoutData"].map((x) => BusLayoutDatum.fromJson(x))),
//     responseCode: json["ResponseCode"],
//     result: json["Result"],
//     responseMsg: json["ResponseMsg"],
//     wallet: json["wallet"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "BusLayoutData": List<dynamic>.from(busLayoutData.map((x) => x.toJson())),
//     "ResponseCode": responseCode,
//     "Result": result,
//     "ResponseMsg": responseMsg,
//     "wallet": wallet,
//   };
// }
//
// class BusLayoutDatum {
//   String driverDirection;
//   String ticketPrice;
//   String decker;
//   String totlSeat;
//   String bookLimit;
//   String isSleeper;
//   List<List<LowerLayout>> lowerLayout;
//   List<dynamic> upperLayout;
//
//   BusLayoutDatum({
//    required this.driverDirection,
//    required this.ticketPrice,
//    required this.decker,
//    required this.totlSeat,
//    required this.bookLimit,
//    required this.isSleeper,
//    required this.lowerLayout,
//    required this.upperLayout,
//   });
//
//   factory BusLayoutDatum.fromJson(Map<String, dynamic> json) => BusLayoutDatum(
//     driverDirection: json["driver_direction"],
//     ticketPrice: json["ticket_price"],
//     decker: json["decker"],
//     totlSeat: json["totl_seat"],
//     bookLimit: json["book_limit"],
//     isSleeper: json["is_sleeper"],
//     lowerLayout: List<List<LowerLayout>>.from(json["lower_layout"].map((x) => List<LowerLayout>.from(x.map((x) => LowerLayout.fromJson(x))))),
//     upperLayout: List<dynamic>.from(json["upper_layout"].map((x) => x)),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "driver_direction": driverDirection,
//     "ticket_price": ticketPrice,
//     "decker": decker,
//     "totl_seat": totlSeat,
//     "book_limit": bookLimit,
//     "is_sleeper": isSleeper,
//     "lower_layout": List<dynamic>.from(lowerLayout.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
//     "upper_layout": List<dynamic>.from(upperLayout.map((x) => x)),
//   };
// }
//
// class LowerLayout {
//   String seatNumber;
//   String seatType;
//   bool isBooked;
//   dynamic gender;
//
//   LowerLayout({
//     required this.seatNumber,
//     required this.seatType,
//     required this.isBooked,
//     this.gender,
//   });
//
//   factory LowerLayout.fromJson(Map<String, dynamic> json) => LowerLayout(
//     seatNumber: json["seat_number"],
//     seatType: json["seat_type"],
//     isBooked: json["is_booked"],
//     gender: json["gender"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "seat_number": seatNumber,
//     "seat_type": seatType,
//     "is_booked": isBooked,
//     "gender": gender,
//   };
// }
