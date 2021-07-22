class User {
  final String id;
  final String name;
  final String email;
  final String created;
  final String role;
  final bool isVerified;
  final String jwtToken;
  final String message;
  final int statusCode;
  final String refreshToken;
  final String csrfToken;
  final String session;

  User(
      this.name,
      this.id,
      this.email,
      this.role,
      this.isVerified,
      this.jwtToken,
      this.message,
      this.statusCode,
      this.created,
      this.refreshToken,
      this.csrfToken,
      this.session);

  String getId() {
    return id;
  }

  int getStatusCode() {
    return statusCode;
  }

  User.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        id = json["id"],
        email = json["email"],
        role = json["role"],
        isVerified = json["isVerified"],
        jwtToken = json["jwtToken"],
        message = json["message"],
        statusCode = json["statusCode"],
        created = json["created"],
        refreshToken = json["refreshToken"],
        csrfToken = json["csrfToken"],
        session = json["session"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "role": role,
        "isVerified": isVerified,
        "jwtToken": jwtToken,
        "message": message,
        "statusCode": statusCode,
        "created": created,
        "refreshToken": refreshToken,
        "csrfToken": csrfToken,
        "session": session
      };
}
