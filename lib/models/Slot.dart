class Slot {
  final String id;
  final String slotStart;
  final String slotEnd;
  final int count;

  Slot(this.id, this.slotStart, this.slotEnd, this.count);

  Slot.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        slotStart = json["slot_start"],
        slotEnd = json["slot_end"],
        count = json["count"];

  Map<String, dynamic> toJson() =>
      {"id": id, "slot_start": slotStart, "slot_end": slotEnd, "count": count};
}
