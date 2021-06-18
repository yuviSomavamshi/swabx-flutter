class Appointment {
  final int id;
  final String date;
  final String time;
  final String location;
  final String status;

  Appointment(this.id, this.location, this.date, this.time, this.status);

  Appointment.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        date = json["slot_date"],
        time = json["slot_at"],
        location =
            (json["location"] != null) ? json["location"] : json["locationid"],
        status = json["status"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "time": time,
        "location": location,
        "status": status
      };
}
