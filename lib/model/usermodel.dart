class UserDetailsModel {
  UserDetailsModel({
    this.fName,
    this.lName,
    this.email,
    this.password,
    this.uid,
  });

  String? fName;
  String? lName;
  String? email;
  String? password;
  String? uid;

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) => UserDetailsModel(
    fName: json["fName"],
    lName: json["lName"],
    email: json["email"],
    password: json["password"],
    uid: json["uid"],
  );

  Map<String, dynamic> toJson() => {
    "fName": fName,
    "lName": lName,
    "email": email,
    "password": password,
    "uid": uid,
  };
}
