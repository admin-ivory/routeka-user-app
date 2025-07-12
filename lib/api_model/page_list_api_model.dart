import 'dart:convert';

// Fonctions de conversion
PageList pageListFromJson(String str) =>
    PageList.fromJson(json.decode(str));

String pageListToJson(PageList data) =>
    json.encode(data.toJson());

// Modèle principal
class PageList {
  List<Pagelist> pagelist;
  String responseCode;
  String result;
  String responseMsg;

  PageList({
    required this.pagelist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory PageList.fromJson(Map<String, dynamic> json) => PageList(
        pagelist: json["pagelist"] != null
            ? List<Pagelist>.from(
                (json["pagelist"] as List).map((x) => Pagelist.fromJson(x)))
            : [],
        responseCode: json["ResponseCode"]?.toString() ?? "",
        result: json["Result"]?.toString() ?? "",
        responseMsg: json["ResponseMsg"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "pagelist": pagelist.map((x) => x.toJson()).toList(),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

// Modèle secondaire
class Pagelist {
  String title;
  String description;

  Pagelist({
    required this.title,
    required this.description,
  });

  factory Pagelist.fromJson(Map<String, dynamic> json) => Pagelist(
        title: json["title"]?.toString() ?? "",
        description: json["description"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
      };
}