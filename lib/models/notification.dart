class NotificationsData {
  String? message;
  NotificationsData({this.message});
  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    return NotificationsData(
      message: json['message'],
    );
  }
}

class NotificationUser {
  String? name, image;
  NotificationUser({this.name, this.image});
  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      name: json['name'],
      image: json['completeImage'],
    );
  }
}

class NotificationOrder {
  String? date, time;
  NotificationOrder({this.date, this.time});
  factory NotificationOrder.fromJson(Map<String, dynamic> json) {
    return NotificationOrder(
      date: json['date'],
      time: json['start_time'],
    );
  }
}
