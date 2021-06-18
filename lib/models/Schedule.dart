class Schedule {
  final int id;
  final String date;
  final String time;
  final String location;
  final String status;
  final String patientName;
  final String patientHash;

  Schedule(this.id, this.location, this.date, this.time, this.status,
      this.patientName, this.patientHash);

  Schedule.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        date = json["slot_date"],
        time = json["slot_at"],
        location = json["locationid"],
        status = json["status"],
        patientName = json["patient"],
        patientHash = json["s_id"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "time": time,
        "location": location,
        "status": status,
        "patient": patientName
      };
}
