class Location {
  final String id;
  final String location;
  final String created;

  Location(this.id, this.location, this.created);

  String getId() {
    return id;
  }

  String getLocation() {
    return location;
  }

  Location.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        location = json["location"],
        created = json["created"];

  Map<String, dynamic> toJson() =>
      {"id": id, "location": location, "created": created};
}
