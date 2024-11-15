
class DayModel {
  String data;
  bool full;

  DayModel({
    this.data = "",
    this.full = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'full': full,
    };
  }
}