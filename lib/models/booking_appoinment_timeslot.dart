class TimeSlot {
  var startTime;

  TimeSlot({this.startTime});
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(startTime: json['start_time']);
  }
}
