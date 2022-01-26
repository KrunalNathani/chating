class ChatDetailsModel {
  ChatDetailsModel({
    this.senderName,
    this.receiverName,
    this.token,
    this.massage,
    this.senderUid,
    this.receiverUid,
    this.dateTime,
    this.massageType,
    this.url,
    this.vidurl
  });

  String? senderName;
  String? receiverName;
  String? token;
  String? massage;
  String? senderUid;
  String? receiverUid;
  String? dateTime;
  String? massageType;
  String? url;
  String? vidurl;

  factory ChatDetailsModel.fromJson(Map<String, dynamic> json) => ChatDetailsModel(
    senderName: json["senderName"],
    receiverName: json["receiverName"],
    token: json["token"],
    massage: json["massage"],
    senderUid: json["senderUID"],
    receiverUid: json["receiverUID"],
    dateTime: json["dateTime"],
    massageType: json["massageType"],
    url: json["url"],
    vidurl: json["vidurl"],
  );

  Map<String, dynamic> toJson() => {
    "senderName": senderName,
    "receiverName": receiverName,
    "token": token,
    "massage": massage,
    "senderUID": senderUid,
    "receiverUID": receiverUid,
    "dateTime": dateTime,
    "massageType": massageType,
    "url": url,
    "vidurl": vidurl,
  };
}
