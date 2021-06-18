class API {
  final int statusCode;
  final String message;

  API(this.statusCode, this.message);

  int getStatusCode() {
    return statusCode;
  }

  String getMessage() {
    return message;
  }

  API.fromJson(Map<String, dynamic> json)
      : statusCode =
            json["statusCode"] != null ? json["statusCode"] : json["_status"],
        message = json["message"] != null ? json["message"] : json["_msg"];

  Map<String, dynamic> toJson() =>
      {"statusCode": statusCode, "message": message};
}
